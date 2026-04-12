<cfinclude template="/include/perfcount.cfm" />
<cfset eventContactsXRefService = createObject("component", "services.EventContactsXRefService")>
<cfset eventContactsXRefService.INSeventcontactsxref_24532(new_eventid=new_eventid, new_contactid=new_contactid)>