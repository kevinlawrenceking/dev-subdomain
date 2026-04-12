<cfinclude template="/include/perfcount.cfm" />
<cfset notesService = request.svc("NoteService")>
<cfset notes = notesService.SELnoteslog(noteid=noteid)>