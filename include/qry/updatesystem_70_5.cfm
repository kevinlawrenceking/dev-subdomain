<!--- This ColdFusion page updates the status of a user in the fusystemusers table to 'Completed' based on the provided user ID. --->

<cfquery name="updatesystem">
    <!--- Update the status of the user to 'Completed' based on the user ID. --->
    Update fusystemusers
    set suStatus = 'Completed'
    where suid = #newsuid#
</cfquery>
