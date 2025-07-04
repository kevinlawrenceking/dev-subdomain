<!--- This ColdFusion page fetches notes from the noteslog table based on a provided note ID --->
<cfquery name="note">
    <!--- Query to fetch notes based on the provided note ID --->
    SELECT 
        * 
    FROM 
        noteslog 
    WHERE 
        noteid = #noteid#
</cfquery>
