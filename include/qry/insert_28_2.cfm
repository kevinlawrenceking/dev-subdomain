<cfset contactItemService = request.svc("ContactItemService")>
<cfset contactItemService.INScontactitems(new_contactid=new_contactid, cdtype=cdtype)>