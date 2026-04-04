<cfset noteService = request.svc("NoteService")>
<cfset noteService.UPDnoteslog_23980(
    noteDetails = trim(noteDetails),
    isPublic = isPublic,
    noteid = noteid
)>