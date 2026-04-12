<cfinclude template="/include/perfcount.cfm" />
<cfset panelService = createObject("component", "services.PanelService")>
<cfset pgpanels = panelService.SELpgpanels(newpnids=newpnids)>