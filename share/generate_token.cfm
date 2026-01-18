<!--- 
    PURPOSE: Generate a test token for the share system
    AUTHOR: GitHub Copilot
    DATE: 2025-07-19
--->

<!--- Make sure Application.cfc is initialized --->
<cfif not structKeyExists(application, "dsn")>
    <cfset onApplicationStart() />
</cfif>

<!--- Parameters --->
<cfparam name="url.userId" default="0" />
<cfparam name="url.shareType" default="relationships" />
<cfparam name="url.expiryDays" default="30" />

<cfif url.userId eq 0>
    <h2>Please specify a userId</h2>
    <p>Example: generate_token.cfm?userId=1&shareType=relationships&expiryDays=30</p>
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
    </cfcatch>
</cftry>

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
        <cfqueryparam value="#url.userId#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#token#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#url.shareType#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">,
        <cfqueryparam value="#DateAdd('d', url.expiryDays, Now())#" cfsqltype="cf_sql_timestamp">,
        <cfqueryparam value="1" cfsqltype="cf_sql_integer">
    )
</cfquery>

<!--- Get the user info --->
<cfquery name="userInfo" datasource="#application.dsn#">
    SELECT userfirstname, userlastname
    FROM taousers
    WHERE userid = <cfqueryparam value="#url.userId#" cfsqltype="cf_sql_integer">
</cfquery>

<!DOCTYPE html>
<html>
<head>
    <title>Share Token Generated</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
        .container { max-width: 800px; margin: 0 auto; }
        .success { color: green; padding: 10px; background: #e8f5e9; border-radius: 5px; }
        .url-box { 
            background: #f5f5f5; 
            padding: 15px; 
            border-radius: 5px; 
            font-family: monospace;
            word-break: break-all;
            margin: 20px 0;
        }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Share Token Generated</h1>
        
        <div class="success">
            <strong>Success!</strong> A new share token has been created.
        </div>
        
        <h2>Token Details</h2>
        <table>
            <tr>
                <th>User</th>
                <td><cfoutput>#userInfo.userfirstname# #userInfo.userlastname# (ID: #url.userId#)</cfoutput></td>
            </tr>
            <tr>
                <th>Share Type</th>
                <td><cfoutput>#url.shareType#</cfoutput></td>
            </tr>
            <tr>
                <th>Token</th>
                <td><cfoutput>#token#</cfoutput></td>
            </tr>
            <tr>
                <th>Created</th>
                <td><cfoutput>#DateFormat(Now(), "yyyy-mm-dd")# #TimeFormat(Now(), "HH:mm:ss")#</cfoutput></td>
            </tr>
            <tr>
                <th>Expires</th>
                <td><cfoutput>#DateFormat(DateAdd('d', url.expiryDays, Now()), "yyyy-mm-dd")# #TimeFormat(DateAdd('d', url.expiryDays, Now()), "HH:mm:ss")#</cfoutput></td>
            </tr>
        </table>
        
        <h2>Share URL</h2>
        <p>Use this URL to share the content:</p>
        <div class="url-box">
            <cfoutput>https://dev.theactorsoffice.com/share/?shareToken=#token#</cfoutput>
        </div>
        
        <h2>Test Links</h2>
        <ul>
            <li><a href="<cfoutput>https://dev.theactorsoffice.com/share/?shareToken=#token#</cfoutput>" target="_blank">Open in new window</a></li>
            <li><a href="<cfoutput>index.cfm?shareToken=#token#</cfoutput>">Open in this window</a></li>
        </ul>
    </div>
</body>
</html>
