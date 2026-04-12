<cfinclude template="/include/perfcount.cfm" />
<cfset objPanelsUserXRefService = createObject("component", "services.PanelsUserXRefService")>
<cfset objPanelsUserXRefService.INSpgpanels_user_xref(newpnid=newpnid, newuserid=newuserid)>