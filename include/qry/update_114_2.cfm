<cfset siteTypeUserService = createObject("component", "services.SiteTypeUserService")>
<cfset siteTypeUserService.UPDsitetypes_user(sitetypeid=current_sitetypeid)>