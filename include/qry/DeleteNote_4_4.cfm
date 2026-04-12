<cfinclude template="/include/perfcount.cfm" />
<cfset noteService = request.svc("NoteService")>
<cfset noteService.DELnoteslog_23709(noteId=updatenoteid)>