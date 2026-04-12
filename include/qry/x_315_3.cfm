<cfinclude template="/include/perfcount.cfm" />
<cfset contactImportService = createObject("component", "services.ContactImportService")>
<cfset new = contactImportService.getContactsImportByUploadID(uploadId=new_uploadid)>