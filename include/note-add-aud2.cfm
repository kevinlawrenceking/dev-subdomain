<!--- This ColdFusion page processes note text and redirects to a specified URL after including necessary templates. --->

<cfparam name="rcontactid" default="0" /> 
<cfparam name="reventid" default="0" /> 
<cfparam name="TEXT" default="" /> 

<!--- Clean the note text by removing non-ASCII characters --->
<cfset new_notetext = notetext >

<!--- Include the first template for inserting a note --->
<cfinclude template="/include/qry/InsertNote_169_1.cfm" />

<!--- Include the second template for cleaning data --->
<cfinclude template="/include/qry/CLEAN_169_2.cfm" />

<!--- Prepare the return URL with parameters --->
<cfoutput>
    <cfset returnurl = "/app/#returnurl#/?contactid=#rcontactid#&audprojectid=#audprojectid#&secid=178" />
</cfoutput>

<!--- Redirect to the constructed return URL --->
<cflocation url="#returnurl#">
