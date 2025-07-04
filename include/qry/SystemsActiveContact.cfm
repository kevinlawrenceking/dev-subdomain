<!--- This ColdFusion page retrieves user information, checks for a specific contact item, and determines the system scope based on the user's tags. --->

<cfinclude template="/include/qry/FindUser_539_1.cfm" />

<cfinclude template="/include/qry/findscope_539_2.cfm" />

<cfif findscope.recordcount is "1">
    <!--- Set the system scope to "Casting Director" if the record count is 1 --->
    <cfset new_systemscope = "Casting Director" />
<cfelse>
    <!--- Otherwise, set the system scope to "Industry" --->
    <cfset new_systemscope = "Industry" />
</cfif>

<cfinclude template="/include/qry/sysAvail_539_3.cfm" />

