<cfset notesService = createObject("component", "services.NoteService")>
<cfset notes = notesService.SELnoteslog(noteid=noteid)>