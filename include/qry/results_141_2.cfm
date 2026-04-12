<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset results = contactItemService.REScontactitems(userid=userid, uploadid=uploadid)>