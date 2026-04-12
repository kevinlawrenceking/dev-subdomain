<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset contactItemService.INScontactitems_24057(contactID=CONTACTID, company=Company) />