<!--- This ColdFusion page processes a list of batch items and redirects to a dashboard page after completion. --->
<cfset src = "x" />

<cfset notstatus = "Skipped" />

<!--- Loop through each item in the batch list --->
<cfloop list="#batchlist#" index="notid">
    
    <cfset src = "x" />
    
    <!--- Include the template for processing the current item --->
    <cfinclude template="/include/complete_not_skip.cfm" />
    
</cfloop>

<!--- Redirect to the dashboard page after processing --->
<cflocation url="/app/dashboard_new/?pgaction=view" />
