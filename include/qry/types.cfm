<cfset itemTypeService = createObject("component", "services.itemTypeService")>
<cfset typesResult = itemTypeService.getValueTypesByCategory(catid=new_catid, userid=userid)>

