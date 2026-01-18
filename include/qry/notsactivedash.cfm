<!--- This ColdFusion page retrieves reminders and notifications for a specific user based on their status and start date. --->

<Cfset currentStartDate="#DateFormat(Now(),'yyyy-mm-dd')#" />

<!--- Query to count total reminders for the user --->
<cfinclude template="/include/qry/reminders_511_1.cfm" />

<!--- Query to retrieve active notifications for the user --->
<cfinclude template="/include/qry/notsActive_511_2.cfm" />

<!--- Query to count total active notifications for the user --->
<cfinclude template="/include/qry/notsActives_511_3.cfm" />

<!--- Check if there are any active notifications and set total accordingly --->
<cfif #notsactives.recordcount# is "0">
    <cfset nots_total = 0 />
<cfelse>
    <cfset nots_total = notsActives.nots_total />
</cfif>

