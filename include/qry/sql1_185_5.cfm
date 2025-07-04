<!--- This ColdFusion page updates a record in the specified table with a new value based on the provided primary key. --->

<cfquery name="sql1">        
    <!--- Update the specified field in the table with the desired value based on the record ID. --->
    update #comptable# 
    set #fname# = #desired_val# 
    where #primary_key# = #recid#
</cfquery>
