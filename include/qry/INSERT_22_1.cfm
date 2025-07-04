<cfset attachmentService = createObject("component", "services.AttachmentService")>
<cfset new_uploadid = attachmentService.INSattachments(
    attachname = attachname,
    attachfilename = attachfilename,
    noteid = noteid
)>