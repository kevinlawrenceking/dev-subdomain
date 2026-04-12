<cfinclude template="/include/perfcount.cfm" />
<cfset noteService = request.svc("NoteService")>
<cfset noteService.UPDnoteslog_23974(
    noteDetails = trim(noteDetails),
    new_noteText = trim(new_notetext),
    isPublic = isPublic,
    noteid = noteid
)>