<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset relationships = contactService.SELcontactdetails_23722(userId=userid)>