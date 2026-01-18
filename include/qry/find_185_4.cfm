<!--- This ColdFusion page retrieves a primary key from a specified table based on a given value for a specific field. --->

<cfquery name="find">        
    <!--- Query to select the primary key from the specified table where the field matches the desired value. --->
    select #primary_key# as primary_key 
    from #comptable# 
    where #fname# = #desired_val# 
    limit 1      
</cfquery>
