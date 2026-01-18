<!--- This page retrieves the details of a specific note from the noteslog table and joins it with contact details for display. --->
<cfquery name="notesContactDetails" maxrows="1">
    <!--- Query to select note details along with contact information based on the note ID --->
    SELECT
        n.noteID,
        n.noteDetails,
        n.userID,
        n.noteTimestamp,
        n.contactID,
        n.isPublic,
        d.contactFullName AS fullname
    FROM 
        noteslog n
    INNER JOIN 
        contactDetails d ON d.contactid = n.contactid
    WHERE 
        n.noteid = #updatenoteid#
</cfquery>
