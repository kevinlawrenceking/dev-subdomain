<cfinclude template="/include/perfcount.cfm" />
<cfset auditionMediaTypeService = createObject("component", "services.AuditionMediaTypeService")>
<cfset Type = auditionMediaTypeService.SELaudmediatypes_24067(src=src)>