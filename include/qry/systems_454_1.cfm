<cfinclude template="/include/perfcount.cfm" />
<cfset systemsService = createObject("component", "services.FUSystemTypeService")>
<cfset systems = systemsService.SELfusystemtypes()>