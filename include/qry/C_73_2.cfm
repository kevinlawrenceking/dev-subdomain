<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset C = contactService.SELcontactdetails_23843(userid=userid, select_contactid=select_contactid)>