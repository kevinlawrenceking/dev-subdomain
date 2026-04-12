<cfinclude template="/include/perfcount.cfm" />
<cfset NoteService = request.svc("NoteService")>

<cfset NoteService.SELnoteslog(
    noteid = noteid
) />