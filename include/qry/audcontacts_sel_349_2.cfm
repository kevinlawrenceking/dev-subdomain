<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset audcontacts_sel = contactService.SELcontactdetails_24515(userid=userid, audprojectid=audprojectid)>