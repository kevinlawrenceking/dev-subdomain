<cfinclude template="/include/perfcount.cfm" />
<cfset panelUserService = createObject("component", "services.PanelUserService")>

<cfset dashboards = panelUserService.SELpgpanels_user_24640(userid=userid) />