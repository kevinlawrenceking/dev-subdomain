<cfinclude template="/include/perfcount.cfm" />
<cfset auditionCategoryService = createObject("component", "services.AuditionCategoryService") />
<cfset categories = auditionCategoryService.SELaudcategories_24735(isDeleted=false) />