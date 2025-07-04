<!--- This ColdFusion page retrieves notes related to an event and specific contact details for a note. --->

<cfparam name="eventid" default="0" />
<cfparam name="updatenoteid" default="0" />

<!--- Query to retrieve notes related to the specified event --->
<cfinclude template="/include/qry/notesEvent_508_1.cfm" />

<!--- Query to retrieve contact details for a specific note --->
<cfinclude template="/include/qry/notesContactDetails_508_2.cfm" />

