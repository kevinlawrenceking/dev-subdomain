<cfparam name="dbug" default="1" />

<cfset path_prefix = "C:/home/theactorsoffice.com/optimized" />
<cfset path_save = "C:/home/theactorsoffice.com/extracted" /> 
<cfset use_path = "/include/qry" />
<cfset qry_path = "/include/qry" />

<cfquery result="result" name="getFiles" datasource="abod" maxrows="100">
    SELECT id, `path`, `filename`
    FROM tao_files
    WHERE path = '/include/qry'
    and qry_extract_yn = 0
    ORDER BY `filename`
</cfquery>

<cfloop query="getFiles">

    <cfset fullFilePath = "#path_prefix##use_path#/#getFiles.filename#" />

    <cfif dbug eq 1>
        <cfoutput>fullFilePath: #fullFilePath#<br/></cfoutput>
    </cfif>

    <cfif fileExists(fullFilePath)>
        <cfset fileContent = fileRead(fullFilePath) />
        <cfset originalFileContent = fileContent />
        <cfset counter = 0 />
        <cfset queryFound = false />

        <cfloop condition="true">
            <cfset startQuery = REFindNoCase("(?i)<cfquery(\s+[^>]*)?>", fileContent, 1) />
            <cfset endQuery = REFindNoCase("(?i)</cfquery>", fileContent, startQuery) />

            <cfif dbug eq 1>
                <cfoutput>startQuery: #startQuery#, endQuery: #endQuery#<br/></cfoutput>
            </cfif>

            <cfif startQuery GT 0 AND endQuery GT startQuery>
                <cfset queryFound = true />
                <cfset queryBlockLength = (endQuery + 9) - startQuery />
                
                <cfif queryBlockLength GT 0>
                    <cfset fullQueryBlock = mid(fileContent, startQuery, queryBlockLength) />

                    <cfif dbug eq 1>
                        <cfoutput>Extracted Query Block:<br/>#htmlEditFormat(fullQueryBlock)#<br/></cfoutput>
                    </cfif>

                    <cfset nameStart = FindNoCase('name="', fileContent, startQuery) />
                    <cfset nameEnd = FindNoCase('"', fileContent, nameStart + 6) />
                    <cfif nameStart GT 0 AND nameEnd GT 0>
                        <cfset qryName = mid(fileContent, nameStart + 6, nameEnd - (nameStart + 6)) />
                    <cfelse>
                        <cfset qryName = "query_#counter#" />
                    </cfif>

                    <cfset qryNameSanitized = REReplace(qryName, "[^a-zA-Z0-9_]", "", "ALL")>
                    <cfset counter = counter + 1 />
                    <cfset newQueryFilename = qryNameSanitized & "_" & getFiles.id & "_" & counter & ".cfm" />

                    <cfif dbug eq 1>
                        <cfoutput>newQueryFilename: #newQueryFilename#<br/></cfoutput>
                    </cfif>

                    <cfset newQueryFilePath = "#path_save##qry_path#/#newQueryFilename#" />

                    <cfset fullQueryBlock = Replace(fullQueryBlock, "</cfquery", "</cfquery>", "ALL") />
                    <cffile action="write" file="#newQueryFilePath#" output="#fullQueryBlock#" />

                    <cftransaction>
                        <cfquery result="result" datasource="abod">
                            INSERT INTO tao_files (
                                `filename`,
                                `status`,
                                `path`,
                                `updated_timestamp`,
                                `optimized_yn`,
                                `qry_extract_yn`,
                                `parents`
                            )
                            VALUES (
                                <cfqueryparam value="#newQueryFilename#" cfsqltype="cf_sql_varchar" maxlength="255">,
                                <cfqueryparam value="new" cfsqltype="cf_sql_varchar" maxlength="20" />,
                                <cfqueryparam value="#qry_path#" cfsqltype="cf_sql_varchar" maxlength="255" />,
                                NOW(),
                                0, 1, <cfqueryparam value="#getFiles.id#" cfsqltype="cf_sql_varchar" />
                            )
                        </cfquery>

                        <cfquery result="result" datasource="abod">
                            UPDATE tao_files
                            SET qry_extract_yn = 1
                            WHERE id = <cfqueryparam value="#getFiles.id#" cfsqltype="cf_sql_integer" />
                        </cfquery>
                    </cftransaction>

                    <cfset cfIncludeTag = '<cfinclude template="#qry_path#/#newQueryFilename#" />'>
                    <cfset fileContent = Replace(fileContent, fullQueryBlock, cfIncludeTag, "ONE")>

                    <cfif dbug eq 1>
                        <cfoutput>Updated File Content:<br/>#htmlEditFormat(fileContent)#<br/></cfoutput>
                    </cfif>
                </cfif>
            <cfelse>
                <cfbreak>
            </cfif>
        </cfloop>

        <cfif queryFound eq false>
            <cfquery result="result" datasource="abod">
                UPDATE tao_files
                SET qry_extract_yn = 1
                WHERE id = <cfqueryparam value="#getFiles.id#" cfsqltype="cf_sql_integer" />
            </cfquery>
        </cfif>

        <cfif originalFileContent neq fileContent>
            <cfset newMainFilePath = "#path_save##use_path#/#getFiles.filename#">
            <cffile action="write" file="#newMainFilePath#" output="#fileContent#">
        </cfif>

        <cfset structDelete(variables, "fileContent")>
        <cfset structDelete(variables, "originalFileContent")>
    </cfif>
</cfloop>
