<cfset contactItemService = createObject("component", "services.contactItemService")>

<!--- Call the function and pass necessary arguments --->
<cfset result = contactItemService.itemsByCatActive(
    contactid = currentid,
    valueCategory = ActiveCategories.valueCategory,
    catArea_UCB = catArea_UCB
)>