<!--- This ColdFusion page updates the contact details in the database based on the provided contact ID. --->

<cfquery name="updateContact">
    <!--- Update contact details to set the unique name to 'Y' for the specified contact ID. --->
    Update contactdetails
    Set #uniquename# = 'Y'
    Where contactid = #contactid#
</cfquery>
