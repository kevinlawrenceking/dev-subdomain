<!--- Step 1: Select records where qry_table is blank --->

<cfquery result="result" name="getBlankTableQueries" datasource="abod">
    SELECT id, qry_details, qry_table, qry_type
    FROM tao_files
    WHERE qry_extract_yn = 1
      AND PATH = '/include/qry'
      AND STATUS = 'existing'
      AND qry_table = ''
    ORDER BY qry_table, qry_type, qry_details
</cfquery>

<cfloop query="getBlankTableQueries">
    <!--- Step 2: Find the "FROM " string in qry_details --->
    <cfset fromPos = FindNoCase("FROM ", getBlankTableQueries.qry_details)>

    <!--- Step 3: Extract the table name (next word after "FROM ") --->
    <cfif fromPos GT 0>
        <!--- Get the substring starting right after "FROM " and ending at the next space --->
        <cfset tableName = ListFirst(mid(getBlankTableQueries.qry_details, fromPos + 5, Len(getBlankTableQueries.qry_details) - fromPos - 4), " ")>
        <cfset tableName = trim(tableName)>

        <!--- Step 4: Update the qry_table in the database with the found table name --->
        <cfquery result="result" datasource="abod">
            UPDATE tao_files
            SET qry_table = <cfqueryparam value="#tableName#" cfsqltype="cf_sql_varchar">
            WHERE id = <cfqueryparam value="#getBlankTableQueries.id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <!--- Output success for debugging purposes --->
        <cfoutput>Updated qry_table for ID: #getBlankTableQueries.id# with table: #tableName#<br></cfoutput>
    <cfelse>
        <!--- No "FROM " found, skipping this record --->
        <cfoutput>No "FROM" keyword found in qry_details for ID: #getBlankTableQueries.id#<br></cfoutput>
    </cfif>
</cfloop>
