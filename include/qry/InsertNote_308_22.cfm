<cfset noteService = request.svc("NoteService")>
<cfset noteService.INSnoteslog_24373(
    userid = userid,
    noteDetails = trim(x.note),
    new_audprojectid = new_audprojectid
)>