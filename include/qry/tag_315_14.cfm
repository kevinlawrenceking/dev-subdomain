<cfset contactImportService = createObject("component", "services.contactImportService")>
<cfset tag3 = contactImportService.getcontactsImportTag(uploadid=new_uploadid,tag_label="tag3")>
<cfdump var="#tag3#" label="tag3" >