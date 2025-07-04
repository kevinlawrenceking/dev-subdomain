<cfset objService = createObject("component", "services.AuditionAgeRangeService")>
<cfset objService.UPDaudageranges(
    new_rangename = new_rangename,
    new_age_min = new_age_min,
    new_age_max = new_age_max,
    new_age_group = new_age_group,
    new_isDeleted = new_isDeleted,
    new_rangeid = new_rangeid
)>