<!--- This ColdFusion page handles the inclusion of query templates and redirects to a specified URL after processing. --->

<cfinclude template="/include/qry/insert_41_1.cfm" />

<cfinclude template="/include/qry/x_41_2.cfm" />

<!--- Loop through the query results from 'x' to include additional processing. --->
<cfloop query="x">
    <cfinclude template="/include/qry/insert_41_3.cfm" />
</cfloop>

<!--- Set the return URL for redirection after processing. --->
<cfoutput>
    <cfset returnurl="/app/audition/?audprojectid=#audprojectid#&secid=179" />
</cfoutput>

<!--- Redirect to the specified return URL. --->
<cflocation url="#returnurl#">
