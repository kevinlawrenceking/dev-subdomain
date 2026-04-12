<cfinclude template="/include/perfcount.cfm" />
<cfset PanelUserService = createObject("component", "services.PanelUserService")>
<cfset PanelUserService.pgPanelsFix() />