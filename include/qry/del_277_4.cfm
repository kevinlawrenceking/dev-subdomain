<cfinclude template="/include/perfcount.cfm" />
<cfset contactAuditionService = createObject("component", "services.ContactAuditionService")>
<cfset contactAuditionService.DELaudcontacts_auditions_xref(audprojectid=audprojectid, old_contactid=old_contactid)>