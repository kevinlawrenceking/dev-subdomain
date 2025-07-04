<!--- This ColdFusion page includes a query and redirects to a version page based on the recid parameter. --->

<cfinclude template="/include/qry/update_322_1.cfm" />

<!--- Redirect to the version page with the specified recid. --->
<cflocation url="/app/version/?recid=#verid#" />
