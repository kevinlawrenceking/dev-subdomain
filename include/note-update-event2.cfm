<!--- This ColdFusion page processes note information and redirects to a specified URL after cleaning the input. --->
<cfparam name="rcontactid" default="0" /> 
<cfparam name="reventid" default="0" /> 
<cfparam name="notetext" default="" /> 
<cfparam name="notedetailshtml" default="" />

<!--- Clean the note text by removing non-ASCII characters --->
<cfset new_notetext = notetext>

<!--- Include the update note query --->
<cfinclude template="/include/qry/updatenote_177_1.cfm" />

<!--- Include the clean query --->
<cfinclude template="/include/qry/CLEAN_169_2.cfm" />

<!--- Prepare the return URL with contact and event IDs --->
<cfoutput>
    <cfset returnurl = "/app/#returnurl#/?contactid=#rcontactid#&eventid=#reventid#&tab2_expand=true&t3=1" />
</cfoutput>

<!--- Redirect to the return URL --->
<cflocation url="#returnurl#">

