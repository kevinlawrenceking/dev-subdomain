<!--- This ColdFusion page updates a record in the specified table with the given values based on the primary key. --->

<cfquery name="sq2">        
    <!--- Update the specified field in the table with the current value where the primary key matches the desired record ID. --->
    update #comptable# 
    set #fname# = #current_val# 
    where #primary_key# = #desired_recid#     
</cfquery>
