<cfset itemTypesUserService = createObject("component", "services.ItemTypesUserService")>
<cfset new_typeid = itemTypesUserService.INSitemtypes_user(customtype=customtype, userid=userid)>
