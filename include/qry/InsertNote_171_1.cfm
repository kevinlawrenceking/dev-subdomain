<cfset noteService = createObject("component", "services.NoteService")>
<cfset noteService.INSnoteslog_23969(
    userid = userid,
    contactid = rcontactid,
    noteDetails = LEFT(trim(noteDetails),2000),
    isPublic = isPublic,
    eventid = eventid,
    notedetailshtml = new_notetext
)>