<!--- This ColdFusion page processes a batch list and redirects to the dashboard after completion. --->
<cfset src = "x" />

<cfset notstatus = "Pending" />

<!--- Loop through each item in the batch list --->
<cfloop list="#batchlist#" index="notid">
    
    <cfset src = "x" />
    
    <!--- Include the template for completing the batch notification --->
    <cfinclude template="/include/complete_not_batch.cfm" />
    
</cfloop>

<!--- Redirect to the dashboard after processing the batch list --->
<cflocation url="/app/dashboard_new/?pgaction=view" />
