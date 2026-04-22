<!---
    P11 Step 4 Save: Import or Add Auditions
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

        <cfset audDate = trim(aud.audDate ?: "")>
        <cfif NOT len(audDate) OR NOT isDate(audDate)>
            <cfset audDate = now()>
        </cfif>

        <!--- UI sends audsubcatid (the "Other" subcategory of the chosen category).
              audcatid is derivable via JOIN, so we don't pass it separately. --->
        <cfset audSubCatID = val(aud.audsubcatid ?: "0")>

        <!--- Pick a valid role type for the chosen category.
              audroletypes is category-scoped (audroletypes.audcatid), so we JOIN
              through audsubcategories to land on a role type that belongs to the
              same category. Fallback to 1 (Film > Background) if nothing matches. --->
        <cfset audRoleTypeID = 1>
        <cfif audSubCatID GT 0>
            <cfquery name="qRoleType" datasource="#application.datasource#">
                SELECT rt.audroletypeid
                FROM audroletypes rt
                INNER JOIN audsubcategories sc ON sc.audcatid = rt.audcatid
                WHERE sc.audsubcatid = <cfqueryparam value="#audSubCatID#" cfsqltype="cf_sql_integer" />
                  AND rt.isDeleted = 0
                ORDER BY rt.audroletypeid
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
        <cfquery datasource="#application.datasource#">
            INSERT INTO audroles (
                audRoleName, audprojectID, audRoleTypeID, charDescription,
                holdStartDate, holdEndDate, audDialectID, audSourceID,
                userid, isDeleted, isBooked
            ) VALUES (
                <cfqueryparam cfsqltype="cf_sql_varchar"     value="#projName#" maxlength="500" />,
                <cfqueryparam cfsqltype="cf_sql_integer"     value="#newProjId#" />,
                <cfqueryparam cfsqltype="cf_sql_integer"     value="#audRoleTypeID#" />,
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
