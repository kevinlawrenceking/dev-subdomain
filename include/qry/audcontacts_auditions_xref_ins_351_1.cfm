<cfset contactAuditionService = createObject("component", "services.ContactAuditionService") />
<cfset contactAuditionService.UPDaudcontacts_auditions_xref(
    new_contactid = new_contactid,
    new_audprojectid = new_eventid
) />