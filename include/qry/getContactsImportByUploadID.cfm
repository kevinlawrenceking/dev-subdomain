<cfset contactImportService = createObject("component", "services.ContactImportService")>
<cfset new = contactImportService.getContactsImport(uploadId=new_uploadid)>
<cfset new_id = new.id />