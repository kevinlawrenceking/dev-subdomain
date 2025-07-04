<cfset componentPath = "/services/AuditionRoleService">
<cfset auditionRoleService = createObject("component", componentPath)>
<cfset auditionRoleService.UPDaudroles_23810(
    new_audroleid = new_audroleid,
    new_incometypeid = new_incometypeid,
    new_payrate = new_payrate,
    new_netincome = new_netincome,
    new_buyout = new_buyout,
    new_paycycleid = new_paycycleid
)>
