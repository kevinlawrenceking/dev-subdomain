<cfset systemService = createObject("component", "services.SystemService")>
<cfset sysAvail = systemService.SELfusystems_24762(
    new_systemscope = new_systemscope, 
    currentid = currentid, 
    userid = userid
)>