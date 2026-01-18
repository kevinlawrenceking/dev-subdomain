<cfset systemService = createObject("component", "services.SystemService")>
<cfset FindSystem = systemService.SELfusystems_24317(
    systemtype = new_systemtype, 
    systemscope = new_systemscope
)>