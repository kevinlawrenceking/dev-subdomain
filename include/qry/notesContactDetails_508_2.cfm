<!--- This page retrieves the details of a specific note from the noteslog table along with the contact's full name. --->

<cfquery name="notesContactDetails" maxrows="1">
    <!--- Select the necessary fields from the noteslog and contactDetails tables. --->
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
