<cfinclude template="/include/perfcount.cfm" />
<cfset contactAuditionService = createObject("component", "services.ContactAuditionService")>
<cfset contactAuditionService.INSaudcontacts_auditions_xref_24551(
    audprojectid = cdcheck.audprojectid,
    contactid = cdcheck.contactid
)>