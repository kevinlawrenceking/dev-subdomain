<cfset contactItemService = request.svc("ContactItemService")>

<cfset new_systemscope = contactItemService.SELfindscope_24712(
    contactid = contactid,        
    userid = userid         
) />