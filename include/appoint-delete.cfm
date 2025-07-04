<!--- This ColdFusion page handles the inclusion of a query and redirects the user to the calendar appointment page. --->

<cfinclude template="/include/qry/delete_15_1.cfm" />

<!--- Redirecting the user to the calendar appointment page. --->
<cflocation url="/app/calendar-appoint/" />
