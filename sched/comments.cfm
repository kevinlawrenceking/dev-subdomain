<!--- Step 1: Select records where qry_details starts with a comment --->

<cfquery result="result" name="getCommentedQueries" datasource="abod">
    SELECT id, qry_details
    FROM tao_files
    WHERE qry_details LIKE '<!-%'
</cfquery>

<cfloop query="getCommentedQueries">
    <!--- Step 2: Remove the comment --->

    <!--- Find the position of the start and end of the comment block --->
    <cfset startComment = FindNoCase("<!-", getCommentedQueries.qry_details)>
    <cfset endComment = FindNoCase("->", getCommentedQueries.qry_details)>

    <!--- Check if valid comment tags were found --->
    <cfif startComment GT 0 AND endComment GT startComment>
        <!--- Extract the part of the query after the comment block --->
        <cfset cleanQryDetails = mid(getCommentedQueries.qry_details, endComment + 4, Len(getCommentedQueries.qry_details) - endComment)>

        <!--- Step 3: Trim the string and remove extra spaces --->
        <cfset cleanQryDetails = trim(REReplace(cleanQryDetails, "[\s]+", " ", "ALL"))>

        <!--- Step 4: Update the qry_details in the database with the cleaned string --->

        <cfquery result="result" datasource="abod">
            UPDATE tao_files
            SET qry_details = <cfqueryparam value="#cleanQryDetails#" cfsqltype="cf_sql_varchar">
            WHERE id = <cfqueryparam value="#getCommentedQueries.id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <!--- Output success for debugging purposes --->
        <cfoutput>Updated qry_details for ID: #getCommentedQueries.id#<br></cfoutput>
    <cfelse>
        <!--- Comment block not found or invalid, skipping this record --->
        <cfoutput>No valid comment block found for ID: #getCommentedQueries.id#<br></cfoutput>
    </cfif>
</cfloop>
