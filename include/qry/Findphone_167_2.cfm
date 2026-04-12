<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset Findphone = contactItemService.SELcontactitems_23963(contactID=myteam.contactid)>