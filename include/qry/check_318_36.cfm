<cfinclude template="/include/perfcount.cfm" />
<cfset itemCategoryXRefUserService = createObject("component", "services.ItemCategoryXRefUserService")>
<cfset check = itemCategoryXRefUserService.SELitemcatxref_user(
    select_userid = select_userid,
    new_typeid = new_typeid,
    new_catid = new_catid
)>