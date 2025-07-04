<cfset auditionUnionService = createObject("component", "services.AuditionUnionService")>
<cfset auditionUnionService.UPDaudunions(
    new_unionName = trim(new_unionName),
    new_countryid = trim(new_countryid),
    new_audCatID = new_audCatID,
    new_isDeleted = new_isDeleted,
    new_unionID = new_unionID
)>