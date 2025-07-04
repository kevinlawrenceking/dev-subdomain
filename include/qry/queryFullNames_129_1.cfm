<cfset contactService = createObject("component", "services.ContactService")>
<cfset queryFullNames = contactService.SELcontactdetails_23906(searchTerm=arguments.searchTerm)>