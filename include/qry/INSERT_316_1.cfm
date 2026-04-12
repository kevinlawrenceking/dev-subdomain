<cfinclude template="/include/perfcount.cfm" />
<cfset uploadService = createObject("component", "services.UploadService")>
<cfset new_uploadid = uploadService.INSuploads(userid=userid)>