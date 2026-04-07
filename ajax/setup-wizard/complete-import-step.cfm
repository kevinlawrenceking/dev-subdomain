<!---
    P11: Complete Import Step
    Called after import modal closes to advance setup_step.
    Used by Steps 3 and 4 when the import (not manual) path is taken.
    Auth + CSRF handled by ajax/Application.cfc.
--->
<cfset userid = session.userid>
<cfparam name="form.step" default="3" />
<cfset stepNum = val(form.step)>

<!--- Only allow steps 3 or 4 --->
<cfif stepNum NEQ 3 AND stepNum NEQ 4>
    <cfset stepNum = 3>
</cfif>

<cfquery datasource="#application.datasource#">
    UPDATE taousers_tbl SET setup_step = <cfqueryparam value="#stepNum#" cfsqltype="cf_sql_tinyint" />
    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
</cfquery>

<cfset session.setup_step = stepNum>

<cfcontent type="application/json; charset=utf-8" reset="true">
<cfoutput>#serializeJSON({"success": true})#</cfoutput>
