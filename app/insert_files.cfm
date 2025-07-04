<cfset includeDir = expandPath("/include")>
<cfset qryDir = expandPath("/include/qry")>

<!--- Get the list of files in the directory (include only files) --->
<cfset fileList = directoryList(includeDir, false, "files")>
  <cftry>
<!--- Loop through the files in /include directory --->
<cfloop array="#fileList#" index="f">
    <!--- Extract filename from the full file path --->

    <cfoutput>#f#</cfoutput>

<cfset fname = listLast(f, "/")>

    <!--- Try to insert each file into the database --->
    <cftry>
        <cfquery result="result" datasource="abod">
            INSERT INTO tao_files (`filename`, `status`, `path`, `updated_timestamp`)
            VALUES (
                <cfqueryparam value="#fname#" cfsqltype="cf_sql_varchar" maxlength="255">,
                <cfqueryparam value="existing" cfsqltype="cf_sql_varchar" maxlength="20">,
                <cfqueryparam value="/include" cfsqltype="cf_sql_varchar" maxlength="255">,
                NOW()
            );
        </cfquery>
        <cfcatch type="any">
            <!--- Catch any error but continue with next file --->
            <cfoutput>Error inserting #filename#: #cfcatch.message#</cfoutput>
        </cfcatch>
    </cftry>
</cfloop>

<!--- Now loop through the /include/qry directory --->
<cfset fileListQry = directoryList(qryDir, false, "files")>

<cfloop array="#fileListQry#" index="f">
<cfoutput>#f#</cfoutput>
    <cfset fname = listLast(f, "/")>

    <cftry>
        <cfquery result="result" datasource="abod">
            INSERT INTO tao_files (`filename`, `status`, `path`, `updated_timestamp`)
            VALUES (
                <cfqueryparam value="#fname#" cfsqltype="cf_sql_varchar" maxlength="255">,
                <cfqueryparam value="existing" cfsqltype="cf_sql_varchar" maxlength="20">,
                <cfqueryparam value="/include/qry" cfsqltype="cf_sql_varchar" maxlength="255">,
                NOW()
            );
        </cfquery>
        <cfcatch type="any">
            <cfoutput>Error inserting #fname#: #cfcatch.message#</cfoutput>
        </cfcatch>
    </cftry>
</cfloop>
      <cfcatch type="any">
            <cfoutput>Error inserting #fname#: #cfcatch.message#</cfoutput>
        </cfcatch>
  </cftry>
<cfoutput>Insert complete.</cfoutput>
