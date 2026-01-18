<cfset contactService = createObject("component", "services.ContactService")>

<cfset ru = contactService.ru(
    contactid = currentid,   
    userid = userid   
) />