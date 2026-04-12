<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset refers = contactService.SELcontactdetails_24069(userid=userid)>