<cfset itemTypesService = createObject("component", "services.ItemTypesUserService")>
<cfset find = itemTypesService.SELitemtypes_user(valuetype=x.valuetype, userid=users.userid)>