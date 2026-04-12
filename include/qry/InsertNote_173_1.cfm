<cfinclude template="/include/perfcount.cfm" />
<cfset objNoteService = request.svc("NoteService")>
<cfset objNoteService.INSnoteslog_23972(
    userid = userid,
    contactid = rcontactid,
    noteDetails = trim(noteDetails),
    isPublic = isPublic,
    eventid = eventid
)>