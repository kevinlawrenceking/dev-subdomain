<!--- This ColdFusion page retrieves contact details and related information based on user input. --->

<cfinclude template="/include/qry/details_451_1.cfm" />

<!--- Check if there is a referred contact ID to fetch additional details. --->
<cfif #details.refer_contact_id# IS NOT "">
    <cfinclude template="/include/qry/refer_details_451_2.cfm" />
</cfif>

<!--- Retrieve active contacts for the current user. --->
<cfinclude template="/include/qry/results_451_3.cfm" />

<!--- Fetch pronouns for the current user. --->
<cfinclude template="/include/qry/pronouns_451_4.cfm" />

<!--- Redirect if no details are found for the contact. --->
<Cfif #details.recordcount# IS "0">
    <cflocation url="/app/contacts/" />
</Cfif>

