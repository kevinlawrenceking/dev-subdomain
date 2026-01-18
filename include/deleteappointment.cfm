<!--- This ColdFusion page includes a query for deleting a ticket and redirects to the contact page with parameters. --->

<cfinclude template="/include/qry/deleteticket_100_1.cfm" />

<!--- Redirect to the contact page with the current contact ID and additional parameters. --->
<cflocation url="/app/contact/?currentid=#contactid#&contactid=#contactid#&t2=1">
