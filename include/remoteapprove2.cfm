<!--- This ColdFusion page handles the insertion or update of records based on the test ID and user status. --->

<cfif #testid# is "0">
    <!--- If test ID is 0, include the insert template --->
    <cfinclude template="/include/qry/Insert_213_1.cfm" />
<cfelse>
    <!--- If test ID is not 0, include the update template --->
    <cfinclude template="/include/qry/update_213_2.cfm" />
</cfif>

<cfif "#userlastname#" is "Ansoff">
    <!--- Check if the user's last name is Ansoff --->
    <cfif "#new_teststatus#" is "Approved">
        <!--- If the new test status is Approved, include the update ticket template for approved status --->
        <cfinclude template="/include/qry/updateticket_213_3.cfm" />
    <cfelse>
        <!--- If the new test status is not Approved, include the update ticket template for non-approved status --->
        <cfinclude template="/include/qry/updateticket_213_4.cfm" />
    </cfif>
</cfif>

<!--- Redirect to the specified URL with the old version ID --->
<cflocation url="/app/version/?recid=#oldverid#" />
