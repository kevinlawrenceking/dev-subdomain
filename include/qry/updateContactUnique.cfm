<cfset ContactService = createObject("component", "services.ContactService")>
<cfset ContactService.updateContactUnique(contactid=contactid, uniquename=uniquename)>