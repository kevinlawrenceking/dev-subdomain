<!--- This ColdFusion page processes category lists and includes necessary templates for account management. --->

<cfparam name="IsDeleted" default="0" />

<!--- Include the subsites query template --->
<cfinclude template="/include/qry/subsites_189_1.cfm" />

<!--- Check if the category list is not empty --->
<cfif #catlist# is not "">
    <!--- Sort the category list in ascending numeric order --->
    <cfset sortedCatList = listSort(catlist, "numeric", "asc")>
</cfif>

<!--- Include the update query template --->
<cfinclude template="/include/qry/update_260_2.cfm" />

<!--- Redirect to the account page with specific parameters --->
<cflocation url="/app/myaccount/?t4=1&tab4_expand=true" /> 

