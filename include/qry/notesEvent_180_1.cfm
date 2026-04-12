<cfinclude template="/include/perfcount.cfm" />
<cfset noteService = request.svc("NoteService")>
<cfset notesEvent = noteService.SELnoteslog_23987(
    userID = userid,
    eventID = eventid
)>