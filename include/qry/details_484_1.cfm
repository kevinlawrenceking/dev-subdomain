<cfinclude template="/include/perfcount.cfm" />
<cfset uploadService = createObject("component", "services.UploadService")>
<cfset details = uploadService.DETuploads(uploadid=uploadid)>