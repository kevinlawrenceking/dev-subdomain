<cfset contactService = request.svc("ContactService")>
<cfset BatchDetails = contactService.DETcontactdetails_24340(idList=idlist)>

<cfoutput><cfdump var="#BatchDetails#"></cfoutput>