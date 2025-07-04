<!--- This ColdFusion page handles the inclusion of a query and redirects the user to a calendar appointment page. --->

<cfinclude template="/include/qry/insert_564_1.cfm" /> 

<!--- Redirect the user to the calendar appointment page with a specific legend status. --->
<cflocation url="/app/calendar-appoint/?legendstatus=show" /> 
