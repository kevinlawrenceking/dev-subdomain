<cfinclude template="/include/perfcount.cfm" />
<cfset contactImportService = createObject("component", "services.ContactImportService")>
<cfset i = contactImportService.SELcontactsimport_i(uploadid=new_uploadid)>