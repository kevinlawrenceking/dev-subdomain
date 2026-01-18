<!--- This ColdFusion page includes a query template and redirects the user to their account page. --->

<cfinclude template="/include/qry/update_151_1.cfm" />

<!--- Redirect to the account page with parameters. --->
<cflocation url="/app/myaccount/?t1=1&target_id=#target_id#" /> 
