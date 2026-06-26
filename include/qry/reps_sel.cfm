<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset reps = auditionProjectService.SELauditionReps(userid=userid)>
