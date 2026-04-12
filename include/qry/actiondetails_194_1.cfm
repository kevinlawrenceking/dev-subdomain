<cfinclude template="/include/perfcount.cfm" />
<cfset systemService = createObject("component", "services.SystemService")>

<cfset actiondetails = systemService.DETfusystems_24029(id=id) />