<cfinclude template="/include/perfcount.cfm" />
<cfset noteService = request.svc("NoteService")>
<cfset notesaud = noteService.SELnoteslog_24698(audprojectid=audprojectid)>