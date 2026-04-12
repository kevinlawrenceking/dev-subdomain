<cfinclude template="/include/perfcount.cfm" />
<cfset ContactImportService = createObject("component", "services.ContactImportService")>
<cfset upload_details = contactImportService.DETcontactsimport(uploadid=uploadid)>