<cfset noteService = createObject("component", "services.NoteService")>
<cfset find_note = noteService.SELnoteslog_24400(
    select_userid = select_userid,
    select_contactid = select_contactid,
    noteDetailsPrefix = left(new.notes, 8)
)>
<cfdump var="#find_note#" label="notes" >
