<cfset noteService = createObject("component", "services.NoteService")>
<cfset noteService.INSnoteslog_24373(
    userid = userid,
    noteDetails = LEFT(trim(x.note), 2000),
    new_audprojectid = new_audprojectid
)>