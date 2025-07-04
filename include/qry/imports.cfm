<cfset contactImportService = createObject("component", "services.ContactImportService")>
<cfset imports = contactImportService.getImportsByUserID(userid=userid)>