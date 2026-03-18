<cfset noteService = createObject("component", "services.NoteService")>
<cfset noteService.INSnoteslog_23969(
    userid = userid,
    contactid = rcontactid,
    noteDetails = trim(noteDetails),
    isPublic = isPublic,
    eventid = eventid,
    notedetailshtml = new_notetext
)>