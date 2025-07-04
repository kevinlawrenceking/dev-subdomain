<!--- This ColdFusion page processes category lists and includes relevant query templates based on record counts. --->

<cfif #catlist# is not "">
    <!--- Check if catlist is not empty and sort it numerically in ascending order. --->
    <cfset sortedCatList = listSort(catlist, "numeric", "asc")>
</cfif>

<!--- Include the query template to find records. --->
<cfinclude template="/include/qry/find_197_1.cfm" />

<cfif #find.recordcount# is "1">
    <!--- If exactly one record is found, include the update template. --->
    <cfinclude template="/include/qry/update_197_2.cfm">
</cfif>

<cfif #find.recordcount# is "0">
    <!--- If no records are found, include the add template. --->
    <cfinclude template="/include/qry/add_197_3.cfm">
</cfif>

<!--- Redirect to the my account page with specific parameters. --->
<cflocation url="/app/myaccount/?t4=1&tab4_expand=true" />
