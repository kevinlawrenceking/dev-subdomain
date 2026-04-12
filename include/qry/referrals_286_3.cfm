<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset referrals = contactService.SELcontactdetails_24263(userid=userid)>