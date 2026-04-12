<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset updates = contactService.SELcontactdetails_24674(userId=1, compId=1)>