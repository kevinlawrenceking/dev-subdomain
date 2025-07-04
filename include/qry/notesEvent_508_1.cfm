<cfset noteService = createObject("component", "services.NoteService")>
<cfset notesEvent = noteService.SELnoteslog_24702(
    userID = userid,
    eventID = eventid
)>