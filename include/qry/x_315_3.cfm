<cfset contactImportService = createObject("component", "services.ContactImportService")>
<cfset new = contactImportService.getContactsImportByUploadID(uploadId=new_uploadid)>