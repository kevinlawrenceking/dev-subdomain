<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset contactService.UPDcontactdetails_23816(uniquename="Y", contactid=contactid)>