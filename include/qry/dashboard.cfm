<!--- This ColdFusion page retrieves user-specific dashboard panels and counts active notifications for the user. --->

<cfinclude template="/include/qry/dashboards_458_1.cfm" />

<cfinclude template="/include/qry/notsActives_458_2.cfm" />

<cfif #notsActives.recordcount# IS "0">
    <!--- Set notification total to 0 if no active notifications are found --->
    <cfset nots_total = 0 />
<cfelse>
    <!--- Set notification total to the count of active notifications found --->
    <cfset nots_total = notsActives.nots_total />
</cfif>

