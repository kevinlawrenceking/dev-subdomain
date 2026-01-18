<cfset eventContactsService = createObject("component", "services.EventContactsXRefService")>
<cfset result = eventContactsService.deleteEventContactsXref(audStepId=5)>