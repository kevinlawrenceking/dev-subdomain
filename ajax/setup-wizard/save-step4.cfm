<!---
    P11 Step 4 Save: Add Auditions (manual quick-add only)
    Bulk import removed from setup 2026-05-30.
    Creates audition projects/roles via AuditionProjectService.
    Auth + CSRF handled by ajax/Application.cfc.
    TECH-DEBT: INSaudprojects() uses cookie.userid, so we set it here.
--->
<cfset userid = session.userid>

<cfparam name="form.auditions" default="[]" />
<cfset auditions = []>
<cftry>
    <cfset auditions = deserializeJSON(form.auditions)>
    <cfcatch><cfset auditions = []></cfcatch>
</cftry>

<cfset auditionsCreated = 0>

<!--- TECH-DEBT: Inlined INSERT from INSaudprojects() to avoid cookie.userid. Main app still uses cookie path. --->

<cftry>
<cftransaction>

    <cfloop array="#auditions#" index="aud">
        <cfset projName = trim(aud.projectName ?: "")>
        <cfif NOT len(projName)><cfcontinue></cfif>

        <!--- D7: role/character is its own value, distinct from the project title.
              Optional in the wizard; stored empty when not supplied. --->
        <cfset roleName = trim(aud.roleName ?: "")>

        <cfset audDate = trim(aud.audDate ?: "")>
        <cfif NOT len(audDate) OR NOT isDate(audDate)>
            <cfset audDate = now()>
        </cfif>

        <!--- UI sends audsubcatid (the "Other" subcategory of the chosen category).
              audcatid is derivable via JOIN, so we don't pass it separately. --->
        <cfset audSubCatID = val(aud.audsubcatid ?: "0")>

        <!--- Role type is a required, user-selected field in the wizard.
              Trust but verify: store the submitted audroletypeid only if it is a
              live role type belonging to the chosen category (audroletypes is
              category-scoped). If it is missing or invalid, leave it UNSET (NULL)
              rather than silently defaulting to Background (B3). --->
        <cfset audRoleTypeID = "">
        <cfset submittedRoleTypeID = val(aud.audroletypeid ?: "0")>
        <cfif submittedRoleTypeID GT 0 AND audSubCatID GT 0>
            <cfquery name="qRoleType" datasource="#application.datasource#">
                SELECT rt.audroletypeid
                FROM audroletypes rt
                INNER JOIN audsubcategories sc ON sc.audcatid = rt.audcatid
                WHERE sc.audsubcatid = <cfqueryparam value="#audSubCatID#" cfsqltype="cf_sql_integer" />
                  AND rt.isDeleted = 0
                  AND rt.audroletypeid = <cfqueryparam value="#submittedRoleTypeID#" cfsqltype="cf_sql_integer" />
                LIMIT 1
            </cfquery>
            <cfif qRoleType.recordCount>
                <cfset audRoleTypeID = qRoleType.audroletypeid>
            </cfif>
        </cfif>

        <!--- Create project (inline to avoid cookie.userid dependency).
              Mirrors AuditionImportService column set so prod MySQL strict-mode
              doesn't reject missing NOT-NULL-no-default columns. --->
        <cfquery result="projResult" datasource="#application.datasource#">
            INSERT INTO audprojects (
                projName, projDescription, userid, audSubCatID,
                isDeleted, isDirect, contactid, projdate, audprojectdate
            ) VALUES (
                <cfqueryparam cfsqltype="cf_sql_varchar"     value="#projName#" maxlength="500" />,
                <cfqueryparam cfsqltype="cf_sql_longvarchar" value="" null="true" />,
                <cfqueryparam cfsqltype="cf_sql_integer"     value="#userid#" />,
                <cfqueryparam cfsqltype="cf_sql_integer"     value="#audSubCatID#" />,
                <cfqueryparam cfsqltype="cf_sql_bit"         value="0" />,
                <cfqueryparam cfsqltype="cf_sql_bit"         value="0" />,
                <cfqueryparam cfsqltype="cf_sql_integer"     value="0" null="true" />,
                <cfqueryparam cfsqltype="cf_sql_date"        value="#audDate#" />,
                <cfqueryparam cfsqltype="cf_sql_date"        value="#audDate#" />
            )
        </cfquery>
        <cfset newProjId = projResult.generatedKey>

        <!--- Default role, keyed to the chosen category's role type set.
              TECH-DEBT: Inlined INSERT instead of AuditionRoleService.INSaudroles()
              because that function declares new_holdStartDate/new_holdEndDate/
              new_audDialectID/new_audSourceID as required=false with NO default,
              then dereferences arguments.<name> unconditionally -- so any caller
              that omits them hits "element is undefined in arguments".
              Column set mirrors the service so table defaults/nullability match. --->
        <cfquery result="roleResult" datasource="#application.datasource#">
            INSERT INTO audroles (
                audRoleName, audprojectID, audRoleTypeID, charDescription,
                holdStartDate, holdEndDate, audDialectID, audSourceID,
                userid, isDeleted, isBooked
            ) VALUES (
                <cfqueryparam cfsqltype="cf_sql_varchar"     value="#roleName#" maxlength="500" />,
                <cfqueryparam cfsqltype="cf_sql_integer"     value="#newProjId#" />,
                <cfqueryparam cfsqltype="cf_sql_integer"     value="#audRoleTypeID#" null="#NOT len(audRoleTypeID)#" />,
                <cfqueryparam cfsqltype="cf_sql_longvarchar" value="" null="true" />,
                <cfqueryparam cfsqltype="cf_sql_date"        value="" null="true" />,
                <cfqueryparam cfsqltype="cf_sql_date"        value="" null="true" />,
                <cfqueryparam cfsqltype="cf_sql_integer"     value="0" null="true" />,
                <cfqueryparam cfsqltype="cf_sql_integer"     value="0" null="true" />,
                <cfqueryparam cfsqltype="cf_sql_integer"     value="#userid#" />,
                <cfqueryparam cfsqltype="cf_sql_bit"         value="0" />,
                <cfqueryparam cfsqltype="cf_sql_bit"         value="0" />
            )
        </cfquery>
        <cfset newAudRoleId = roleResult.generatedKey>

        <!--- WO-A: Create the audition event the main app creates, gated identically.
              The main app writes an events row whenever isDirect NEQ 1
              (include/audition-add2.cfm:156). The wizard always logs a real
              (non-direct) audition, so it meets that condition and must create the
              same event -- keyed to the new audroleid -- otherwise the audition shows
              with blank appointment/step columns and is dropped by views that
              INNER JOIN events (e.g. the per-contact CD history). Routed through the
              canonical EventService.INSevents_24555 (no inline events_tbl INSERT).
              Sits INSIDE the existing step-4 transaction, so project + role + event +
              CD links commit or roll back together as one atomic unit. --->
        <cfset audIsDirect = 0><!--- mirrors the bit written to audprojects.isDirect above; do NOT flip --->
        <cfif audIsDirect NEQ 1>

            <!--- Idempotency guard (audrole-scoped): skip if a non-deleted event
                  already exists for this audrole. The events view filters
                  IsDeleted = 0, so a view read yields "non-deleted" for free.
                  Re-running step 4 must not add a second event for the same audrole. --->
            <cfquery name="qExistingEvent" datasource="#application.datasource#" maxrows="1">
                SELECT eventID
                FROM events
                WHERE audRoleID = <cfqueryparam value="#newAudRoleId#" cfsqltype="cf_sql_integer" />
            </cfquery>

            <cfif qExistingEvent.recordCount EQ 0>
                <!--- INTENTIONAL DEVIATION from the main app: cap the event title to
                      255 chars. events_tbl.eventTitle is varchar(255) but the service
                      binds maxlength=500; an over-length title would roll back the
                      ENTIRE wizard transaction (project + role + event + CD xref).
                      Trimming the title is strictly safer than losing the whole
                      audition. The wizard is deliberately stricter than the main app
                      here. (Main app's 500-bind-into-255-column mismatch is logged
                      separately as a hygiene backlog item; not fixed under WO-A.) --->
                <cfset eventTitle = left(projName, 255)>

                <!--- Sentinel args mirror auditions_ins_373_1.cfm:5-15 so the
                      conditional writes inside INSevents_24555 behave exactly like the
                      main app: only userid, audRoleID, audStepID (=1 'Audition') and
                      eventtitle are written; every other column is skipped. The
                      workwithcoach/trackmileage args go in as 0 (the INSevents guard is
                      isBoolean(), not NEQ 0), written as bit 0 -- identical to main. --->
                <cfset eventSvc = request.svc("EventService")>
                <cfset new_eventid = eventSvc.INSevents_24555(
                    new_userid         = userid,
                    new_audRoleID      = newAudRoleId,
                    new_audTypeID      = 0,
                    new_audLocation    = "",
                    new_eventStart     = "1970-01-01",
                    new_eventStartTime = "00:00:00",
                    new_eventStopTime  = "00:00:00",
                    new_audplatformid  = 0,
                    new_audStepID      = 1,
                    new_parkingDetails = "",
                    new_workwithcoach  = 0,
                    new_trackmileage   = 0,
                    new_eventtitle     = eventTitle
                )>

                <cflog file="TAO_setup_wizard" type="information"
                       text="Step 4 event created: userid=#userid# audprojectid=#newProjId# audroleid=#newAudRoleId# eventid=#new_eventid#" />
            </cfif>
        </cfif>

        <!--- Link the casting director to this audition. Resolve the typed CD name
              to a contact for this user (match an existing active contact by name
              first for idempotency, otherwise create one). Mirrors the canonical
              include/audition-add2.cfm path; all within the surrounding transaction. --->
        <cfset cdName = trim(aud.castingDirector ?: "")>
        <cfif len(cdName)>
            <cfquery name="qCd" datasource="#application.datasource#" maxrows="1">
                SELECT contactid
                FROM contactdetails
                WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
                  AND contactFullName = <cfqueryparam value="#cdName#" cfsqltype="cf_sql_varchar" />
                  AND contactStatus = 'Active'
            </cfquery>
            <cfif qCd.recordCount>
                <cfset cdContactId = qCd.contactid>
            <cfelse>
                <!--- Create with contactStatus='Active' (matches save-step2 and the
                      dedupe lookup above) so a re-submit resolves the same contact
                      instead of creating a duplicate. --->
                <cfset cdContactId = request.svc("ContactService").create({
                    userid: userid,
                    contactFullName: cdName,
                    contactStatus: "Active"
                })>
            </cfif>

            <!--- B1: the audition list/detail views read the CD name from
                  contactdetails.recordname (aliased castingFullName), not
                  contactFullName. Populate recordname when empty so the saved CD
                  actually shows. Non-destructive: never overwrites an existing name. --->
            <cfquery datasource="#application.datasource#">
                UPDATE contactdetails
                SET recordname = <cfqueryparam value="#cdName#" cfsqltype="cf_sql_varchar" />
                WHERE contactid = <cfqueryparam value="#cdContactId#" cfsqltype="cf_sql_integer" />
                  AND userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
                  AND (recordname IS NULL OR recordname = '')
            </cfquery>

            <!--- B1: the audition views join the CD on audprojects.contactid
                  (DETaudprojects_24554 / SELaudprojects). The wizard inserted the
                  project with contactid NULL, so the CD never appeared. Link it now. --->
            <cfquery datasource="#application.datasource#">
                UPDATE audprojects
                SET contactid = <cfqueryparam value="#cdContactId#" cfsqltype="cf_sql_integer" />
                WHERE audprojectid = <cfqueryparam value="#newProjId#" cfsqltype="cf_sql_integer" />
                  AND userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
            </cfquery>

            <!--- Secondary project-contact link used by other features. INSERT IGNORE,
                  so a double-submit will not create a duplicate. --->
            <cfset request.svc("ContactAuditionService").INSaudcontacts_auditions_xref_23780(
                audprojectid = newProjId,
                new_contactid = cdContactId
            )>

            <!--- B2: tag the contact as a Casting Director in the relationship record
                  (contactitems Tag), mirroring the main app's insert_28_2 path so the
                  role appears and Step 5 can scope it. Idempotent: skip if the active
                  tag already exists (re-submit safe). --->
            <cfquery name="qCdTag" datasource="#application.datasource#" maxrows="1">
                SELECT 1 FROM contactitems
                WHERE contactid = <cfqueryparam value="#cdContactId#" cfsqltype="cf_sql_integer" />
                  AND valueType = 'Tags'
                  AND valueCategory = 'Tag'
                  AND valuetext = <cfqueryparam value="Casting Director" cfsqltype="cf_sql_varchar" />
                  AND itemStatus = 'Active'
            </cfquery>
            <cfif qCdTag.recordCount EQ 0>
                <cfset request.svc("ContactItemService").INScontactitems(
                    new_contactid = cdContactId,
                    cdtype = "Casting Director"
                )>
            </cfif>
        </cfif>

        <cfset auditionsCreated++>
    </cfloop>

    <cfquery datasource="#application.datasource#">
        UPDATE taousers_tbl SET setup_step = 4
        WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
    </cfquery>

</cftransaction>

    <cfset session.setup_step = 4>
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({
        "success": true,
        "message": auditionsCreated & " audition(s) logged.",
        "data": {"auditionsCreated": auditionsCreated}
    })#</cfoutput>

<cfcatch type="any">
    <cfset ctxFile = "">
    <cfset ctxLine = "">
    <cfif isArray(cfcatch.tagContext) AND arrayLen(cfcatch.tagContext)>
        <cfset ctxFile = cfcatch.tagContext[1].template>
        <cfset ctxLine = cfcatch.tagContext[1].line>
    </cfif>
    <cflog file="TAO_setup_wizard" type="error"
           text="Step 4 save failed for user #userid# type=#cfcatch.type# msg=#cfcatch.message# detail=#cfcatch.detail# at=#ctxFile#:#ctxLine#" />
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({
        "success": false,
        "message": "Failed to save auditions.",
        "errorType": cfcatch.type,
        "errorMessage": cfcatch.message,
        "errorDetail": cfcatch.detail,
        "errorAt": ctxFile & ":" & ctxLine
    })#</cfoutput>
</cfcatch>
</cftry>
