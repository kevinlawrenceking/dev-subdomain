<!--- This ColdFusion page includes various query templates and handles a conditional logic for record count before redirecting the user. --->

<cfinclude template="/include/qry/Find_114_1.cfm" />

<cfinclude template="/include/qry/update_114_2.cfm" />

<!--- Check if the record count matches a specific value --->
<cfif #find.recordcount# is "145645654654645645645">
    
    <!--- Include the third update query template if the condition is met --->
    <cfinclude template="/include/qry/update_114_3.cfm" />
    
</cfif>

<!--- Redirect the user to the my account page --->
<cflocation url="/app/myaccount/?t1=1" />
