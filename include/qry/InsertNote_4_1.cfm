<cfset noteService = request.svc("NoteService")>
<cfset noteService.INSnoteslog(userid=userid, newcontactid=newcontactid, newnoteDetails=trim(newnoteDetails))>