<cfset contactImportService = createObject("component", "services.ContactImportService")>
<cfset contactImportService.UPDCONTACTSIMPORT(new_status=new_status, new_contactid=new_contactid, id=new.id)>