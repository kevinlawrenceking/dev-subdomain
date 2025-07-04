    
<cfquery result="result" name="getFiles" datasource="abod">
    SELECT `id`, `path`, `filename`
    FROM `tao_files`
    WHERE `function_id` IS NOT NULL
    AND `qry_no` = 1;
</cfquery>

<cfloop query="getFiles">

    <cfset fullFilePath = "C:/home/theactorsoffice.com/optimized#path#/#filename#">

<cfif fileExists(fullFilePath)>
        <cfset fileContent = fileRead(fullFilePath)>
<Cfabort>
     
        <cfoutput>Processing file: #filename#<br></cfoutput>
<cfset queryNameMatch = REMatchNoCase("name\s*=\s*['\"]([^'\"]+)['\"]", fileContent)>


<cfoutput>
            Found Matches: #arrayLen(queryNameMatch)# for file: #filename#<br>
        </cfoutput>

        <!--- If a match is found, extract and update the qry_name field --->
        <cfif arrayLen(queryNameMatch) GT 0>
    
            <cfset extractedQueryName = queryNameMatch[1]>

<cfset extractedQueryName = trim(replace(replace(extractedQueryName, "name=", "", "ALL"), '"', "", "ALL"))>
<cfoutput>
    file: #filename#
    
    <br/>
    </cfoutput>

<cfquery result="result" datasource="abod">
                UPDATE tao_files
                SET qry_name = <cfqueryparam value="#extractedQueryName#" cfsqltype="cf_sql_varchar" maxlength="255">
                WHERE id = <cfqueryparam value="#getFiles.id#" cfsqltype="cf_sql_integer">
            </cfquery>
        <cfelse>
            <cfoutput>No query name found for file: #filename#<br></cfoutput>
        </cfif>
    <cfelse>
        <cfoutput>File not found: #fullFilePath#<br></cfoutput>
    </cfif>
</cfloop>
