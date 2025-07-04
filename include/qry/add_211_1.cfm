<cfset contactService = createObject("component", "services.ContactService")>

<cfset params = {
    userid = userid,
    contactFullName = contactFullName,
    contactMeetingLoc = contactmeetingloc,
    contactPronoun = contactPronoun
}>

<!--- Only add the date fields and referContactId if they are not blank --->
<cfif len(trim(contactbirthday))>
    <cfset params["contactBirthday"] = contactbirthday>
</cfif>

<cfif isNumeric(refer_contact_id)>
    <cfset params["referContactId"] = refer_contact_id>
</cfif>

<cfif len(trim(contactmeetingdate))>
    <cfset params["contactMeetingDate"] = contactmeetingdate>
</cfif>

<cfset currentid = contactService.INScontactdetails_24070(argumentCollection=params)>