<!--- This ColdFusion page retrieves event details for a specific user from the database. --->
<cfparam name="userid" default="0" />

<!--- Check if the session variable 'userid' is defined --->
<cfif #isdefined('userid')#>
    <cfset userid = userid />
</cfif>

<!--- Query to fetch event results for the logged-in user --->
<cfinclude template="/include/qry/eventresults_471_1.cfm" />

