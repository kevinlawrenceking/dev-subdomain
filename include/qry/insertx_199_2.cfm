<cfset itemCategoryXRefUserService = createObject("component", "services.ItemCategoryXRefUserService")>
<cfset itemCategoryXRefUserService.INSitemcatxref_user(
    new_typeid = new_typeid,
    catid = catid,
    userid = userid
)>