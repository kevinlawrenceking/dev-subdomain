<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset fin_recordname = contactService.getContactRecordName(new_contactid)>