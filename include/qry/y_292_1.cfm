<cfinclude template="/include/perfcount.cfm" />
<cfset informationSchemaService = createObject("component", "services.InformationSchemaTableService")>
<cfset y = informationSchemaService.SELinformation_schema.tables(tableNamePattern="aud%")>