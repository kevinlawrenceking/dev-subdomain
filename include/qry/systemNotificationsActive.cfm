<!--- This ColdFusion page retrieves user information based on the authenticated user's email. --->
<cfparam name="suID" default="7" />

<!--- Check if the session variable 'mocktoday' is defined to set the current start date. --->
<cfif isdefined('session.mocktoday')>
    <cfset currentStartDate = DateFormat(session.mocktoday, 'yyyy-mm-dd') />
<cfelse>
    <cfset currentStartDate = DateFormat(Now(), 'yyyy-mm-dd') />
</cfif>

<!--- Query to find user information based on the authenticated user's email. --->
<cfinclude template="/include/qry/FindUser_538_1.cfm" />

