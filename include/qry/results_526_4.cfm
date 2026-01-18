<!--- This ColdFusion page retrieves data from the database while filtering out deleted records. --->

<cfquery name="results">
    #preservesinglequotes(resultsQuery)#
    WHERE T.isdeleted is false
    #filter#
</cfquery>
