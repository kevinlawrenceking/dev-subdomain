<!--- 
    PURPOSE: Handle loading of shared content for external viewing
    AUTHOR: Updated by GitHub Copilot
    DATE: 2025-07-19
    PARAMETERS: shareToken
    DEPENDENCIES: services.ContactItemService, services.ReminderService
--->

<cfparam name="url.shareToken" default="" />
<cfparam name="debug" default="NO">

<!--- Import debug settings from parent --->
<cfif isDefined("variables.debug") AND variables.debug eq "YES">
    <cfset debug = "YES">
</cfif>

<!--- Debug Helper Function --->
<cffunction name="debugDump" returntype="void" output="true">
    <cfargument name="label" type="string" required="true">
    <cfargument name="value" required="true">
    <cfif debug is "YES">
        <cfdump var="#arguments.value#" label="#arguments.label#">
        <hr>
    </cfif>
</cffunction>

<!--- Ensure we have access to the application datasource --->
<cfif not structKeyExists(application, "dsn")>
    <cfif debug is "YES"><cfoutput><p style="background:#ffe6e6;padding:5px;border:1px solid red">Application DSN not found, initializing...</p></cfoutput></cfif>
    <cfset onApplicationStart() />
</cfif>
<cfset dsn = application.dsn />

<!--- Debug information --->
<cfif debug is "YES">
    <div style="background:#e6e6ff;padding:10px;margin:10px 0;border:1px solid #9370db;">
        <h3>Remote Load Processing</h3>
        <ul>
            <li>Share Token: <cfoutput>#url.shareToken#</cfoutput></li>
            <li>DSN: <cfoutput>#dsn#</cfoutput></li>
        </ul>
    </div>
</cfif>

<!--- Validate share token if present --->
<cfif len(trim(url.shareToken)) gt 0>
    <!--- Check if the shareTokens table exists --->
    <cftry>
        <cfif debug is "YES">
            <div style="background:#f0f8ff;padding:10px;margin:10px 0;border:1px solid #add8e6;">
                <h3>ShareToken Validation</h3>
                <code style="display:block;background:#f8f8f8;padding:10px;white-space:pre-wrap;">
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
                        s.token = '<cfoutput>#url.shareToken#</cfoutput>'
                        AND s.isActive = 1
                        AND (s.expiryDate IS NULL OR s.expiryDate >= NOW())
                </code>
            </div>
        </cfif>
        
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
        
        <cfif debug is "YES">
            <div style="background:#e6e6ff;padding:10px;margin:10px 0;border:1px solid #9370db;">
                <h3>Token Validation Results</h3>
                <p>Records found: <cfoutput>#qValidateToken.recordCount#</cfoutput></p>
                <cfdump var="#qValidateToken#" label="Token Query Result">
            </div>
        </cfif>
        
        <cfif qValidateToken.recordCount gt 0>
            <!--- Set token user in request scope --->
            <cfset request.shareUserID = qValidateToken.userID />
            <cfset request.shareType = qValidateToken.shareType />
            <cfset request.shareDisplayName = qValidateToken.firstname & " " & qValidateToken.lastname />
            <cfset new_userid = qValidateToken.userID />
            
            <cfif debug is "YES">
                <div style="background:#e6ffe6;padding:10px;margin:10px 0;border:1px solid #90ee90;">
                    <h3>Token Valid - User Information</h3>
                    <ul>
                        <li>User ID: <cfoutput>#request.shareUserID#</cfoutput></li>
                        <li>Share Type: <cfoutput>#request.shareType#</cfoutput></li>
                        <li>User Name: <cfoutput>#request.shareDisplayName#</cfoutput></li>
                    </ul>
                </div>
            </cfif>
            
            <!--- Log this view --->
            <cfif debug is "YES">
                <div style="background:#f0f8ff;padding:10px;margin:10px 0;border:1px solid #add8e6;">
                    <h3>Logging View</h3>
                    <p>Inserting record into shareViews table:</p>
                    <ul>
                        <li>Share ID: <cfoutput>#qValidateToken.shareID#</cfoutput></li>
                        <li>Date: <cfoutput>#DateFormat(now(), "yyyy-mm-dd")# #TimeFormat(now(), "HH:mm:ss")#</cfoutput></li>
                        <li>IP Address: <cfoutput>#cgi.remote_addr#</cfoutput></li>
                    </ul>
                </div>
            </cfif>
            
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
            <cfif debug is "YES">
                <div style="background:#f0f8ff;padding:10px;margin:10px 0;border:1px solid #add8e6;">
                    <h3>Loading Content Template</h3>
                    <p>Share Type: <cfoutput>#request.shareType#</cfoutput></p>
                    <p>Template to Load: <cfoutput>#request.shareType eq "relationships" ? "relationships_shared.cfm" : (request.shareType eq "calendar" ? "calendar_shared.cfm" : "pgload.cfm")#</cfoutput></p>
                </div>
            </cfif>
            
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
            <cfif debug is "YES">
                <div style="background:#ffe6e6;padding:10px;margin:10px 0;border:1px solid red;">
                    <h3>Invalid Token</h3>
                    <p>The provided token is invalid, has expired, or has been deactivated.</p>
                    <p>Token: <cfoutput>#url.shareToken#</cfoutput></p>
                </div>
            </cfif>
            <cfinclude template="invalid_token.cfm" />
            <cfabort>
        </cfif>
        
    <cfcatch>
        <!--- If the shareTokens table doesn't exist, just continue with the regular flow --->
        <cfif debug is "YES">
            <div style="background:#ffe6e6;padding:10px;margin:10px 0;border:1px solid red;">
                <h3>Error Processing Token</h3>
                <p>There was an error processing the share token. The shareTokens table may not exist.</p>
                <cfdump var="#cfcatch#" label="Error Details">
            </div>
        </cfif>
        <cfset new_userid = 0 />
    </cfcatch>
    </cftry>
</cfif>
