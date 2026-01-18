<!--- This ColdFusion page retrieves notes and contact details for a specific user and contact. --->

<cfparam name="contactid" default="1" />
<cfparam name="updatenoteid" default="0" />

<!--- Query to retrieve notes related to the specified contact and user. --->
<cfinclude template="/include/qry/notesRelationship_509_1.cfm" />

<!--- Query to retrieve details of a specific note based on the note ID. --->
<cfinclude template="/include/qry/notesContactDetails_509_2.cfm" />

