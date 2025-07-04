<!--- This ColdFusion page processes a new order based on user input from a form. --->
<cfset newOrder = ListToArray(FORM.order)>

<!--- Loop through each item in the new order array --->
<cfloop from="1" to="#ArrayLen(newOrder)#" index="i">
    <!--- Include the query template for processing each order item --->
    <cfinclude template="/include/qry/query_0_314_1.cfm" />
</cfloop>
