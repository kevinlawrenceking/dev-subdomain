<!--- This ColdFusion page handles parameter initialization and includes necessary query templates before redirecting the user to the account page. --->

<cfparam name="newpnids" default="" />

<!--- Include the first query template for processing data. --->
<cfinclude template="/include/qry/x_94_1.cfm" />

<!--- Include the second query template for pagination panels. --->
<cfinclude template="/include/qry/pgpanels_94_2.cfm" />

<!--- Redirect the user to the account page with a query parameter. --->
<cflocation url="/app/myaccount/?t1=1" />
