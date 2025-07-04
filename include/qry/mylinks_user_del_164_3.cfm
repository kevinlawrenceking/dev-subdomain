<cfset myService = createObject("component", "services.SiteLinkUserService")>
<cfset mylinks_user_del = myService.SELsitelinks_user_23959(
    userId = userid,
    siteTypeId = sitetypes.sitetypeid
)>