<cfinclude template="/include/perfcount.cfm" />
<cfset attachmentService = createObject("component", "services.AttachmentService")>
<cfset attachdetails = attachmentService.DETattachments(attachid=attachid)>