<!--- This ColdFusion page performs a database update based on specific conditions. --->

<cfquery name="update">
    <!--- Execute the query to update the database with preserved single quotes from resultsquery and where variables. --->
    #preservesinglequotes(resultsquery)#
    #preservesinglequotes(where)#
</cfquery>
