<cfinclude template="/include/perfcount.cfm" />
<cfset noteService = request.svc("NoteService")>
<cfset result = noteService.INSnoteslog_24401(
    userid = select_userid,
    contactid = select_contactid,
    noteDetails = trim(new.Notes)
)>

<cfdump var="#result#" >