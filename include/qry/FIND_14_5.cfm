<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset FIND = contactService.SELcontactdetails_23727(userid=userid, relationship=relationship)>