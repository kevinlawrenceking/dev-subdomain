<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset checkUnique = contactService.SELcontactdetails_23939(addDaysNoUniqueName=adddaysno.uniquename, contactId=contactid)>