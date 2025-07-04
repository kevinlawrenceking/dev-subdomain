<!--- This ColdFusion page processes queries and includes various templates for data handling and redirection. --->

<cfinclude template="/include/qry/removenotdups.cfm" />

<cfinclude template="/include/qry/restoreActionUsers.cfm" />

<!--- Redirect to the specified URL with parameters. --->
<cflocation url="/app/myaccount/?t7=1&target_id_system=#target_id_system#" />

