<cfinclude template="/include/perfcount.cfm" />
<cfset panelsMasterService = createObject("component", "services.PanelsMasterService")>
<cfset m = panelsMasterService.SELpgpanels_master()>