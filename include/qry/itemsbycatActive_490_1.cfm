<cfset contactItemService = createObject("component", "services.ContactItemService")>
<cfset itemsbycatActive = contactItemService.SELcontactitems_24673(
    currentid = currentid,
    activeCategoriesValueCategory = ActiveCategories.valueCategory,
    catArea_UCB = catArea_UCB
)>