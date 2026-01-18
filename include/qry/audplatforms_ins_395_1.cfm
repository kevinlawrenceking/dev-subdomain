<cfset auditionPlatformsService = createObject("component", "services.AuditionPlatformsService")>
<cfset auditionPlatformsService.UPDaudplatforms(
    new_audplatform = new_audplatform,
    new_isDeleted = new_isDeleted,
    new_audplatformid = new_audplatformid
)>