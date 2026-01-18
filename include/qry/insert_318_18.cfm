<cfset siteLinkService = createObject("component", "services.SiteLinkUserService")>
<cfset siteLinkService.INSsitelinks_user_24449(
    sitename = x.sitename,
    siteurl = x.siteurl,
    siteicon = x.siteicon,
    sitetypeid = new_sitetypeid,
    userid = users.userid
)>