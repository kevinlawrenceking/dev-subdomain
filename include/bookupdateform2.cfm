<!--- This ColdFusion page processes audition location data and redirects the user to a specific URL based on parameters. --->

<cfinclude template="/include/qry/audlocations_ins_58_1.cfm" /> 

<!--- Set the return URL based on audition project, event, section, and focus IDs. --->
<cfoutput>
    <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&eventid=#eventid#&secid=181&focusid=#focusid#" />
</cfoutput>

<!--- Redirect the user to the constructed return URL. --->
<cflocation url="#returnurl#" />
