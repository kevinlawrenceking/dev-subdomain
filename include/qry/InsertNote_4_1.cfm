<cfset noteService = createObject("component", "services.NoteService")>
<cfset noteService.INSnoteslog(userid=userid, newcontactid=newcontactid, newnoteDetails=trim(newnoteDetails))>