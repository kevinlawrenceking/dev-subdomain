<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset contactItemService.INScontactitems_24050(contactID=CONTACTID, workEmail=workemail)>