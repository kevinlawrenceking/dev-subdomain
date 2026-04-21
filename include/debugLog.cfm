


<!--- Dev-only query logger. Three guards below are all required:
     - application.dbug flag (may not be initialized on cold app start)
     - session.userid (bare `userid` is NOT in CF's default scope search;
       modal/iframe loads like /include/roleupdateform.cfm never set variables.userid)
     - caller contract: every caller sets `current_queryResult`, NOT `result`. --->
<cfif structKeyExists(application, "dbug") AND application.dbug eq "Y"
      AND structKeyExists(session, "userid") AND session.userid eq 30>
    <cfset debugService = createObject("component", "services.DebugService")>
    <cfset debugDetails = {
        arguments = arguments,
        queryResult = structKeyExists(variables, "current_queryResult") ? variables.current_queryResult : ""
    }>
    <cfset debugService.insertDebugLog(
        filename = cgi.script_name,
        debugDetails = serializeJSON(debugDetails)
    )>
</cfif>
