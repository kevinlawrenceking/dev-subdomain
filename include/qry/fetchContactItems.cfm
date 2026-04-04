<!--- This ColdFusion page fetches active and inactive contact items from the ContactItems service. --->
<cfset contactItemsService = request.svc("ContactItemService")>

<!--- Fetch active contact items --->
<cfset activeCategories = contactItemsService.getActiveCategories()>

<!--- Fetch inactive contact items --->
<cfset inactiveCategories = contactItemsService.getInactiveCategories()>
