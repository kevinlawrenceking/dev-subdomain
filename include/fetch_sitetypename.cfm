<!--- This ColdFusion page processes a user request to check for a specific site type associated with a user ID and returns a JSON response. --->

<cfset userID = URL.userID>

<!--- Check if the site type name is posted --->
<cfif structKeyExists(form, "sitetypename")>

    <!--- Query the database to check for the site type name --->
    <cfquery name="checkSiteType" >
        SELECT COUNT(*) AS total_row
        FROM sitetypes_user
        WHERE userid = <cfqueryparam value="#userID#" cfsqltype="CF_SQL_INTEGER">
        AND sitetypename = <cfqueryparam value="#trim(form.sitetypename)#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

    <!--- Check if no rows were returned --->
    <cfif checkSiteType.total_row EQ 0>
        <cfset output = { "success" = true }>
        <cfoutput>#serializeJSON(output)#</cfoutput>
    </cfif>

</cfif>
