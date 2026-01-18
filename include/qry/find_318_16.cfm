<cfset siteTypeUserService = createObject("component", "services.SiteTypeUserService")>
<cfset find = siteTypeUserService.SELsitetypes_user_24447(
    sitetypename = x.sitetypename,
    userid = users.userid
)>