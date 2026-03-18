<cfset objNoteService = createObject("component", "services.NoteService")>
<cfset objNoteService.INSnoteslog_23972(
    userid = userid,
    contactid = rcontactid,
    noteDetails = trim(noteDetails),
    isPublic = isPublic,
    eventid = eventid
)>