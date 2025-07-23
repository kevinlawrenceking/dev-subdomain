<!---
    PURPOSE: Command-line style testing for IPN handler
    AUTHOR: Kevin King
    DATE: 2025-07-22
    PARAMETERS: type, data
    DEPENDENCIES: ipn-cancelled.cfm
--->

<h2>IPN Handler Command-Line Style Test</h2>

<cfparam name="url.type" default="form">
<cfparam name="url.data" default="">

<cfswitch expression="#url.type#">
    
    <cfcase value="paypal">
        <!--- Simulate typical PayPal IPN data --->
        <cfset testData = "txn_type=subscr_cancel&subscr_id=I-BW452GLLEP1G&payment_status=Cancelled&mc_gross=29.99&mc_currency=USD&payer_email=test@paypal.com&payer_id=TESTBUYERID01&custom=user123&item_name=TAO Subscription&item_number=TAO001&notify_version=3.9&verify_sign=AFcWxV21C7fd0v3bYYYRCpSSRl31A7y-IpGaVq0L6.AzLhJrSA7P.zNL">
    </cfcase>
    
    <cfcase value="stripe">
        <!--- Simulate Stripe webhook data (JSON format) --->
        <cfset testData = '{"id":"evt_1234567890","object":"event","type":"customer.subscription.deleted","data":{"object":{"id":"sub_1234567890","status":"canceled","customer":"cus_1234567890"}},"created":1640995200}'>
    </cfcase>
    
    <cfcase value="square">
        <!--- Simulate Square webhook data --->
        <cfset testData = '{"merchant_id":"ML4EK6DN8RVCX","type":"subscription.canceled","event_id":"7f5f8078-04ab-4f1d-b64b-36e3a0bc1234","created_at":"2025-07-22T12:00:00Z","data":{"type":"subscription","id":"subscription_1234567890"}}'>
    </cfcase>
    
    <cfcase value="json">
        <!--- Generic JSON test --->
        <cfset testData = '{"transaction_type":"cancellation","subscription_id":"test_123","status":"cancelled","amount":"29.99","currency":"USD","user_id":"user123"}'>
    </cfcase>
    
    <cfcase value="custom">
        <!--- Use provided data --->
        <cfset testData = urlDecode(url.data)>
    </cfcase>
    
    <cfdefaultcase>
        <!--- Default form data --->
        <cfset testData = "txn_type=subscr_cancel&subscr_id=I-BW452GLLEP1G&payment_status=Cancelled">
    </cfdefaultcase>
    
</cfswitch>

<!--- Determine content type based on data format --->
<cfif left(trim(testData), 1) eq "{">
    <cfset contentType = "application/json">
<cfelse>
    <cfset contentType = "application/x-www-form-urlencoded">
</cfif>

<cfoutput>
<h3>Testing with: #url.type# format</h3>
<p><strong>Content-Type:</strong> #contentType#</p>
<p><strong>Data to send:</strong></p>
<pre style="background: ##f5f5f5; padding: 10px; border: 1px solid ##ddd;">#htmlEditFormat(testData)#</pre>
</cfoutput>

<!--- Make the HTTP request --->
<cfhttp url="http://#cgi.server_name##cgi.script_name#/../ipn-cancelled.cfm" 
        method="POST" 
        timeout="30">
    <cfhttpparam type="header" name="Content-Type" value="#contentType#">
    <cfhttpparam type="header" name="User-Agent" value="Test-Agent/1.0">
    <cfhttpparam type="body" value="#testData#">
</cfhttp>

<cfoutput>
<div style="margin: 20px 0; padding: 15px; background: ##e7f3ff; border: 1px solid ##b3d9ff;">
    <h4>Test Results:</h4>
    <p><strong>HTTP Status:</strong> #cfhttp.statusCode#</p>
    <p><strong>Response:</strong> #htmlEditFormat(cfhttp.fileContent)#</p>
    <p><strong>Response Time:</strong> #getTickCount() - variables.startTime# ms</p>
</div>

<p style="color: green; font-weight: bold;">✓ Test completed! Check your email for the debug notification.</p>

<hr>
<h3>Available Test URLs:</h3>
<ul>
    <li><a href="?type=paypal">PayPal IPN Format</a></li>
    <li><a href="?type=stripe">Stripe Webhook Format</a></li>
    <li><a href="?type=square">Square Webhook Format</a></li>
    <li><a href="?type=json">Generic JSON Format</a></li>
    <li><a href="?type=form">Form-encoded Format</a></li>
    <li><a href="?type=custom&data=custom_field%3Dtest_value%26another%3D123">Custom Data</a></li>
</ul>
</cfoutput>

<cfset variables.startTime = getTickCount()>
