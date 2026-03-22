<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = createObject("component", "services.ContactService")>
<cfset relationships = contactService.SELcontactdetails_23722(userId=userid)>