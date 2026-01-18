<cfset itemTypeService = createObject("component", "services.ItemTypeService")>
<cfset types = itemTypeService.SELitemtypes(catId=4, excludeTypeId=1000)>