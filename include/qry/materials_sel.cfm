<cfset auditionMediaService = createObject("component", "services.AuditionMediaService")>
<cfset materials_sel = auditionMediaService.GetMaterials(userid=userid)>