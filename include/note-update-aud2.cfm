<!--- This ColdFusion page processes note updates and redirects to a specified URL based on parameters. --->

<cfparam name="rcontactid" default="0" /> 
<cfparam name="notetext" default="" /> 
<cfparam name="notedetailshtml" default="" />

<!--- Clean the note text by removing non-ASCII characters --->
<cfset new_notetext = notetext >

<!--- Include the update note query template --->
<cfinclude template="/include/qry/updatenote_175_1.cfm" />

<!--- Include the clean query template --->
<cfinclude template="/include/qry/CLEAN_169_2.cfm" />

<!--- Prepare the return URL for redirection --->
<cfoutput>
    <cfset returnurl = "/app/#returnurl#/?audprojectid=#audprojectid#&contactid=#rcontactid#&secid=178" />
</cfoutput>

<!--- Redirect to the return URL --->
<cflocation url="#returnurl#" />

