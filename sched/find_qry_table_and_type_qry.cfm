  <cfquery result="result" name="getFilesWithMissingTableType" datasource="abod">
  
    SELECT id, `path`, `filename`, qry_details
    FROM tao_files
    WHERE (qry_table IS NULL OR qry_table = '' OR qry_type IS NULL OR qry_type = '')
    AND path = '/include/qry' and status <> 'deleted' and qry_no = 1
</cfquery>

<cfloop query="getFilesWithMissingTableType">
    <!--- Extract the query details ---> 
    <cfset qryDetails = getFilesWithMissingTableType.qry_details>

    <!--- Default values ---> 
    <cfset qryType = "UNKNOWN">
    <cfset tableName = "UNKNOWN">

    <!--- Check for the type of query (SELECT, INSERT, UPDATE, DELETE) ---> 
    <cfset qryTypePattern = "^(SELECT|INSERT|UPDATE|DELETE)">
    <cfif REFindNoCase(qryTypePattern, qryDetails)>
        <cfset qryType = UCase(mid(qryDetails, REFindNoCase(qryTypePattern, qryDetails), 6))>
        
        <!--- Determine table name based on query type ---> 
        <cfif qryType EQ "SELECT" OR qryType EQ "DELETE">
            <!--- For SELECT and DELETE, look for the table after "FROM " ---> 
            <cfset fromPos = FindNoCase("FROM ", qryDetails)>
            <cfif fromPos GT 0>
                <cfset tableName = ListFirst(mid(qryDetails, fromPos + 5, Len(qryDetails) - fromPos - 4), " ")>
            </cfif>
        <cfelseif qryType EQ "UPDATE">
            <!--- For UPDATE, the table is after "UPDATE " ---> 
            <cfset updatePos = FindNoCase("UPDATE ", qryDetails)>
            <cfif updatePos GT 0>
                <cfset tableName = ListFirst(mid(qryDetails, updatePos + 7, Len(qryDetails) - updatePos - 6), " ")>
            </cfif>
        <cfelseif qryType EQ "INSERT">
            <!--- For INSERT, the table is after "INSERT INTO " ---> 
            <cfset insertPos = FindNoCase("INSERT INTO ", qryDetails)>
            <cfif insertPos GT 0>
                <cfset tableName = ListFirst(mid(qryDetails, insertPos + 12, Len(qryDetails) - insertPos - 11), " ")>
            </cfif>
        </cfif>
    </cfif>

    <!--- Clean the table name ---> 
    <cfset tableName = trim(tableName)>

    <!--- Insert the qry_table and qry_type into the database ---> 
    <cfquery result="result" datasource="abod">
        UPDATE tao_files
        SET qry_table = <cfqueryparam value="#tableName#" cfsqltype="cf_sql_varchar">,
            qry_type = <cfqueryparam value="#qryType#" cfsqltype="cf_sql_varchar">
        WHERE id = <cfqueryparam value="#getFilesWithMissingTableType.id#" cfsqltype="cf_sql_integer">
    </cfquery>

    <!--- Output the result for each file ---> 
    <cfoutput>
        File: #getFilesWithMissingTableType.filename#<br>
        Query Type: #qryType#<br>
        Query Table: #tableName#<br><br>
    </cfoutput>
</cfloop>
