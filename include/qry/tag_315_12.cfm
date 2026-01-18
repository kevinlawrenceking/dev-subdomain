<cfset contactImportService = createObject("component", "services.ContactImportService") />
<cfset tag2 = contactImportService.getcontactsImportTag(uploadid=new_uploadid,tag_label="tag2") />
<cfdump var="#tag2#" label="tag2" >