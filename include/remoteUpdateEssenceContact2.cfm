<!--- This ColdFusion page handles parameter initialization and includes a query template before redirecting the user to their account page. --->
<cfparam name="IsDeleted" default="0" />

<!--- Include the query template for updates --->
<cfinclude template="/include/qry/update_264_1.cfm" />

<!--- Redirect the user to their account page with specific parameters --->
<cflocation url="/app/myaccount/?t3=1&tab3_expand=true" />
