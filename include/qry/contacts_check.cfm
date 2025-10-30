<cfparam name="devicetype" default="desktop" />

<!--- This ColdFusion page includes different contact queries based on the device type (mobile or desktop) --->
<cfif #devicetype# is "mobile">
    <!--- Include the query for all contacts for mobile devices --->
    <cfset qContactsall = application.services.ContactsService.listAllContacts({})>
<cfelse>
    <!--- Include the query for contacts for non-mobile devices --->
    <cfset qContacts = application.services.ContactsService.listContacts({})>
</cfif>

