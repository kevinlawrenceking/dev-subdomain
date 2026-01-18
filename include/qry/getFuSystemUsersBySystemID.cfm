<cfset systemService = createObject("component", "services.SystemService") />
<cfset addDaysNo = systemService.getFuSystemUsersBySystemID(systemid=systemid, userid=userid) />