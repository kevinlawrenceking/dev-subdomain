<!--- This ColdFusion page retrieves notes for a specific contact and details for a specific note update. --->

<cfparam name="contactid" default="1" />
<cfparam name="updatenoteid" default="0" />

<!--- Query to fetch notes associated with a contact --->
<cfinclude template="/include/qry/notesContact_507_1.cfm" />

<!--- Query to fetch details of a specific note update --->
<cfinclude template="/include/qry/notesContactDetails_507_2.cfm" />

