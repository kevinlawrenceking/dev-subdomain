<cfset noteService = createObject("component", "services.NoteService")>
<cfset noteService.INSnoteslog(userid=userid, newcontactid=newcontactid, newnoteDetails=LEFT(trim(newnoteDetails), 2000))>