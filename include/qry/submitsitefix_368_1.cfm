   <cfparam name="audsourceid" default="0" />
<cfset componentPath = "/services/AuditionRoleService">
<cfset auditionRoleService = createObject("component", componentPath)>
<cfset auditionRoleService.UPDaudroles_24542(audsourceid)>

 <cfif application.dbug eq "Y" and userid eq 30555>
    <cfset debugService = createObject("component", "services.DebugService")>
    <cfset debugDetails = {
        functionName = "UPDaudroles_24542",
        arguments = arguments,
        rowsAffected = result.recordCount
    }>
    <cfset debugService.insertDebugLog(
        filename = "AuditionRoleService.cfc",
        debugDetails = serializeJSON(debugDetails)
    )>
    </cfif>

