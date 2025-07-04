<cfset itemTypesUserService = createObject("component", "services.ItemTypesUserService")>
<cfset find = itemTypesUserService.SELitemtypes_user_24466(
    valuetype = x.valuetype,
    userid = select_userid
)>