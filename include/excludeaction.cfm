<!--- This ColdFusion page includes a query template and redirects the user to the myaccount page with specific parameters. --->
<cfinclude template="/include/qry/updateActionUsersByExcludeAction.cfm" />

<!--- Redirect to the myaccount page with target_id_system parameter --->
<cflocation url="/app/myaccount/?t7=1&target_id_system=#target_id_system#" />
