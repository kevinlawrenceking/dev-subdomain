<!--- This ColdFusion page updates the isdeleted field for a specified user ID in the actionusers_tbl --->
<cfquery name="update">
    <!--- Update the isdeleted field to 0 for the specified user ID --->
    UPDATE actionusers_tbl
    SET isdeleted = 0
    WHERE id = #new_id#
</cfquery>
