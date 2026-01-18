<cfset noteService = createObject("component", "services.NoteService")>
<cfset notesContact = noteService.SELnoteslog_24700(
    userID = userid,
    contactID = contactid
)>