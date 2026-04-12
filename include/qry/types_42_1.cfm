<cfinclude template="/include/perfcount.cfm" />
<cfset auditionMediaTypeService = createObject("component", "services.AuditionMediaTypeService")>
<cfset types = auditionMediaTypeService.SEL_Media_types_material()>
