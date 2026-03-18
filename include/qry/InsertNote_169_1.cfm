<cfset noteService = createObject("component", "services.NoteService")>
<cfset noteService.INSnoteslog_23966(
    userid = Val(userid),
    contactid = Val(rcontactid),
    noteDetails = trim(noteDetails),
    isPublic = isPublic,
    audprojectid = Val(audprojectid),
    notedetailshtml = new_notetext
)>