   <cfparam name="audsourceid" default="0" />
<cfset auditionRoleService = createObject("component", "services.AuditionRoleService")>
<cfset auditionRoleService.UPDaudroles_24542(audsourceid)>

 <cfif application.dbug eq "Y" and userid eq 30555>
    <cfset debugService = createObject("component", "services.DebugService")>
    <cfset debugDetails = {
        functionName = "UPDaudroles_24542",
        audsourceid = audsourceid,
        timestamp = now()
    }>
    <cfset debugService.insertDebugLog(
        filename = "submitsitefix_368_1.cfm",
        debugDetails = serializeJSON(debugDetails)
    )>
    </cfif>

