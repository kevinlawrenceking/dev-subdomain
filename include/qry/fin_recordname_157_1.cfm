<cfset contactService = createObject("component", "services.ContactService")>
<cfset fin_recordname = contactService.getContactRecordName(new_contactid)>