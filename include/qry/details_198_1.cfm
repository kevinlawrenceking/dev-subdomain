<cfset itemCategoryService = createObject("component", "services.ItemCategoryService")>
<cfset details = itemCategoryService.DETitemcategory(catid=new_catid)>