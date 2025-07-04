<cfset componentService = createObject("component", "services.ComponentService")>
<cfset menuItemsAU = componentService.SELpgcomps(
    menuYN="Y",
    compOwner="U",
    appid=3
)>