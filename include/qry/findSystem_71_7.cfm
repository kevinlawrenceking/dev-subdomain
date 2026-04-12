<cfinclude template="/include/perfcount.cfm" />
<cfset systemService = createObject("component", "services.SystemService") />
<cfset findSystem = systemService.SELfusystems_23821(newsystemscope=newsystemscope) />