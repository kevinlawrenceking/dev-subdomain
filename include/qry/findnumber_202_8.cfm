<cfinclude template="/include/perfcount.cfm" />
<cfset eventContactsXRefService = createObject("component", "services.EventContactsXRefService") />
<cfset findnumber = eventContactsXRefService.SELeventcontactsxref_24060(eventNumber=eventNumber, contactID=CONTACTID) />