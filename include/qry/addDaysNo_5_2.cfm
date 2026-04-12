<cfinclude template="/include/perfcount.cfm" />
<cfset systemService = createObject("component", "services.SystemService")>
<cfset addDaysNo = systemService.SELfusystems(
    new_systemid = new_systemid,
    userid = userid
)>