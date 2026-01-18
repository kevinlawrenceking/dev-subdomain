<cfset siteTypeUserService = createObject("component", "services.SiteTypeUserService")>
<cfset find = siteTypeUserService.SELsitetypes_user_24438(
    sitetypename = x.sitetypename,
    userid = select_userid
)>