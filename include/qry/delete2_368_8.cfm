<cfinclude template="/include/perfcount.cfm" />
<cfset eventContactsXRefService = createObject("component", "services.EventContactsXRefService")>
<cfset eventContactsXRefService.UPDeventcontactsxref_24549(deletecontactid=deletecontactid, audprojectid=audprojectid)>