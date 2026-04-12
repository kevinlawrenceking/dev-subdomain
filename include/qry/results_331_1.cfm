<cfinclude template="/include/perfcount.cfm" />
<cfset updateLogService = createObject("component", "services.UpdateLogService")>
<cfset results = updateLogService.RESupdatelog(userId=session.userid)>