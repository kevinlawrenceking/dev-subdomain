<cfset eventContactsService = createObject("component", "services.EventContactsXRefService")>
<cfset eventContactsService.DELeventcontactsxref(eventIds=[])>
<cflog text="Successfully executed remove event contacts." type="information">