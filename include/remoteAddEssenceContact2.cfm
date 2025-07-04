<!--- This ColdFusion page includes a query template and redirects the user to the myaccount page with specific parameters. --->

<cfinclude template="/include/qry/add_sitetype_205_1.cfm" />

<!--- Redirects the user to the myaccount page with query parameters. --->
<cflocation url="/app/myaccount/?t3=1&tab3_expand=true" /> 
