<cfset noteService = createObject("component", "services.NoteService")>
<cfset notesRelationship = noteService.SELnoteslog_24704(
    userID = userid,
    contactID = contactid
)>