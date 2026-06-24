<!---
    P11 Step 2 Save: Add Your Representation
    Creates contacts with a single role tag (Agent/Manager/Publicist). D6: team
    and rep membership are derived from the role tag by repointed readers.
    Auth + CSRF handled by ajax/Application.cfc.
--->
<cfset userid = session.userid>

<!--- Parse rep array from form data --->
<cfparam name="form.reps" default="[]" />
<cfset reps = []>
<cftry>
    <cfset reps = deserializeJSON(form.reps)>
    <cfcatch>
        <cfset reps = []>
    </cfcatch>
</cftry>

<cfset contactsCreated = 0>
<!--- WO-C: ids of contacts created this submit, provisioned post-commit. --->
<cfset createdContactIds = []>

<cftry>
<cftransaction>

    <cfloop array="#reps#" index="rep">
        <cfset repName = trim(rep.name ?: "")>
        <cfif NOT len(repName)>
            <cfcontinue>
        </cfif>

        <cfset repRole = trim(rep.role ?: "Agent")>
        <cfset repCompany = trim(rep.company ?: "")>
        <cfset repPhone = trim(rep.phone ?: "")>
        <cfset repEmail = trim(rep.email ?: "")>

        <!--- Create contact via ContactService --->
        <cfset contactService = request.svc("ContactService")>
        <cfset newContactId = contactService.create({
            userid: userid,
            contactFullName: repName,
            contacttitle: repRole,
            contactStatus: "Active"
        })>

        <!--- Insert contact items --->
        <cfif len(repEmail)>
            <cfquery datasource="#application.datasource#">
                INSERT INTO contactitems_tbl (contactid, valueCategory, valueType, valuetext, primary_yn, itemStatus)
                VALUES (
                    <cfqueryparam value="#newContactId#" cfsqltype="cf_sql_integer" />,
                    'Email', 'Business',
                    <cfqueryparam value="#repEmail#" cfsqltype="cf_sql_varchar" />,
                    'Y', 'Active'
                )
            </cfquery>
        </cfif>

        <cfif len(repPhone)>
            <cfquery datasource="#application.datasource#">
                INSERT INTO contactitems_tbl (contactid, valueCategory, valueType, valuetext, primary_yn, itemStatus)
                VALUES (
                    <cfqueryparam value="#newContactId#" cfsqltype="cf_sql_integer" />,
                    'Phone', 'Work',
                    <cfqueryparam value="#repPhone#" cfsqltype="cf_sql_varchar" />,
                    'Y', 'Active'
                )
            </cfquery>
        </cfif>

        <cfif len(repCompany)>
            <cfquery datasource="#application.datasource#">
                INSERT INTO contactitems_tbl (contactid, valueCategory, valueType, valueCompany, itemStatus)
                VALUES (
                    <cfqueryparam value="#newContactId#" cfsqltype="cf_sql_integer" />,
                    'Company', 'Company',
                    <cfqueryparam value="#repCompany#" cfsqltype="cf_sql_varchar" />,
                    'Active'
                )
            </cfquery>
        </cfif>

        <!--- D6 (Option A): write only the single role tag (Agent/Manager/
              Publicist). 'My Rep Team' and 'My Team' are no longer written here;
              team and rep membership are derived from the role tag by the
              repointed readers (ContactService SELcontactdetails_24683/GetMyTeam/
              getContactForCard, LookupService.getContactsNotTeam, wizard steps
              2/5/7).
              TECH-DEBT: pre-existing 'My Team'/'My Rep Team' rows on live
              contacts are intentionally left in place; removing them is a
              separate data-cleanup pass, not part of this work order. --->
        <cfquery datasource="#application.datasource#">
            INSERT INTO contactitems_tbl (contactid, valueCategory, valueType, valuetext, itemStatus)
            VALUES (
                <cfqueryparam value="#newContactId#" cfsqltype="cf_sql_integer" />,
                'Tag', 'Tags',
                <cfqueryparam value="#repRole#" cfsqltype="cf_sql_varchar" />,
                'Active'
            )
        </cfquery>

        <cfset arrayAppend(createdContactIds, newContactId)>
        <cfset contactsCreated++>
    </cfloop>

    <!--- Update wizard progress --->
    <cfquery datasource="#application.datasource#">
        UPDATE taousers_tbl
        SET setup_step = 2
        WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
    </cfquery>

</cftransaction>

    <!--- WO-C: provision contact media folders. Filesystem-only, best-effort, AFTER
          the DB transaction commits (mirrors remoteAddContactAdd.cfm:62-65). A folder
          failure must NEVER roll back an already-committed contact. --->
    <cfif arrayLen(createdContactIds)>
        <cftry>
            <!--- Defensive: session media paths are normally set by
                  /app/Application.cfc:459-478 on the /app/setup-wizard/ page load.
                  If absent (cold path), derive from application.baseMediaPath with the
                  IDENTICAL derivation -- not a hardcoded path. WO-C register: this
                  inline copy shadows app/Application.cfc block 4. --->
            <cfif NOT structKeyExists(session, "userMediaPath") OR NOT len(trim(session.userMediaPath))>
                <cfset session.userMediaPath    = application.baseMediaPath & "\\users\\" & userid>
                <cfset session.userMediaUrl     = application.baseMediaUrl  & "/users/" & userid>
                <cfset session.userContactsPath = session.userMediaPath & "\\contacts">
                <cfset session.userContactsUrl  = session.userMediaUrl  & "/contacts">
                <cfset session.userImportsUrl   = session.userMediaUrl  & "/imports">
                <cfset session.userAvatarPath   = session.userMediaPath & "\\avatar.jpg">
            </cfif>

            <cfloop array="#createdContactIds#" index="provContactId">
                <cfset select_userid    = userid>
                <cfset select_contactid = provContactId>
                <!--- cfsavecontent captures and discards the include's dir-create HTML
                      so it never reaches the JSON response body. --->
                <cfsavecontent variable="provHtmlSink">
                    <cfinclude template="/include/contactfolder_setup.cfm">
                </cfsavecontent>
                <cflog file="TAO_setup_wizard" type="information"
                       text="WO-C step2 folder provisioned: userid=#userid# contactid=#provContactId# path=#session.userMediaPath#\contacts\#provContactId#">
            </cfloop>
        <cfcatch type="any">
            <cflog file="TAO_setup_wizard" type="error"
                   text="WO-C step2 folder provisioning failed (contacts committed, continuing): #cfcatch.message# | #cfcatch.detail#">
        </cfcatch>
        </cftry>
    </cfif>

    <cfset session.setup_step = 2>

    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({
        "success": true,
        "message": contactsCreated & " contact(s) created.",
        "data": {"contactsCreated": contactsCreated}
    })#</cfoutput>

<cfcatch type="any">
    <cflog file="TAO_setup_wizard" type="error"
           text="Step 2 save failed for user #userid#: #cfcatch.message# | #cfcatch.detail#" />
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({"success": false, "message": "Failed to save contacts. Please try again."})#</cfoutput>
</cfcatch>
</cftry>
