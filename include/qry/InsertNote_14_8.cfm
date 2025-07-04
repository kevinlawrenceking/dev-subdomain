<cfset noteService = createObject("component", "services.NoteService")>
<cfset noteService.INSnoteslog_23730(userid=userid, new_eventid=new_eventid, noteDetails=trim(noteDetails))>