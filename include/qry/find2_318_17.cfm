<cfset siteLinkUserService = createObject("component", "services.SiteLinkUserService")>
<cfset find2 = siteLinkUserService.SELsitelinks_user_24448(
    sitename = x.sitename,
    userid = users.userid
)>