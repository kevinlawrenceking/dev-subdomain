<cfinclude template="/include/perfcount.cfm" />
<cfset filteredQueryService = createObject("component", "services.FilteredQueryService")>
<cfset qCount = filteredQueryService.SELqFiltered(sIndexColumn=sIndexColumn)>