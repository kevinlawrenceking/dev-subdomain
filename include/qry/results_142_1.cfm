<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset results = contactItemService.getContactDetails(uploadid=uploadid)>