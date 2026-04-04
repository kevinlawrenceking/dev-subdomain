<cfset ContactService = request.svc("ContactService")>
<cfset ContactService.updateContactUnique(contactid=contactid, uniquename=uniquename)>