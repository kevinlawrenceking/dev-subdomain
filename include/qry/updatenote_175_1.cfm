<cfset noteService = createObject("component", "services.NoteService")>
<cfset noteService.UPDnoteslog_23974(
    noteDetails = LEFT(trim(noteDetails), 2000),
    new_noteText = trim(new_notetext),
    isPublic = isPublic,
    noteid = noteid
)>