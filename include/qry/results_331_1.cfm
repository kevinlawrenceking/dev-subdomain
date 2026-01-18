<cfset updateLogService = createObject("component", "services.UpdateLogService")>
<cfset results = updateLogService.RESupdatelog(userId=FindUser.Userid)>