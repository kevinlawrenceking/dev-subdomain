<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset findcd = contactService.SELcontactdetails_24364(cdfullname=cdfullname, userid=userid)>