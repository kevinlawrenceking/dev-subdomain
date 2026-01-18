<!--- This ColdFusion page includes a query and redirects the user to the myaccount page with specific parameters. --->
<cfinclude template="/include/qry/delete_102_1.cfm" />

<!--- Redirect the user to the myaccount page with query parameters. --->
<cflocation url="/app/myaccount/?t3=1&tab3_expand=true" />
