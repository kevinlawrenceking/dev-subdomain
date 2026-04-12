<cfinclude template="/include/perfcount.cfm" />
<cfset contactImportService = createObject("component", "services.ContactImportService")>
<cfset h = contactImportService.SELcontactsimport_h(uploadid=new_uploadid)>