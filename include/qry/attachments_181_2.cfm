<cfinclude template="/include/perfcount.cfm" />
<cfset attachmentService = createObject("component", "services.AttachmentService")>
<cfset attachments = attachmentService.SELattachments(new_noteid=new_noteid)>