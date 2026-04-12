<cfinclude template="/include/perfcount.cfm" />
<cfset auditionMediaService = createObject("component", "services.AuditionMediaService")>
<cfset headshots = auditionMediaService.SELaudmedia_24573(audprojectid=audprojectid)>