<cfset contactSSService = createObject("component", "services.ContactSSService")>
<cfset jsons = contactSSService.SELcontacts_ss(userId=userid)>