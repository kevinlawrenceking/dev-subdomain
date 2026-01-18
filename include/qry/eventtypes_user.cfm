<!--- This ColdFusion page retrieves event types for a specific user from the database. --->
<cfparam name="userid" default="0" />

<!--- Check if the session variable for userid is defined --->
<cfif isdefined('userid')>
    <cfset userid = userid />
</cfif>

<!--- Query to fetch event types associated with the user --->
<cfinclude template="/include/qry/eventtypes_user_473_1.cfm" />

