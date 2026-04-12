<cfinclude template="/include/perfcount.cfm" />
<cfset allFieldsService = createObject("component", "services.AllFieldsService")>
<cfset x = allFieldsService.getFilteredAllFields("pri", "auto_increment")>