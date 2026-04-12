<cfinclude template="/include/perfcount.cfm" />
<cfset auditionMediaService = createObject("component", "services.AuditionMediaService")>
<cfset audmedia = auditionMediaService.SELaudmedia_23799(eventid=eventid)>