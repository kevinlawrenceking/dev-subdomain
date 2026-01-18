<cfset panelUserService = createObject("component", "services.PanelUserService")>
<cfset FIND = panelUserService.SELpgpanels_user_24435(
    userid = select_userid,
    pnFilename = m.pnFilename
)>