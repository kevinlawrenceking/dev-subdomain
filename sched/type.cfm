<!--- Step 1: Select records where qry_type is 'UNKNOWN' --->
<cfquery result="result" name="getUnknownTypeQueries" datasource="abod">
    SELECT id, qry_details, qry_table, qry_type
    FROM tao_files
    WHERE qry_extract_yn = 1
      AND PATH = '/include/qry'
      AND STATUS = 'existing'
      AND qry_type = 'UNKNOWN'
    ORDER BY qry_table, qry_type, qry_details
</cfquery>

<cfloop query="getUnknownTypeQueries">
    <!--- Step 2: Extract the first word from qry_details, which is the query type --->
    <cfset firstWord = ListFirst(trim(getUnknownTypeQueries.qry_details), " ")>

    <!--- Step 3: Check if the first word matches a valid SQL query type --->
    <cfset validQueryTypes = "SELECT,INSERT,UPDATE,DELETE">
    <cfif ListFindNoCase(validQueryTypes, firstWord)>
        <!--- Step 4: If the first word is a valid query type, update qry_type --->
        <cfquery result="result" datasource="abod">
            UPDATE tao_files
            SET qry_type = <cfqueryparam value="#firstWord#" cfsqltype="cf_sql_varchar">
            WHERE id = <cfqueryparam value="#getUnknownTypeQueries.id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <!--- Output success for debugging purposes --->
        <cfoutput>Updated qry_type for ID: #getUnknownTypeQueries.id# with type: #firstWord#<br></cfoutput>
    <cfelse>
        <!--- If the first word is not a recognized query type, output a message --->
        <cfoutput>Unrecognized query type in qry_details for ID: #getUnknownTypeQueries.id#<br></cfoutput>
    </cfif>
</cfloop>
