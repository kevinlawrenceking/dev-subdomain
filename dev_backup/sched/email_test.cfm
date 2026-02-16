<!---
    PURPOSE: Test email functionality
    AUTHOR: Kevin King
    DATE: 2025-08-29
    DESCRIPTION: Simple test to verify email is working
--->

<cfparam name="url.send" default="0" />

<html>
<head>
    <title>Email Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        .info { background: #f0f0f0; padding: 10px; margin: 10px 0; }
    </style>
</head>
<body>

<h1>Email Test Page</h1>

<div class="info">
    <strong>Current Environment:</strong> <cfoutput>#ListFirst(cgi.server_name, ".")#</cfoutput><br>
    <strong>Time:</strong> <cfoutput>#dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss")#</cfoutput><br>
    <strong>Server:</strong> <cfoutput>#cgi.server_name#</cfoutput>
</div>

<cfif url.send EQ 1>
    <h2>Sending Test Email...</h2>
    
    <cftry>
        <cfmail 
      
            to="kevinking7135@gmail.com"
            subject="Test Email from TAO Scheduler - #dateTimeFormat(now(), 'yyyy-mm-dd HH:nn:ss')#" 
            type="text">
This is a test email from the TAO scheduler system.

Server: #cgi.server_name#
Time: #dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss")#
Environment: #ListFirst(cgi.server_name, ".")#

If you receive this, email is working correctly.
        </cfmail>
        
        <div class="success">
            ✓ Email sent successfully!<br>
            Check kevinking7135@gmail.com for the test message.
        </div>
        
    <cfcatch type="any">
        <div class="error">
            ✗ Email failed to send:<br>
            <strong>Error:</strong> #cfcatch.message#<br>
            <cfif len(cfcatch.detail)>
                <strong>Detail:</strong> #cfcatch.detail#<br>
            </cfif>
            <strong>Type:</strong> #cfcatch.type#
        </div>
        
        <cflog file="email_test_errors" 
               text="Email test failed: #cfcatch.message# - #cfcatch.detail#" 
               type="error" />
    </cfcatch>
    </cftry>
    
    <hr>
    <p><a href="email_test.cfm">Test Again</a></p>
    
<cfelse>
    <h2>Ready to Test Email</h2>
    <p>This will send a test email to kevinking7135@gmail.com</p>
    <p><a href="email_test.cfm?send=1" style="background: #007cba; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Send Test Email</a></p>
</cfif>

</body>
</html>
