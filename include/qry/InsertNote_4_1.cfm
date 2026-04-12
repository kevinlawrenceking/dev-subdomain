<cfinclude template="/include/perfcount.cfm" />
<cfset noteService = request.svc("NoteService")>
<cfset noteService.INSnoteslog(userid=userid, newcontactid=newcontactid, newnoteDetails=trim(newnoteDetails))>