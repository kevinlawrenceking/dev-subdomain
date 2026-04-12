<cfinclude template="/include/perfcount.cfm" />
<cfset noteService = request.svc("NoteService")>
<cfset notesEvent = noteService.SELnoteslog_24702(
    userID = userid,
    eventID = eventid
)>