<cfinclude template="/include/perfcount.cfm" />
<cfset auditionMediaService = createObject("component", "services.AuditionMediaService")>
<cfset materials_sel = auditionMediaService.GetMaterials(userid=userid)>