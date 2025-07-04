<cfset siteLinkService = createObject("component", "services.SiteLinkUserService")>
<cfset mylinks_user = siteLinkService.SELsitelinks_user_23958(
    userId = userid,
    siteTypeId = sitetypes.sitetypeid
)>