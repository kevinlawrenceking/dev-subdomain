<cfset eventContactsService = createObject("component", "services.EventContactsXRefService")>
<cfset eventContactsService.INSeventcontactsxref(new_eventid=new_eventid, new_contactid=new_contactid)>