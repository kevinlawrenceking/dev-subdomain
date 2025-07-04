<!--- This ColdFusion page handles the inclusion of various query templates and redirects based on the value of the variable 'pgrtn'. --->

<cfparam name="isvisible" default="0" />

<!--- Include the first query template for adding data  --->
<cfinclude template="/include/qry/add_240_1.cfm" /> 

<cfinclude template="/include/qry/pgPanelsFix.cfm" />

<!--- Redirect based on the value of 'pgrtn' for different scenarios --->
<cfif #pgrtn# is "P">
    <cflocation url="/app/myaccount/?t1=1&target_id=#new_sitetypeid###heading#new_sitetypeid#" addtoken="no"  />
</cfif>

<cfif #pgrtn# is "D">
    <cflocation url="/app/myaccount/?t1=1&target_id=#new_sitetypeid###heading#new_sitetypeid#" addtoken="no"  />
</cfif>

<cfif #pgrtn# is "z">
    <cflocation url="/app/dashboard_new/##heading#new_sitetypeid#" addtoken="no" />
</cfif>
