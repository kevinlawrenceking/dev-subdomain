<cfoutput>

#chr(60)#cffunction name="#getInsertFunctions.function_name#" access="public" returntype="void" output="false"#chr(62)#
            #chr(60)#cfargument name="recordData" type="struct" required="true" #chr(62)#
            
            #chr(60)#cfif NOT structKeyExists(arguments, "recordData") OR structIsEmpty(arguments.recordData)#chr(62)#
                #chr(60)#cfthrow message="recordData argument is missing or empty."#chr(62)#
            #chr(60)#/cfif#chr(62)#
            
            #chr(60)#cfset var columns = ""#chr(62)#
            #chr(60)#cfset var values = ""#chr(62)#

#chr(60)#cfloop query="getTableMetadata"#chr(62)#
                #chr(60)#cfset columnName = getTableMetadata.COLUMN_NAME#chr(62)#
                #chr(60)#cfset paramType = "cf_sql_varchar"#chr(62)#
                
                #chr(60)#cfif getTableMetadata.DATA_TYPE contains "int"#chr(62)#
                    #chr(60)#cfset paramType = "cf_sql_integer"#chr(62)#
                #chr(60)#cfelseif getTableMetadata.DATA_TYPE contains "date"#chr(62)#
                    #chr(60)#cfset paramType = "cf_sql_date"#chr(62)#
                #chr(60)#/cfif#chr(62)#

#chr(60)#cfif structKeyExists(arguments.recordData, columnName)#chr(62)#
                    #chr(60)#cfset columns = listAppend(columns, columnName)#chr(62)#
                    #chr(60)#cfset values = listAppend(values, "#chr(60)#cfqueryparam value=""#arguments.recordData[columnName]#"" cfsqltype=""#paramType#""#chr(62)#")#chr(62)#
                #chr(60)#/cfif#chr(62)#
            #chr(60)#/cfloop#chr(62)#

#chr(60)#cfquery #chr(62)#
                INSERT INTO #getInsertFunctions.qry_table# (#columns#)
                VALUES (#values#)
            #chr(60)#/cfquery#chr(62)#
        #chr(60)#/cffunction#chr(62)#
    <cfaborT></cfoutput>

<!--- Query to fetch the necessary details from tao_files and functions ---> 
<cfquery result="result" name="getInsertFunctions" datasource="abod">
    SELECT t.id, f.id as function_id, f.function_name, f.component_id, f.qry_type, 
           f.returntype, f.hint, c.component_name, c.related_table, 
           t.qry_table, t.qry_details, t.qry_name
    FROM tao_files t 
    INNER JOIN functions f ON f.id = t.function_id 
    INNER JOIN components c ON c.id = f.component_id
    WHERE t.qry_type = 'ins' AND t.isfetch = 0
</cfquery>

<!--- Iterate over each fetched record to build the insert function ---> 
<cfloop query="getInsertFunctions">

    <!--- Get the table metadata to generate the insert query ---> 
    <cfquery result="result" name="getTableMetadata" datasource="abod">
        SELECT COLUMN_NAME, DATA_TYPE, COLUMN_DEFAULT
        FROM information_schema.columns
        WHERE table_schema = 'new_development'
        AND table_name = <cfqueryparam value="#getInsertFunctions.qry_table#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <!--- Save the insert function logic in a variable using cfsavecontent ---> 
    <cfsavecontent variable="generatedInsertFunction">
        <!--- This is the code we want to save in the `function_code` field --->
        
        #chr(60)#cffunction name="#getInsertFunctions.function_name#" access="public" returntype="void" output="false"#chr(62)#
            #chr(60)#cfargument name="recordData" type="struct" required="true" #chr(62)#
            
            #chr(60)#cfif NOT structKeyExists(arguments, "recordData") OR structIsEmpty(arguments.recordData)#chr(62)#
                #chr(60)#cfthrow message="recordData argument is missing or empty."#chr(62)#
            #chr(60)#/cfif#chr(62)#
            
            #chr(60)#cfset var columns = ""#chr(62)#
            #chr(60)#cfset var values = ""#chr(62)#
            
            <!--- Loop through the table metadata to build the SQL ---> 
            #chr(60)#cfloop query="getTableMetadata"#chr(62)#
                #chr(60)#cfset columnName = getTableMetadata.COLUMN_NAME#chr(62)#
                #chr(60)#cfset paramType = "cf_sql_varchar"#chr(62)#
                
                #chr(60)#cfif getTableMetadata.DATA_TYPE contains "int"#chr(62)#
                    #chr(60)#cfset paramType = "cf_sql_integer"#chr(62)#
                #chr(60)#cfelseif getTableMetadata.DATA_TYPE contains "date"#chr(62)#
                    #chr(60)#cfset paramType = "cf_sql_date"#chr(62)#
                #chr(60)#/cfif#chr(62)#
                
                <!--- Append the generated query code for columns and values ---> 
                #chr(60)#cfif structKeyExists(arguments.recordData, columnName)#chr(62)#
                    #chr(60)#cfset columns = listAppend(columns, columnName)#chr(62)#
                    #chr(60)#cfset values = listAppend(values, "#chr(60)#cfqueryparam value=""#arguments.recordData[columnName]#"" cfsqltype=""#paramType#""#chr(62)#")#chr(62)#
                #chr(60)#/cfif#chr(62)#
            #chr(60)#/cfloop#chr(62)#
            
            <!--- Construct and execute the final INSERT query ---> 
            #chr(60)#cfquery #chr(62)#
                INSERT INTO #getInsertFunctions.qry_table# (#columns#)
                VALUES (#values#)
            #chr(60)#/cfquery#chr(62)#
        #chr(60)#/cffunction#chr(62)#
    </cfsavecontent>

    <!--- Update the function_code field in the functions table ---> 
    <cfquery result="result" datasource="abod">
        UPDATE functions
        SET function_code = <cfqueryparam value="#generatedInsertFunction#" cfsqltype="cf_sql_longvarchar">
        WHERE id = <cfqueryparam value="#getInsertFunctions.function_id#" cfsqltype="cf_sql_integer">
    </cfquery>

    <!--- Mark the isfetch flag as 1 in tao_files ---> 
    <cfquery result="result" datasource="abod">
        UPDATE tao_files
        SET isfetch = 1
        WHERE id = <cfqueryparam value="#getInsertFunctions.id#" cfsqltype="cf_sql_integer">
    </cfquery>

</cfloop>
