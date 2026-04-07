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

<!--- TECH-DEBT: INSaudprojects() reads cookie.userid internally.
      Set cookie to match session for this request. --->
<cfcookie name="userid" value="#userid#" />

<cftry>
<cftransaction>

    <cfset audProjService = request.svc("AuditionProjectService")>
    <cfset audRoleService = request.svc("AuditionRoleService")>

    <cfloop array="#auditions#" index="aud">
        <cfset projName = trim(aud.projectName ?: "")>
        <cfif NOT len(projName)><cfcontinue></cfif>

        <cfset audDate = trim(aud.audDate ?: "")>
        <cfif NOT len(audDate) OR NOT isDate(audDate)>
            <cfset audDate = now()>
        </cfif>

        <!--- Create project --->
        <cfset newProjId = audProjService.INSaudprojects(
            new_projName = projName,
            new_projdate = audDate
        )>

        <!--- Create a default role entry --->
        <cfset audRoleService.INSaudroles(
            new_audRoleName = projName,
            new_audprojectID = newProjId,
            new_audRoleTypeID = 1,
            new_userid = userid
        )>

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
    <cflog file="TAO_setup_wizard" type="error"
           text="Step 4 save failed for user #userid#: #cfcatch.message# | #cfcatch.detail#" />
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({"success": false, "message": "Failed to save auditions."})#</cfoutput>
</cfcatch>
</cftry>
