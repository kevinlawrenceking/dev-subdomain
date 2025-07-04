<!--- This ColdFusion page handles the insertion of data into a specified table based on dynamic fields and types. --->
<cfquery name="#tname#_ins" result="result">
    INSERT INTO `#tname#` (
        <cfloop query="x">
            <!--- Loop through each field in the query to construct the column names. --->
            <cfif #x.currentrow# is not "1">,</cfif>
            `#x.field#`
        </cfloop>
    )
    VALUES (
        <cfloop query="x">
            <!--- Process each field to determine its SQL type and prepare the values for insertion. --->
            <cfscript>
                origText = x.type;
                newText = origText;
            </cfscript>

            <cfoutput>
                <cfset new_field="#EVALUATE('new_#x.field#')#" />
                <cfset new_maxvalue="#replace('#x.type#','#newtext#','')#" />
                <cfset new_maxvalue="#replace('#new_maxvalue#','(','')#" />
                <cfset new_maxvalue="#replace('#new_maxvalue#',')','')#" />
                <cfset new_maxvalue="#trim(new_maxvalue)#">

                <!--- Determine the appropriate SQL type based on the field type. --->
                <cfif #newText# is "int">
                    <cfset new_cfsqltype="cf_sql_integer" />
                </cfif>

                <cfif #newText# is "varchar">
                    <cfset new_cfsqltype="cf_sql_varchar" />
                </cfif>

                <cfif #newText# is "tinytext">
                    <cfset new_cfsqltype="cf_sql_varchar" />
                </cfif>

                <cfif #newText# is "mediumtext">
                    <cfset new_cfsqltype="cf_sql_longvarchar" />
                </cfif>

                <cfif #newText# is "longtext">
                    <cfset new_cfsqltype="cf_sql_longvarchar" />
                </cfif>

                <cfif #newText# is "text">
                    <cfset new_cfsqltype="cf_sql_longvarchar" />
                </cfif>

                <cfif #newText# is "bit">
                    <cfset new_cfsqltype="cf_sql_bit" />
                </cfif>

                <cfif #newText# is "time">
                    <cfset new_cfsqltype="cf_sql_time" />
                </cfif>

                <cfif #newText# is "date">
                    <cfset new_cfsqltype="cf_sql_date" />
                </cfif>

                <cfif #newText# is "datetime">
                    <cfset new_cfsqltype="cf_sql_timestamp" />
                </cfif>

                <cfif #newText# is "timestamp">
                    <cfset new_cfsqltype="cf_sql_timestamp" />
                </cfif>

                <cfif #newText# is "char">
                    <cfset new_cfsqltype="cf_sql_char" />
                </cfif>

                <cfif #x.currentrow# is not "1">,</cfif>
                <cfif #new_maxvalue# is not "">
                    <cfqueryparam cfsqltype="#new_cfsqltype#" value="#new_field#" maxlength="#new_maxvalue#" null="#NOT len(trim(new_field))#" />
                <cfelse>
                    <cfqueryparam cfsqltype="#new_cfsqltype#" value="#new_field#" null="#NOT len(trim(new_field))#" />
                </cfif>
            </cfoutput>
        </cfloop>
    );
</cfquery>
