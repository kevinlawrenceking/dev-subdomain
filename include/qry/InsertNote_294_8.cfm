<cfset noteService = createObject("component", "services.NoteService")>
<cfset noteService.INSnoteslog_24319(
    userid = userid,
    contactid = contactid,
    noteDetails = new_NoteDetails,
    isPublic = true,
    eventid = 0
)>