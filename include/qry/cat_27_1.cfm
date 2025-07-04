<cfset auditionCategoryService = createObject("component", "services.AuditionCategoryService")>
<cfset cat = auditionCategoryService.SELaudcategories(new_audsubcatid=new_audsubcatid)>