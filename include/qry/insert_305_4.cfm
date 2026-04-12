<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset contactItemService.UPDCONTACTITEMS_24349(
    itemid = findsame.itemid,
    new_currentStartDate = new_currentStartDate
)>