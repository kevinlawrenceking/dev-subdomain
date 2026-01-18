<!--- 
    PURPOSE: Test page for share system
    AUTHOR: GitHub Copilot
    DATE: 2025-07-19
--->

<!DOCTYPE html>
<html>
<head>
    <title>Share System Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
        .container { max-width: 800px; margin: 0 auto; }
        .section { margin-bottom: 40px; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }
        h1 { color: #333; }
        h2 { color: #555; margin-top: 30px; }
        ul { padding-left: 20px; }
        li { margin-bottom: 10px; }
        .code { 
            background: #f5f5f5; 
            padding: 15px; 
            border-radius: 5px; 
            font-family: monospace;
            overflow-x: auto;
        }
        .button {
            display: inline-block;
            padding: 10px 15px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            margin-right: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Share System Test Page</h1>
        
        <div class="section">
            <h2>1. Testing Legacy System</h2>
            <p>To test the legacy system using the password hash method:</p>
            
            <cfquery name="getUsers" datasource="#application.dsn#">
                SELECT 
                    userid, 
                    firstname, 
                    lastname, 
                    left(passwordhash,10) as share_token
                FROM 
                    taousers
                ORDER BY 
                    lastname, firstname
                LIMIT 10
            </cfquery>
            
            <cfif getUsers.recordCount gt 0>
                <h3>Available Test Users:</h3>
                <ul>
                    <cfoutput query="getUsers">
                        <li>
                            <strong>#firstname# #lastname#</strong> (ID: #userid#)<br>
                            Legacy URL: <a href="index.cfm?uid=#share_token#" target="_blank">index.cfm?uid=#share_token#</a>
                        </li>
                    </cfoutput>
                </ul>
            <cfelse>
                <p>No users found in the database.</p>
            </cfif>
        </div>
        
        <div class="section">
            <h2>2. Testing New Token System</h2>
            <p>To test the new token system, you need to generate tokens first:</p>
            
            <a href="generate_token.cfm" class="button">Generate Test Tokens</a>
            
            <h3>How to use the token generator:</h3>
            <ul>
                <li>Go to <code>generate_token.cfm</code> to create a blank form</li>
                <li>Specify a user ID using: <code>generate_token.cfm?userId=1</code></li>
                <li>Optionally specify share type: <code>generate_token.cfm?userId=1&shareType=calendar</code></li>
            </ul>
            
            <h3>Available Share Types:</h3>
            <ul>
                <li><code>relationships</code> - Shows contacts and relationships</li>
                <li><code>calendar</code> - Shows calendar events</li>
            </ul>
            
            <cfquery name="getTokens" datasource="#application.dsn#">
                SELECT 
                    s.shareID,
                    s.userID, 
                    s.token,
                    s.shareType,
                    s.createdDate,
                    s.expiryDate,
                    u.firstname,
                    u.lastname
                FROM 
                    shareTokens s
                INNER JOIN
                    taousers u ON s.userID = u.userID
                WHERE
                    s.isActive = 1
                ORDER BY 
                    s.createdDate DESC
                LIMIT 10
            </cfquery>
            
            <cfif isDefined("getTokens") AND getTokens.recordCount gt 0>
                <h3>Recently Generated Tokens:</h3>
                <ul>
                    <cfoutput query="getTokens">
                        <li>
                            <strong>#firstname# #lastname#</strong> (Type: #shareType#)<br>
                            Created: #DateFormat(createdDate, "yyyy-mm-dd")#<br>
                            URL: <a href="index.cfm?shareToken=#token#" target="_blank">index.cfm?shareToken=#token#</a>
                        </li>
                    </cfoutput>
                </ul>
            <cfelse>
                <p>No tokens found in the database yet.</p>
            </cfif>
        </div>
        
        <div class="section">
            <h2>3. Instructions</h2>
            <p>Follow these steps to test the share system:</p>
            <ol>
                <li>Test legacy URLs using the links above</li>
                <li>Generate new tokens using the generator</li>
                <li>Test the new token system with generated links</li>
                <li>Check error handling with an invalid token: <a href="index.cfm?shareToken=invalid123" target="_blank">Test Invalid Token</a></li>
            </ol>
        </div>
    </div>
</body>
</html>
