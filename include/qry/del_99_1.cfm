<cfinclude template="/include/perfcount.cfm" />
<cfset mediaService = createObject("component", "services.AuditionMediaService")>
<cfset mediaService.UPDaudmedia(mediaid=mediaid)>