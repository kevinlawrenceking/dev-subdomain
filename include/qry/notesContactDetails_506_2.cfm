<!--- This ColdFusion page retrieves contact details and notes for a specific note ID from the database. --->

<cfquery name="notesContactDetails" maxrows="1">
    <!--- Select the relevant fields from noteslog and contactDetails tables --->
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
