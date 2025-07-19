<!--- 
    PURPOSE: Handle loading of shared content for external viewing
    AUTHOR: Updated by GitHub Copilot
    DATE: 2025-07-19
    PARAMETERS: shareToken
    DEPENDENCIES: services.ContactItemService, services.ReminderService
--->

<cfparam name="url.shareToken" default="" />

<!--- Ensure we have access to the application datasource --->
<cfif not structKeyExists(application, "dsn")>
    <cfset onApplicationStart() />
</cfif>
<cfset dsn = application.dsn />

<!--- Validate share token if present --->
<cfif len(trim(url.shareToken)) gt 0>
    <!--- Check if the shareTokens table exists --->
    <cftry>
        <!--- Query to validate token and get user information --->
        <cfquery name="qValidateToken" datasource="#application.dsn#">
            SELECT 
                s.shareID,
                s.userID,
                s.shareType,
                s.expiryDate,
                s.isActive,
                u.userid,
                u.firstname,
                u.lastname
            FROM 
                shareTokens s
            INNER JOIN 
                taousers u ON s.userID = u.userID
            WHERE 
                s.token = <cfqueryparam value="#url.shareToken#" cfsqltype="cf_sql_varchar">
                AND s.isActive = 1
                AND (s.expiryDate IS NULL OR s.expiryDate >= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">)
        </cfquery>
        
        <cfif qValidateToken.recordCount gt 0>
            <!--- Set token user in request scope --->
            <cfset request.shareUserID = qValidateToken.userID />
            <cfset request.shareType = qValidateToken.shareType />
            <cfset request.shareDisplayName = qValidateToken.firstname & " " & qValidateToken.lastname />
            <cfset new_userid = qValidateToken.userID />
            
            <!--- Log this view --->
            <cfquery datasource="#application.dsn#">
                INSERT INTO shareViews (
                    shareID,
                    viewDate,
                    ipAddress
                ) VALUES (
                    <cfqueryparam value="#qValidateToken.shareID#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                    <cfqueryparam value="#cgi.remote_addr#" cfsqltype="cf_sql_varchar">
                )
            </cfquery>
            
            <!--- Load appropriate content based on share type --->
            <cfif request.shareType eq "relationships">
                <cfinclude template="relationships_shared.cfm" />
                <cfabort>
            <cfelseif request.shareType eq "calendar">
                <cfinclude template="calendar_shared.cfm" />
                <cfabort>
            <cfelse>
                <!--- Default to legacy view if type not recognized --->
                <cfinclude template="pgload.cfm" />
                <cfabort>
            </cfif>
        <cfelse>
            <cfinclude template="invalid_token.cfm" />
            <cfabort>
        </cfif>
        
    <cfcatch>
        <!--- If the shareTokens table doesn't exist, just continue with the regular flow --->
        <cfset new_userid = 0 />
    </cfcatch>
    </cftry>
</cfif>
