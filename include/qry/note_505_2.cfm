<!--- This ColdFusion page retrieves notes based on the provided note ID --->
<cfquery name="note">
    <!--- Retrieve notes based on the provided note ID --->
    SELECT * 
    FROM noteslog 
    WHERE noteid = #noteid#
</cfquery>
