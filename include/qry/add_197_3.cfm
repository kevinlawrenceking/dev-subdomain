<cfset auditionSubmitSiteUserService = createObject("component", "services.AuditionSubmitSiteUserService")>
<cfset auditionSubmitSiteUserService.INSaudsubmitsites_user(
    new_submitsitename = new_submitsitename,
    sortedCatList = sortedCatList,
    userid = userid
)>