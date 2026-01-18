<cfset componentPath = "/services/AuditionLocationService">
<cfset auditionLocationService = createObject("component", componentPath)>
<cfset auditionLocationService.UPDaudlocations(
    new_userid = new_userid,
    new_eventLocation = new_eventLocation,
    new_audlocadd1 = new_audlocadd1,
    new_audlocadd2 = new_audlocadd2,
    new_audcity = new_audcity,
    new_region_id = new_region_id,
    new_audzip = new_audzip,
    new_isDeleted = new_isDeleted,
    new_audlocid = new_audlocid
)>