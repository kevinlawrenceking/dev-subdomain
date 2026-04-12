<cfinclude template="/include/perfcount.cfm" />
<cfset noteService = request.svc("NoteService")>
<cfset notesContactDetails = noteService.DETnoteslog(updateNoteID=updatenoteid)>