<cfset LinkService = createObject("component", "services.LinkService")>
<cfset links = LinkService.getLinksByNoteId(
    noteid = new_noteid
)>