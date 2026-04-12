<cfinclude template="/include/perfcount.cfm" />
<cfset itemTypeService = createObject("component", "services.itemTypeService")>
<cfset types = itemTypeService.SELitemTypesByCategory_4()>