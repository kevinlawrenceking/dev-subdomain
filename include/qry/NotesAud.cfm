<!--- This ColdFusion page retrieves notes and contact details based on project and note IDs. --->

<cfparam name="audprojectid" default="0" />
<cfparam name="updatenoteid" default="0" />

<!--- Query to fetch notes related to the specified project ID --->
<cfinclude template="/include/qry/notesaud_506_1.cfm" />

<!--- Query to fetch contact details for a specific note ID --->
<cfinclude template="/include/qry/notesContactDetails_506_2.cfm" />

