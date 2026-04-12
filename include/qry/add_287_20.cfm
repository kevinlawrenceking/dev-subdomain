<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset contactService.INScontactdetails_24294(userid=userid, contactfullname=contactfullname)>