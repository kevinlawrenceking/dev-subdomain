<!--- This ColdFusion page includes an update query and redirects the user to their account page after the update. --->

<cfinclude template="/include/qry/update_145_1.cfm" />

<!--- Redirect the user to their account page with specific parameters. --->
<cflocation url="/app/myaccount/?t7=1&target_id_system=#target_id_system#" />
