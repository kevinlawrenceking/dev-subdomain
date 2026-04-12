<cfinclude template="/include/perfcount.cfm" />
<cfset contactImportService = createObject("component", "services.ContactImportService")>


    <cfset insertedCount = contactImportService.INScontactsimport(importData=importdata, newUploadId=new_uploadid)>

