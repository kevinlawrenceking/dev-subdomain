


<cfif application.dbug eq "Y" and userid eq 30>
    <cfset debugService = createObject("component", "services.DebugService")>
    <cfset debugDetails = {
        arguments = arguments,
        queryResult = result
    }>
    <cfset debugService.insertDebugLog(
        filename = cgi.script_name,
        debugDetails = serializeJSON(debugDetails)
    )>
</cfif>
