<cfset noteService = createObject("component", "services.NoteService")>
<cfset notesEvent = noteService.SELnoteslog_23987(
    userID = userid,
    eventID = eventid
)>