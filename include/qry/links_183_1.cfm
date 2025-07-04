<cfset linkService = createObject("component", "services.linkService")>

<!--- Call the function with the specified note ID --->
<cfset links = linkService.getLinksByNoteId(noteid=new_noteid)>