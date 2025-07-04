<cfset contactService = createObject("component", "services.ContactService")>
<cfset audcontacts_sel = contactService.SELcontactdetails_24515(userid=userid, audprojectid=audprojectid)>