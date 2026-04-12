<cfinclude template="/include/perfcount.cfm" />
<cfset noteService = request.svc("NoteService")>
<cfset noteService.DELnoteslog(noteid=noteid)>