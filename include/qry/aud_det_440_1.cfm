<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset aud_det = auditionProjectService.SELaudprojects_24500(eventid=eventid)>