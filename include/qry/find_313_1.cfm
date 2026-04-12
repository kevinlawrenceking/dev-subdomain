<cfinclude template="/include/perfcount.cfm" />
<cfset auditionCategoryService = createObject("component", "services.AuditionCategoryService")>
<cfset find = auditionCategoryService.SELaudcategories_24375(audsubcatid=form.audsubcatid)>