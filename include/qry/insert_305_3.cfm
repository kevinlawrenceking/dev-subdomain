<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset contactItemService.INScontactitems_24348(
    new_contactid = new_contactid,
    new_tagname = new_tagname
)>