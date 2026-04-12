<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset itemsAll = contactItemService.SELcontactitems_24672(currentid=currentid, catArea_UCB=catArea_UCB)>