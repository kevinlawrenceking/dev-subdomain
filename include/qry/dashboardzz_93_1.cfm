<cfinclude template="/include/perfcount.cfm" />
<cfset panelUserService = createObject("component", "services.PanelUserService")>
<cfset dashboardzz = panelUserService.SELpgpanels_user(userid=userid)>