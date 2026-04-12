<cfinclude template="/include/perfcount.cfm" />
<cfset noteService = request.svc("NoteService")>
<cfset noteService.UPDnoteslog(recid=recid)>