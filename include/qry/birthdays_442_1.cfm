<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset birthdays = contactService.SELcontactdetails_24617(userId=userid)>