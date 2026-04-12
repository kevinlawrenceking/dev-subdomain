<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset Findemail = contactItemService.SELcontactitems_23964(contactID=myteam.contactid)>