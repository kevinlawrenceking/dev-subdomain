<cfset panelUserService = createObject("component", "services.PanelUserService") />

<cfset new_pnid = panelUserService.INSpgpanels_user(
    new_pnTitle = new_pnTitle,
    new_pnOrderNo = Findtotal.new_pnOrderNo,
    userid = userid
) />