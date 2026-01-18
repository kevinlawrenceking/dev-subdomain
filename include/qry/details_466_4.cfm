<!--- This ColdFusion page retrieves details from a database using a query. --->

<cfquery name="details">
    #preservesinglequotes(resultsQuery)# 
    #preservesinglequotes(where)#
</cfquery>
