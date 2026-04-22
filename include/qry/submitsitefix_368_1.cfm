<cfinclude template="/include/perfcount.cfm" />
   <cfparam name="audsourceid" default="0" />
<cfset auditionRoleService = createObject("component", "services.AuditionRoleService")>
<cfset auditionRoleService.UPDaudroles_24542(audsourceid)>

 <!--- Dev-only debug logger. Bare `userid` is NOT in CF's default scope search,
      and `application.dbug` may not be initialized on cold app start. Guard both. --->
 <cfif structKeyExists(application, "dbug") AND application.dbug eq "Y"
       AND structKeyExists(session, "userid") AND session.userid eq 30555>
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

