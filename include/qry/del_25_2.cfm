<cfinclude template="/include/perfcount.cfm" />
<cfset attachmentService = createObject("component", "services.AttachmentService")>
<cfset attachmentService.UPDattachments(attachid=attachid)>