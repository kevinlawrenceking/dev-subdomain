<cfset contactImportService = createObject("component", "services.ContactImportService") />
<cfset tag = contactImportService.getcontactsImportTag(uploadid=new_uploadid,tag_label="tag1") />
<cfdump var="#tag#" label="tag1" >