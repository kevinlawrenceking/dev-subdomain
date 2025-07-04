<cfset objNoteService = createObject("component", "services.NoteService")>
<cfset objNoteService.INSnoteslog_23972(
    userid = userid,
    contactid = rcontactid,
    noteDetails = LEFT(trim(noteDetails), 2000),
    isPublic = isPublic,
    eventid = eventid
)>