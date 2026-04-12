<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset queryFullNames = contactService.SELcontactdetails_23906(searchTerm=arguments.searchTerm)>