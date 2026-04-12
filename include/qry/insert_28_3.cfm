<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset contactItemService.INScontactitems_23771(new_contactid=new_contactid, cdco=cdco)>