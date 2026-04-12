<cfinclude template="/include/perfcount.cfm" />
<cfset auditionCategoryService = createObject("component", "services.AuditionCategoryService")>
<cfset find_cat = auditionCategoryService.SELaudcategories_24368(audcatname=x.audcatname)>