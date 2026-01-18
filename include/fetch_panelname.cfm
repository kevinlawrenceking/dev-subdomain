<!--- This ColdFusion page processes a user ID and checks if a specific site type name exists for that user in the database. It returns a JSON response indicating success or failure. --->

<cfset userID = url.userID>

<!--- Check if the site type name is submitted via POST --->
<cfif structKeyExists(form, "sitetypename")>
    
    <!--- Use CFQUERY to check for the site type name --->
    <cfquery name="checkSiteTypeName" >
        SELECT COUNT(*) AS total_row
        FROM sitetypes_user
        WHERE userid = <cfqueryparam value="#userID#" cfsqltype="CF_SQL_INTEGER">
        AND sitetypename = <cfqueryparam value="#trim(form.sitetypename)#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>
    
    <!--- Check if no rows were returned --->
    <cfif checkSiteTypeName.total_row EQ 0>
        <cfset output = { "success" = true }>
        <cfoutput>#serializeJSON(output)#</cfoutput>
    </cfif>
    
</cfif>
