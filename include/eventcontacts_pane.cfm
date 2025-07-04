<!--- This ColdFusion page sets up the contacts table and includes the attendees template for the event. --->
<cfset contacts_table = "contacts_attendees" />

<cfoutput>
    <cfset eventid = "#eventdetails.eventid#" />
</cfoutput>

<!--- Include the contacts table attendees template --->
<cfinclude template="/include/contacts_table_attendees.cfm" />
