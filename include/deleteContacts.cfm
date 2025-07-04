<!--- This ColdFusion page initializes parameters, includes a query, and redirects the user to the contacts page. --->

<cfparam name="idlist" default="0" /> 

<!--- Include the query for updating records. --->
<cfinclude template="/include/qry/update_101_1.cfm" />

<!--- Redirect to the contacts page without adding a token. --->
<cflocation url="/app/contacts/" addtoken="no" />
