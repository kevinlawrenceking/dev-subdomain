<cfset noteService = createObject("component", "services.NoteService")>
<cfset result = noteService.INSnoteslog_24401(
    userid = select_userid,
    contactid = select_contactid,
    noteDetails = trim(new.Notes)
)>

<cfdump var="#result#" >