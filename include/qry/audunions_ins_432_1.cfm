<cfinclude template="/include/perfcount.cfm" />
<cfset auditionUnionService = createObject("component", "services.AuditionUnionService")>
<cfset new_unionID = auditionUnionService.INSaudunions(
    new_unionName    = new_unionName,
    new_countryid    = new_countryid,
    new_audCatIDList = new_audCatIDList,
    new_isDeleted    = new_isDeleted
)>
