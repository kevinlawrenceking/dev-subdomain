<cfset objService = createObject("component", "services.AuditionSubmitSiteUserService")>
<cfset objService.INSaudsubmitsites_user_24297(
    new_submitsitename=trim(new_submitsitename),
    userid=userid,
    new_catid=new_catid
)>