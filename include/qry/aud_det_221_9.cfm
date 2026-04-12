<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset aud_det = auditionProjectService.SELaudprojects_24097(eventid=eventid)>