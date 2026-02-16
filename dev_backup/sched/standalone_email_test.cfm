<!---
    PURPOSE: Standalone email test without Application.cfc dependencies
    AUTHOR: Kevin King
    DATE: 2025-08-29
    DESCRIPTION: Test email with direct SMTP settings
--->

<cfparam name="url.send" default="0" />

<html>
<head>
    <title>Standalone Email Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        .info { background: #f0f0f0; padding: 10px; margin: 10px 0; }
        .settings { background: #e8f4fd; padding: 10px; margin: 10px 0; }
    </style>
</head>
<body>

<h1>Standalone Email Test</h1>

<div class="info">
    <strong>Current Environment:</strong> <cfoutput>#ListFirst(cgi.server_name, ".")#</cfoutput><br>
    <strong>Time:</strong> <cfoutput>#dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss")#</cfoutput><br>
    <strong>Server:</strong> <cfoutput>#cgi.server_name#</cfoutput><br>
    <strong>Test Type:</strong> No Application.cfc dependencies
</div>

<cfif url.send EQ 1>
    <h2>Sending Test Email...</h2>
    
    <div class="settings">
        <strong>SMTP Settings Used:</strong><br>
        Server: localhost (127.0.0.1)<br>
        Port: 25<br>
        Authentication: None<br>
        SSL/TLS: Disabled<br>
        Signing/Encryption: Disabled
    </div>
    
    <cftry>
        <cfmail 
            server="127.0.0.1"
            port="25"
            username=""
            password=""
            useSSL="false"
            useTLS="false"
            from="test@theactorsoffice.com" 
            to="kevinking7135@gmail.com"
            subject="Standalone Email Test - #dateTimeFormat(now(), 'yyyy-mm-dd HH:nn:ss')#" 
            type="text">
This is a standalone email test (no Application.cfc).

Server: #cgi.server_name#
Time: #dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss")#
Environment: #ListFirst(cgi.server_name, ".")#
Test Method: Direct SMTP settings in cfmail tag

If you receive this, basic email functionality is working.
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
            <strong>Type:</strong> #cfcatch.type#<br>
            <cfif structKeyExists(cfcatch, "errorCode")>
                <strong>Error Code:</strong> #cfcatch.errorCode#<br>
            </cfif>
        </div>
        
        <cfif structKeyExists(cfcatch, "stackTrace")>
            <h3>Stack Trace:</h3>
            <pre style="background: #fff; border: 1px solid #ccc; padding: 10px; overflow: auto;">#cfcatch.stackTrace#</pre>
        </cfif>
    </cfcatch>
    </cftry>
    
    <hr>
    <p><a href="standalone_email_test.cfm">Test Again</a></p>
    
<cfelse>
    <h2>Ready to Test Email</h2>
    <div class="settings">
        <strong>This test will use:</strong><br>
        • Direct SMTP settings in the cfmail tag<br>
        • localhost (127.0.0.1) on port 25<br>
        • No authentication<br>
        • No SSL/TLS/signing/encryption<br>
        • No Application.cfc dependencies
    </div>
    
    <p>This will send a test email to kevinking7135@gmail.com</p>
    <p><a href="standalone_email_test.cfm?send=1" style="background: #007cba; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Send Standalone Test Email</a></p>
</cfif>

</body>
</html>
