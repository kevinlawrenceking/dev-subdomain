<cfset ageRangeService = createObject("component", "services.AuditionAgeRangeService")>
<cfset new_rangeid = ageRangeService.INSaudageranges(
    new_rangename = trim(new_rangename),
    new_age_min = new_age_min,
    new_age_max = new_age_max,
    new_age_group = trim(new_age_group),
    new_isDeleted = new_isDeleted
)>