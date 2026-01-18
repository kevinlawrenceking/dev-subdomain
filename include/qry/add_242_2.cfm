<cfset siteLinkUserService = createObject("component", "services.SiteLinkUserService")>

<cfset id = siteLinkUserService.INSsitelinks_user(
    new_sitename = new_sitename, 
    new_siteurl = new_siteurl, 
    userid = userid, 
    new_sitetypeid = new_sitetypeid, 
    ver = ver
)>