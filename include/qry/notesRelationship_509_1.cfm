<cfset noteService = request.svc("NoteService")>
<cfset notesRelationship = noteService.SELnoteslog_24704(
    userID = userid,
    contactID = contactid
)>