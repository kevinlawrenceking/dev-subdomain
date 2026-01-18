<cfset siteTypeUserService = createObject("component", "services.SiteTypeUserService")>
<cfset siteTypeUserService.INSsitetypes_user_24439(
    siteTypeName = x.sitetypename,
    siteTypeDescription = x.sitetypedescription,
    userId = users.userid
)>