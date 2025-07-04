<cfset systemService = createObject("component", "services.SystemService")>
<cfset systemIds = "5,6,1,2,3,4">
<cfset mysystems = systemService.SELfusystems_24320(systemIds=systemIds)>