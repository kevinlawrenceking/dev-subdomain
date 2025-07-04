<!--- This ColdFusion page handles user site URL submissions and checks for existing records in the database. --->
<cfif structKeyExists(url, "userID")>
    <cfset userID = url.userID>
    
    <!--- Check if site URL is submitted --->
    <cfif structKeyExists(form, "siteurl")>
        <!--- Use CFQUERY to check for existing site URL for the user --->
        <cfquery name="checkSiteUrl" >
            SELECT COUNT(*) AS total_row
            FROM sitelinks_user
            WHERE userid = <cfqueryparam value="#userID#" cfsqltype="CF_SQL_INTEGER">
            AND siteurl = <cfqueryparam value="#trim(form.siteurl)#" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>
        
        <!--- Check if no records were found --->
        <cfif checkSiteUrl.total_row EQ 0>
            <cfset output = { "success" = true }>
            <cfoutput>#serializeJSON(output)#</cfoutput>
        </cfif>
    </cfif>
</cfif>
