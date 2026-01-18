<cfset noteService = createObject("component", "services.NoteService")>
<cfset noteService.INSnoteslog_23966(
    userid = userid,
    contactid = rcontactid,
    noteDetails = LEFT(trim(noteDetails), 2000),
    isPublic = isPublic,
    audprojectid = audprojectid,
    notedetailshtml = new_notetext
)>