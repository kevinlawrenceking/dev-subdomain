<cfset siteTypeUserService = createObject("component", "services.SiteTypeUserService")>
<cfset Find = siteTypeUserService.SELsitetypes_user(sitetypeid=current_sitetypeid)>