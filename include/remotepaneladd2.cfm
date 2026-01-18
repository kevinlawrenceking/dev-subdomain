<!--- This ColdFusion page handles the addition of a new site type and redirects based on the operation result. --->

<cfparam name="new_siteypename" default="" />

<cftransaction>
    <!--- Include query to find existing site type --->
    <cfinclude template="/include/qry/find_249_1.cfm" />

    <!--- Check if no existing site type is found --->
    <cfif #find.recordcount# is "0">
        <!--- Set the new site type title --->
        <cfset new_pnTitle = new_sitetypename />

        <!--- Include query to add new site type --->
        <cfinclude template="/include/qry/add_sitetype_249_2.cfm" />
        
        <!--- Get the generated key for the new site type --->
        
        <!--- Include query to find the newly added site type --->
        <cfinclude template="/include/qry/findit_249_3.cfm" />
        
        <!--- Set the new site type title from the find query --->
        <cfset new_pntitle = findit.pntitle />

        <!--- Include query to find the total --->
        <cfinclude template="/include/qry/Findtotal_249_4.cfm" /> 
        
        <!--- Include query to add the new PN --->
        <cfinclude template="/include/qry/add_249_5.cfm" />    
        
        <!--- Include query to add additional information for the new PN --->
        <cfinclude template="/include/qry/add_249_6.cfm" />
    </cfif>
</cftransaction>

<!--- Redirect based on the value of pgrtn --->
<cfif #pgrtn# is "P">
    <cflocation url="/app/myaccount/?t1=1&target_id=#new_sitetypeid#" /> 
</cfif>

<cfif #pgrtn# is "D">
    <cflocation url="/app/myaccount/?t1=1&target_id=#new_sitetypeid#" /> 
</cfif>

<cfif #pgrtn# is "z">
    <cflocation url="/app/dashboard_new/" /> 
</cfif>
