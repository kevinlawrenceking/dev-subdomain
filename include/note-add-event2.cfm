<!--- This ColdFusion page processes note text and redirects to a specified URL after including necessary templates. --->

<cfparam name="rcontactid" default="0" /> 
<cfparam name="reventid" default="0" /> 
<cfparam name="TEXT" default="" /> 

<!--- Clean the note text by removing non-ASCII characters --->
<cfset new_notetext = notetext />

<!--- Include the first query template for inserting a note --->
<cfinclude template="/include/qry/InsertNote_171_1.cfm" />

<!--- Include the second query template for cleaning up --->
<cfinclude template="/include/qry/CLEAN_169_2.cfm" />

<!--- Prepare the return URL with contact and event IDs --->
<cfoutput>
    <cfset returnurl = "/app/#returnurl#/?contactid=#rcontactid#&eventid=#reventid#&tab2_expand=true&t3=1" />
</cfoutput>

<!--- Redirect to the constructed return URL --->
<cflocation url="#returnurl#" />

