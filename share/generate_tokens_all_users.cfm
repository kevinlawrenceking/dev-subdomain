<!--- 
    PURPOSE: Generate tokens for all users in the taousers table
    AUTHOR: Kevin King
    DATE: 2025-08-14
--->

<!--- Require authenticated session for admin token generation --->
<cfif NOT structKeyExists(session, "userid")>
    <cfheader statuscode="403">
    <cfabort>
</cfif>

<!--- Make sure Application.cfc is initialized --->
<cfif not structKeyExists(application, "dsn")>
    <cfset onApplicationStart() />
</cfif>

<!--- Parameters --->
<cfparam name="url.shareType" default="relationships" />
<cfparam name="url.expiryDays" default="30" />
<cfparam name="url.confirm" default="false" />

<!--- Safety check: require confirmation --->
<cfif url.confirm neq "true">
    <!DOCTYPE html>
    <html>
    <head>
        <title>Generate Tokens for All Users - Confirmation Required</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
            .container { max-width: 800px; margin: 0 auto; }
            .warning { color: #d32f2f; padding: 15px; background: #ffebee; border-radius: 5px; border-left: 4px solid #d32f2f; }
            .btn { padding: 10px 20px; margin: 10px 5px; text-decoration: none; border-radius: 5px; display: inline-block; }
            .btn-primary { background: #1976d2; color: white; }
            .btn-secondary { background: #757575; color: white; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Generate Tokens for All Users</h1>
            
            <div class="warning">
                <strong>⚠️ Warning:</strong> This action will generate share tokens for ALL users in the taousers table.
                This could potentially create a large number of tokens. Please confirm you want to proceed.
            </div>
            
            <h2>Current Parameters</h2>
            <ul>
                <li><strong>Share Type:</strong> <cfoutput>#encodeForHTML(url.shareType)#</cfoutput></li>
                <li><strong>Expiry Days:</strong> <cfoutput>#encodeForHTML(url.expiryDays)#</cfoutput></li>
            </ul>
            
            <h2>Actions</h2>
            <a href="<cfoutput>?shareType=#encodeForURL(url.shareType)#&amp;expiryDays=#encodeForURL(url.expiryDays)#&amp;confirm=true</cfoutput>" class="btn btn-primary">
                ✓ Yes, Generate Tokens for All Users
            </a>
            <a href="generate_token.cfm" class="btn btn-secondary">
                ← Back to Single Token Generator
            </a>
        </div>
    </body>
    </html>
    <cfabort>
</cfif>

<!--- Create the share token table if it doesn't exist --->
<cftry>
    <cfquery datasource="#application.dsn#">
        CREATE TABLE IF NOT EXISTS shareTokens (
            shareID INT AUTO_INCREMENT PRIMARY KEY,
            userID INT NOT NULL,
            token VARCHAR(64) NOT NULL,
            shareType VARCHAR(32) NOT NULL,
            createdDate DATETIME NOT NULL,
            expiryDate DATETIME NULL,
            isActive TINYINT(1) NOT NULL DEFAULT 1,
            CONSTRAINT UC_ShareTokens_Token UNIQUE (token)
        );
    </cfquery>
    <cfcatch>
        <h2>Error creating table</h2>
        <p>The shareTokens table may already exist or you may not have permission to create it.</p>
        <p>Error: <cfoutput>#cfcatch.message#</cfoutput></p>
        <cfabort>
    </cfcatch>
</cftry>

<!--- Get all users from taousers table --->
<cfquery name="allUsers" datasource="#application.dsn#">
    SELECT userid, userfirstname, userlastname
    FROM taousers
    WHERE userid IS NOT NULL
    ORDER BY userid
</cfquery>

<!--- Initialize counters --->
<cfset tokensCreated = 0>
<cfset tokensSkipped = 0>
<cfset errors = ArrayNew(1)>

<!--- Loop through all users and generate tokens --->
<cfloop query="allUsers">
    <cftry>
        <!--- Check if user already has an active token for this shareType --->
        <cfquery name="existingToken" datasource="#application.dsn#">
            SELECT shareID
            FROM shareTokens
            WHERE userID = <cfqueryparam value="#allUsers.userid#" cfsqltype="cf_sql_integer">
            AND shareType = <cfqueryparam value="#url.shareType#" cfsqltype="cf_sql_varchar">
            AND isActive = 1
            AND (expiryDate IS NULL OR expiryDate > <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">)
        </cfquery>
        
        <cfif existingToken.recordCount eq 0>
            <!--- Generate a unique token --->
            <cfset token = CreateUUID() />
            <cfset token = Replace(token, "-", "", "all") />
            <cfset token = Left(token, 32) />
            
            <!--- Insert the token --->
            <cfquery name="insertToken" datasource="#application.dsn#">
                INSERT INTO shareTokens (
                    userID,
                    token,
                    shareType,
                    createdDate,
                    expiryDate,
                    isActive
                ) VALUES (
                    <cfqueryparam value="#allUsers.userid#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#token#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#url.shareType#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">,
                    <cfqueryparam value="#DateAdd('d', url.expiryDays, Now())#" cfsqltype="cf_sql_timestamp">,
                    <cfqueryparam value="1" cfsqltype="cf_sql_integer">
                )
            </cfquery>
            
            <cfset tokensCreated = tokensCreated + 1>
        <cfelse>
            <cfset tokensSkipped = tokensSkipped + 1>
        </cfif>
        
        <cfcatch>
            <cfset ArrayAppend(errors, "Error for User ID #allUsers.userid# (#allUsers.userfirstname# #allUsers.userlastname#): #cfcatch.message#")>
        </cfcatch>
    </cftry>
</cfloop>

<!DOCTYPE html>
<html>
<head>
    <title>Bulk Token Generation Complete</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
        .container { max-width: 1000px; margin: 0 auto; }
        .success { color: green; padding: 15px; background: #e8f5e9; border-radius: 5px; margin: 20px 0; }
        .warning { color: #f57c00; padding: 15px; background: #fff3e0; border-radius: 5px; margin: 20px 0; }
        .error { color: #d32f2f; padding: 15px; background: #ffebee; border-radius: 5px; margin: 20px 0; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
        .stats { display: flex; gap: 20px; margin: 20px 0; }
        .stat-box { 
            flex: 1; 
            padding: 20px; 
            background: #f5f5f5; 
            border-radius: 5px; 
            text-align: center; 
        }
        .stat-number { font-size: 2em; font-weight: bold; color: #1976d2; }
        .btn { padding: 10px 20px; margin: 10px 5px; text-decoration: none; border-radius: 5px; display: inline-block; }
        .btn-primary { background: #1976d2; color: white; }
        .btn-secondary { background: #757575; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Bulk Token Generation Complete</h1>
        
        <div class="success">
            <strong>✓ Process Complete!</strong> Token generation for all users has finished.
        </div>
        
        <div class="stats">
            <div class="stat-box">
                <div class="stat-number"><cfoutput>#allUsers.recordCount#</cfoutput></div>
                <div>Total Users</div>
            </div>
            <div class="stat-box">
                <div class="stat-number"><cfoutput>#tokensCreated#</cfoutput></div>
                <div>Tokens Created</div>
            </div>
            <div class="stat-box">
                <div class="stat-number"><cfoutput>#tokensSkipped#</cfoutput></div>
                <div>Tokens Skipped</div>
            </div>
            <div class="stat-box">
                <div class="stat-number"><cfoutput>#ArrayLen(errors)#</cfoutput></div>
                <div>Errors</div>
            </div>
        </div>
        
        <h2>Generation Details</h2>
        <table>
            <tr>
                <th>Share Type</th>
                <td><cfoutput>#encodeForHTML(url.shareType)#</cfoutput></td>
            </tr>
            <tr>
                <th>Expiry Days</th>
                <td><cfoutput>#encodeForHTML(url.expiryDays)#</cfoutput></td>
            </tr>
            <tr>
                <th>Generated At</th>
                <td><cfoutput>#DateFormat(Now(), "yyyy-mm-dd")# #TimeFormat(Now(), "HH:mm:ss")#</cfoutput></td>
            </tr>
            <tr>
                <th>Expires At</th>
                <td><cfoutput>#DateFormat(DateAdd('d', url.expiryDays, Now()), "yyyy-mm-dd")# #TimeFormat(DateAdd('d', url.expiryDays, Now()), "HH:mm:ss")#</cfoutput></td>
            </tr>
        </table>
        
        <cfif tokensSkipped gt 0>
            <div class="warning">
                <strong>Note:</strong> <cfoutput>#tokensSkipped#</cfoutput> tokens were skipped because those users already have active tokens for the "<cfoutput>#encodeForHTML(url.shareType)#</cfoutput>" share type.
            </div>
        </cfif>
        
        <cfif ArrayLen(errors) gt 0>
            <div class="error">
                <strong>⚠️ Errors Encountered:</strong>
                <ul>
                    <cfloop array="#errors#" index="error">
                        <li><cfoutput>#error#</cfoutput></li>
                    </cfloop>
                </ul>
            </div>
        </cfif>
        
        <h2>Actions</h2>
        <a href="test_share.cfm" class="btn btn-primary">
            🔍 Test Share Tokens
        </a>
        <a href="generate_token.cfm" class="btn btn-secondary">
            ← Back to Single Token Generator
        </a>
        
        <h2>Next Steps</h2>
        <p>Your tokens have been generated. Users can now access their shared content using URLs in this format:</p>
        <p><code>https://dev.theactorsoffice.com/share/?shareToken=[TOKEN]</code></p>
        
        <p>To view all generated tokens, you can query the shareTokens table directly or create a management interface.</p>
    </div>
</body>
</html>
