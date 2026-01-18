<cfset panelUserService = createObject("component", "services.PanelUserService")>
<cfset panelUserService.INSpgpanels_user_24436(
    select_userid = select_userid,
    m = {
        pntitle = m.pntitle,
        pnfilename = m.pnfilename,
        pnOrderNo = m.pnOrderNo,
        pnColXl = m.pnColXl,
        pnColMd = m.pnColMd,
        pnDescription = m.pnDescription
    }
)>