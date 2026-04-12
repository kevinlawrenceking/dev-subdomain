<cfinclude template="/include/perfcount.cfm" />
<!--- Legacy query file: DETauditionsimport was removed when AuditionImportService was rebuilt for v3.
     This file is still triggered by the pgFilename column in the pages DB table.
     Return an empty query so downstream code (valuelist, etc.) does not crash. --->
<cftry>
    <cfset auditionImportService = createObject("component", "services.AuditionImportService") />
    <cfif structKeyExists(auditionImportService, "DETauditionsimport")>
        <cfset upload_details = auditionImportService.DETauditionsimport(uploadid=uploadid) />
    <cfelse>
        <cfset upload_details = queryNew("audprojectid") />
    </cfif>
<cfcatch type="any">
    <cfset upload_details = queryNew("audprojectid") />
</cfcatch>
</cftry>