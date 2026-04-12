<cfinclude template="/include/perfcount.cfm" />
<!--- Legacy query file: RESauditionsimport_23917 was removed when AuditionImportService was rebuilt for v3.
     This file is still triggered by import-auditions.cfm after an upload completes.
     Return a fallback query with column aliases matching the display code expectations:
     col1b=projDate, col2=projName, col3=audRoleName, col4=audCatName, col5=audsource, col6=status --->
<cftry>
    <cfset auditionImportService = createObject("component", "services.AuditionImportService")>
    <cfif structKeyExists(auditionImportService, "RESauditionsimport_23917")>
        <cfset results = auditionImportService.RESauditionsimport_23917(uploadid=uploadid)>
    <cfelse>
        <!--- Method removed in V3 rebuild - query auditionsimport directly as fallback --->
        <cfquery name="results">
            SELECT ai.id,
                   ai.audprojectid,
                   ai.projDate AS col1b,
                   ai.projName AS col2,
                   ai.audRoleName AS col3,
                   ai.audCatName AS col4,
                   ai.audsource AS col5,
                   ai.status AS col6
            FROM auditionsimport ai
            WHERE ai.uploadid = <cfqueryparam value="#uploadid#" cfsqltype="cf_sql_integer">
            ORDER BY ai.id
        </cfquery>
    </cfif>
<cfcatch type="any">
    <cflog file="audition_import" type="error" text="getAuditionImportResults fallback: #cfcatch.message#">
    <cfquery name="results">
        SELECT ai.id,
               ai.audprojectid,
               ai.projDate AS col1b,
               ai.projName AS col2,
               ai.audRoleName AS col3,
               ai.audCatName AS col4,
               ai.audsource AS col5,
               ai.status AS col6
        FROM auditionsimport ai
        WHERE ai.uploadid = <cfqueryparam value="#uploadid#" cfsqltype="cf_sql_integer">
        ORDER BY ai.id
    </cfquery>
</cfcatch>
</cftry>