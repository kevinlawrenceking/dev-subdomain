<cfset noteService = createObject("component", "services.NoteService")>
<cfset noteService.UPDnoteslog_23980(
    noteDetails = LEFT(trim(noteDetails), 2000),
    isPublic = isPublic,
    noteid = noteid
)>