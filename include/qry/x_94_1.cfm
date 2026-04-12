<cfinclude template="/include/perfcount.cfm" />
<cfset panelUserService = createObject("component", "services.PanelUserService")>
<cfset panelUserService.UPDpgpanels_user(userid=userid)>