<cfset noteService = request.svc("NoteService")>
<cfset notesContact = noteService.SELnoteslog_24700(
    userID = userid,
    contactID = contactid
)>