<cfset siteTypeUserService = createObject("component", "services.SiteTypeUserService")>
<cfset new_sitetypeid = siteTypeUserService.INSsitetypes_user(new_siteTypeName=new_siteTypeName, userid=userid)>