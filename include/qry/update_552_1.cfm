<!--- This ColdFusion page updates the isdeleted status for a specific user in the actionusers_tbl --->
<cfquery name="update">
    <!--- Update the isdeleted status to 1 for the specified user ID --->
    UPDATE actionusers_tbl
    SET isdeleted = 1
    WHERE id = #new_id#
</cfquery>
