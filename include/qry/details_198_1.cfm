<cfinclude template="/include/perfcount.cfm" />
<cfset itemCategoryService = createObject("component", "services.ItemCategoryService")>
<cfset details = itemCategoryService.DETitemcategory(catid=new_catid)>