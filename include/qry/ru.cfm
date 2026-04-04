<cfset contactService = request.svc("ContactService")>

<cfset ru = contactService.ru(
    contactid = currentid,   
    userid = userid   
) />