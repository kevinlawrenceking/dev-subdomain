<!--- This ColdFusion page processes a user request to check for a specific sitename associated with a user ID and returns a JSON response. --->

<cfif structKeyExists(url, "userID")>
    <cfset userID = url.userID>

    <!--- Check if sitename is posted --->
    <cfif structKeyExists(form, "sitename")>
        
        <!--- Use CFQUERY to check for the sitename --->
        <cfquery name="checkSiteName" >
            SELECT COUNT(*) AS total_row
            FROM sitelinks_user
            WHERE userid = <cfqueryparam value="#userID#" cfsqltype="CF_SQL_INTEGER">
            AND sitename = <cfqueryparam value="#trim(form.sitename)#" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

        <!--- Prepare JSON output based on the row count --->
        <cfif checkSiteName.total_row EQ 0>
            <cfset output = { "success" = true }>
            <cfoutput>#serializeJSON(output)#</cfoutput>
        </cfif>

    </cfif>
</cfif>
