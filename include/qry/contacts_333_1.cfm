<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService") />
<cfset contacts = contactService.SELcontactdetails_24483(userid=userid) />