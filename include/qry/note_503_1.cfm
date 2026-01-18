<!--- This ColdFusion page fetches notes from the noteslog table based on a specific note ID --->
<cfquery name="note">
    <!--- Query to fetch notes based on note ID --->
    Select * 
    from noteslog 
    where noteid = #noteid#
</cfquery>
