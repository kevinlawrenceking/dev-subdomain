<cfset noteService = createObject("component", "services.NoteService")>
<cfset noteService.UPDnoteslog_23980(
    noteDetails = trim(noteDetails),
    isPublic = isPublic,
    noteid = noteid
)>