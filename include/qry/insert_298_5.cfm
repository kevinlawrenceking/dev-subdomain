<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset contactItemService.INScontactitems_24327(contactID=CONTACTID, newValueText=left(new_valuetext, 40))>