<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset results = contactService.REScontactdetails(userId=userid)>