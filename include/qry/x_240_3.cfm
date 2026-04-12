<cfinclude template="/include/perfcount.cfm" />
<cfset panelService = createObject("component", "services.PanelUserService")>
<cfset x = panelService.SELpgpanels_user_24136(userId=userId)>