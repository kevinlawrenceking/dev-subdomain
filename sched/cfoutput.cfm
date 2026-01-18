<cfscript>

    function countOccurrences(text, substring) {
        var count = 0;
        var pos = 1;
        var result = 0; 
        while (pos <= len(text)) {
            result = reFindNoCase(substring, text, pos);
            if (result GT 0) {
                count++;
                pos = result + 1;  
            } else {
                break;
            }
        }
        return count;
    }
</cfscript>

<!--- Query the database for files with path='/include' --->
<cfquery result="result" name="getIncludeFiles" datasource="abod">
    SELECT id, `path`, `filename`, qry_no
    FROM tao_files
    WHERE path = '/include'
</cfquery>

<!--- Loop through each file --->
<cfloop query="getIncludeFiles">
    <cfset fullFilePath = "C:/home/theactorsoffice.com/optimized/include/#getIncludeFiles.filename#">
    
    <!--- Check if the file exists --->
    <cfif fileExists(fullFilePath)>
        <!--- Read the file content with error handling --->
        <cftry>
            <cfset fileContent = toString(fileRead(fullFilePath))>
        <cfcatch>
            <cflog file="cfoutputErrors" text="Error reading file #fullFilePath#: #cfcatch.message#" type="error">
            <cfoutput>Error reading file #fullFilePath#: #cfcatch.message#<br></cfoutput>
            <cfcontinue> <!--- Skip to the next file --->
        </cfcatch>
        </cftry>
        
        <!--- Fix missing '>' in </cfquery> tags --->
        <cfset fileContent = REReplace(fileContent, "</cfquery(?!(>))", "</cfquery>", "ALL")>
        
        <!--- Count the number of '<cfoutput' matches --->
        <cfset cfoutputOpenCount = countOccurrences(fileContent, "<cfoutput")>
        
        <!--- Count the number of '</cfoutput>' matches --->
        <cfset cfoutputCloseCount = countOccurrences(fileContent, "</cfoutput>")>
        
        <!--- Calculate the absolute difference --->
        <cfset difference = abs(cfoutputOpenCount - cfoutputCloseCount)>
        
        <!--- Update qry_no in the database --->
        <cftry>
            <cfquery result="result" datasource="abod">
                UPDATE tao_files
                SET qry_no = <cfqueryparam value="#difference#" cfsqltype="cf_sql_integer">
                WHERE id = <cfqueryparam value="#getIncludeFiles.id#" cfsqltype="cf_sql_integer">
            </cfquery>
        <cfcatch>
            <cflog file="cfoutputErrors" text="Error updating qry_no for file ID #getIncludeFiles.id#: #cfcatch.message#" type="error">
            <cfoutput>Error updating qry_no for file #getIncludeFiles.filename#: #cfcatch.message#<br></cfoutput>
            <cfcontinue> <!--- Skip to the next file --->
        </cfcatch>
        </cftry>
        
        <!--- Output the results for debugging --->
        <cfoutput>
            <strong>File:</strong> #getIncludeFiles.filename#<br>
            &nbsp;&nbsp;<strong>Open &lt;cfoutput&gt; tags:</strong> #cfoutputOpenCount#<br>
            &nbsp;&nbsp;<strong>Close &lt;/cfoutput&gt; tags:</strong> #cfoutputCloseCount#<br>
            &nbsp;&nbsp;<strong>Difference (qry_no):</strong> #difference#<br><br>
        </cfoutput>
    <cfelse>
        <cfoutput>
            <strong>File not found:</strong> #fullFilePath#<br><br>
        </cfoutput>
    </cfif>
</cfloop>
