<cfinclude template="/include/perfcount.cfm" />
<cfset ContactService = request.svc("ContactService")>
<cfset xx =  ContactService.SELcontactdetails_23806(contactid=contactid)>