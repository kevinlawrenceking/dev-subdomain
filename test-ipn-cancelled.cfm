<!---
    PURPOSE: Test the ipn-cancelled.cfm handler
    AUTHOR: Kevin King
    DATE: 2025-07-22
    PARAMETERS: None
    DEPENDENCIES: ipn-cancelled.cfm
--->

<h2>IPN Cancelled Handler Test</h2>

<cfif structKeyExists(form, "testData") OR structKeyExists(url, "auto")>
    
    <h3>Sending Test Data...</h3>
    
    <!--- Prepare test data --->
    <cfif structKeyExists(form, "testData")>
        <cfset testData = form.testData>
    <cfelse>
        <!--- Default test data for auto test --->
        <cfset testData = "txn_type=subscr_cancel&subscr_id=I-BW452GLLEP1G&payment_status=Cancelled&mc_gross=29.99&mc_currency=USD&payer_email=test@example.com&payer_id=TESTBUYERID01&custom=user123&item_name=TAO Subscription&item_number=TAO001">
    </cfif>
    
    <!--- Make HTTP POST request to the IPN handler --->
    <cfhttp url="http://#cgi.server_name##cgi.script_name#/../ipn-cancelled.cfm" 
            method="POST" 
            timeout="30">
        <cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded">
        <cfhttpparam type="header" name="User-Agent" value="PayPal IPN Test">
        <cfhttpparam type="body" value="#testData#">
    </cfhttp>
    
    <cfoutput>
        <div class="alert alert-info">
            <h4>Test Results:</h4>
            <p><strong>Status Code:</strong> #cfhttp.statusCode#</p>
            <p><strong>Response:</strong> #htmlEditFormat(cfhttp.fileContent)#</p>
            <p><strong>Test Data Sent:</strong></p>
            <pre>#htmlEditFormat(testData)#</pre>
        </div>
        
        <p><strong>Check your email for the debug notification!</strong></p>
    </cfoutput>
    
<cfelse>

    <!--- Show test form --->
    <form method="post">
        <div class="form-group">
            <label for="testData"><strong>Test Data (form-encoded format):</strong></label>
            <textarea name="testData" id="testData" rows="8" cols="80" class="form-control">txn_type=subscr_cancel&subscr_id=I-BW452GLLEP1G&payment_status=Cancelled&mc_gross=29.99&mc_currency=USD&payer_email=test@example.com&payer_id=TESTBUYERID01&custom=user123&item_name=TAO Subscription&item_number=TAO001</textarea>
        </div>
        <button type="submit" class="btn btn-primary">Send Test IPN</button>
    </form>
    
    <hr>
    
    <h3>Quick Tests:</h3>
    <ul>
        <li><a href="?auto=1" class="btn btn-success">Auto Test with Sample Data</a></li>
        <li><a href="#" onclick="testJSON()" class="btn btn-warning">Test with JSON Data</a></li>
        <li><a href="#" onclick="testEmpty()" class="btn btn-secondary">Test with Empty Data</a></li>
    </ul>

</cfif>

<script>
function testJSON() {
    // Create a form to submit JSON data
    var form = document.createElement('form');
    form.method = 'POST';
    form.action = '';
    
    var input = document.createElement('textarea');
    input.name = 'testData';
    input.value = '{"txn_type":"subscr_cancel","subscr_id":"I-BW452GLLEP1G","payment_status":"Cancelled","mc_gross":"29.99","payer_email":"test@example.com"}';
    
    form.appendChild(input);
    document.body.appendChild(form);
    form.submit();
}

function testEmpty() {
    // Test with empty data
    var form = document.createElement('form');
    form.method = 'POST';
    form.action = '';
    
    var input = document.createElement('textarea');
    input.name = 'testData';
    input.value = '';
    
    form.appendChild(input);
    document.body.appendChild(form);
    form.submit();
}
</script>

<style>
.alert {
    padding: 15px;
    margin: 20px 0;
    border: 1px solid transparent;
    border-radius: 4px;
}
.alert-info {
    color: #31708f;
    background-color: #d9edf7;
    border-color: #bce8f1;
}
.btn {
    display: inline-block;
    padding: 6px 12px;
    margin: 5px;
    font-size: 14px;
    text-decoration: none;
    border: 1px solid transparent;
    border-radius: 4px;
    cursor: pointer;
}
.btn-primary { background-color: #007bff; color: white; }
.btn-success { background-color: #28a745; color: white; }
.btn-warning { background-color: #ffc107; color: black; }
.btn-secondary { background-color: #6c757d; color: white; }
.form-control {
    width: 100%;
    padding: 8px;
    border: 1px solid #ccc;
    border-radius: 4px;
}
.form-group {
    margin-bottom: 15px;
}
</style>
