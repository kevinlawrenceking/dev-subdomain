<cfinclude template="/include/perfcount.cfm" />
<cfset auditionCategoryService = createObject("component", "services.AuditionCategoryService")>
<cfset getCategories = auditionCategoryService.SELaudcategories_24033()>