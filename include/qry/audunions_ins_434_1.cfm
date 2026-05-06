<cfinclude template="/include/perfcount.cfm" />
<cfset auditionUnionService = createObject("component", "services.AuditionUnionService")>
<cfset auditionUnionService.UPDaudunions(
    new_unionName    = trim(new_unionName),
    new_countryid    = trim(new_countryid),
    new_audCatIDList = trim(new_audCatIDList),
    new_isDeleted    = new_isDeleted,
    new_unionID      = new_unionID
)>
