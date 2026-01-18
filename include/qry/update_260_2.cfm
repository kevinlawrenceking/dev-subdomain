<cfset AuditionSubmitSiteUserService = createObject("component", "services.AuditionSubmitSiteUserService")>
<cfset AuditionSubmitSiteUserService.UPDaudsubmitsites_user_24167(
    submitsiteid = submitsiteid,
    new_submitsitename = new_submitsitename,
    isdeleted = isdeleted,
    catlist = sortedCatList
)>
