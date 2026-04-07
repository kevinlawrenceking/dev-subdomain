<!---
    P11 Step 7 Save: Completion
    Flips userstatus from Setup to Active, completing the wizard.
    Auth + CSRF handled by ajax/Application.cfc.
--->
<cfset userid = session.userid>

<cftry>

    <cfquery datasource="#application.datasource#">
        UPDATE taousers_tbl
        SET userstatus = 'Active',
            setup_step = 7,
            setup_completed_at = NOW()
        WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
    </cfquery>

    <!--- Update session to clear setup guard --->
    <cfset session.userstatus = "Active">
    <cfset session.setup_step = 7>
    <cfset session.bustUserCache = true>

    <cflog file="TAO_setup_wizard" type="information"
           text="User #userid# completed onboarding wizard." />

    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({
        "success": true,
        "message": "Welcome to The Actors Office!",
        "redirect": "/app/"
    })#</cfoutput>

<cfcatch type="any">
    <cflog file="TAO_setup_wizard" type="error"
           text="Step 7 (activation) failed for user #userid#: #cfcatch.message#" />
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({"success": false, "message": "Failed to activate account. Please try again."})#</cfoutput>
</cfcatch>
</cftry>
