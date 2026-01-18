<!---
    PURPOSE: Capture IPN (Instant Payment Notification) data and email for debugging
    AUTHOR: Kevin King
    DATE: 2025-07-22
    PARAMETERS: None (receives POST data)
    DEPENDENCIES: Application.cfc for email settings
--->

<cftry>
    <!--- Get all HTTP request data --->
    <cfset httpData = getHttpRequestData()>
    <cfset rawPostData = httpData.content>
    <cfset httpHeaders = httpData.headers>
    
    <!--- Get current timestamp for logging --->
    <cfset currentTime = now()>
    
    <!--- Parse rawPostData into a struct if it's form-encoded --->
    <cfset paramStruct = {}>
    
    <!--- Check if data is JSON or form-encoded --->
    <cfset contentType = "">
    <cfif structKeyExists(httpHeaders, "content-type")>
        <cfset contentType = httpHeaders["content-type"]>
    </cfif>
    
    <!--- Try to parse as form data first --->
    <cfif len(trim(rawPostData)) and find("=", rawPostData)>
        <cfloop list="#rawPostData#" delimiters="&" index="pair">
            <cfif find("=", pair)>
                <cfset key = listFirst(pair, "=")>
                <cfset value = urlDecode(listRest(pair, "="))>
                <cfset paramStruct[key] = value>
            </cfif>
        </cfloop>
    </cfif>
    
    <!--- Prepare email content with all captured data --->
    <cfset emailBody = "">
    <cfset emailBody = emailBody & "<h2>IPN Cancelled Notification - " & dateFormat(currentTime, "mm/dd/yyyy") & " " & timeFormat(currentTime, "hh:mm:ss tt") & "</h2>">
    <cfset emailBody = emailBody & "<hr>">
    
    <!--- Raw POST Data --->
    <cfset emailBody = emailBody & "<h3>Raw POST Data:</h3>">
    <cfset emailBody = emailBody & "<pre>" & htmlEditFormat(rawPostData) & "</pre>">
    <cfset emailBody = emailBody & "<hr>">
    
    <!--- Content Type --->
    <cfset emailBody = emailBody & "<h3>Content Type:</h3>">
    <cfset emailBody = emailBody & "<p>" & htmlEditFormat(contentType) & "</p>">
    <cfset emailBody = emailBody & "<hr>">
    
    <!--- HTTP Headers --->
    <cfset emailBody = emailBody & "<h3>HTTP Headers:</h3>">
    <cfset emailBody = emailBody & "<ul>">
    <cfloop collection="#httpHeaders#" item="headerName">
        <cfset emailBody = emailBody & "<li><strong>" & htmlEditFormat(headerName) & ":</strong> " & htmlEditFormat(httpHeaders[headerName]) & "</li>">
    </cfloop>
    <cfset emailBody = emailBody & "</ul>">
    <cfset emailBody = emailBody & "<hr>">
    
    <!--- Parsed Parameters (if any) --->
    <cfset emailBody = emailBody & "<h3>Parsed Parameters:</h3>">
    <cfif structCount(paramStruct) gt 0>
        <cfset emailBody = emailBody & "<ul>">
        <cfloop collection="#paramStruct#" item="paramName">
            <cfset emailBody = emailBody & "<li><strong>" & htmlEditFormat(paramName) & ":</strong> " & htmlEditFormat(paramStruct[paramName]) & "</li>">
        </cfloop>
        <cfset emailBody = emailBody & "</ul>">
    <cfelse>
        <cfset emailBody = emailBody & "<p>No form parameters found (data may be JSON or other format)</p>">
    </cfif>
    <cfset emailBody = emailBody & "<hr>">
    
    <!--- CGI Variables for additional context --->
    <cfset emailBody = emailBody & "<h3>Request Info:</h3>">
    <cfset emailBody = emailBody & "<ul>">
    <cfset emailBody = emailBody & "<li><strong>Remote Address:</strong> " & htmlEditFormat(cgi.remote_addr) & "</li>">
    <cfset emailBody = emailBody & "<li><strong>User Agent:</strong> " & htmlEditFormat(cgi.http_user_agent) & "</li>">
    <cfset emailBody = emailBody & "<li><strong>Request Method:</strong> " & htmlEditFormat(cgi.request_method) & "</li>">
    <cfset emailBody = emailBody & "<li><strong>Query String:</strong> " & htmlEditFormat(cgi.query_string) & "</li>">
    <cfset emailBody = emailBody & "</ul>">
    
    <!--- Configure your email address here --->
    <cfset debugEmail = "kevin@theactorsoffice.com"> <!--- CHANGE THIS TO YOUR EMAIL --->
    
    <!--- Send email notification --->
    <cfmail 
        to="#debugEmail#" 
        from="noreply@theactorsoffice.com" 
        subject="IPN Cancelled Debug Data - #dateFormat(currentTime, 'mm/dd/yyyy')# #timeFormat(currentTime, 'hh:mm:ss tt')#"
        type="html">
        #emailBody#
    </cfmail>
    
    <!--- Log to file as backup --->
    <cflog file="ipn_cancelled_debug" text="IPN Cancelled received at #currentTime# from #cgi.remote_addr# - Data: #rawPostData#">
    
<cfcatch>
    <!--- Log any errors --->
    <cflog file="ipn_errors" text="IPN Cancelled Error: #cfcatch.message# - Detail: #cfcatch.detail#">
    
    <!--- Try to email error info --->
    <cftry>
        <cfmail 
            to="#debugEmail#" 
            from="noreply@theactorsoffice.com" 
            subject="IPN Cancelled Processing Error"
            type="html">
            <h2>Error Processing IPN Cancelled</h2>
            <p><strong>Error:</strong> #htmlEditFormat(cfcatch.message)#</p>
            <p><strong>Detail:</strong> #htmlEditFormat(cfcatch.detail)#</p>
            <p><strong>Time:</strong> #now()#</p>
            <p><strong>Raw Data:</strong> #htmlEditFormat(rawPostData)#</p>
        </cfmail>
    <cfcatch>
        <!--- If email fails, just log it --->
        <cflog file="ipn_errors" text="Failed to send error email: #cfcatch.message#">
    </cfcatch>
    </cftry>
</cfcatch>
</cftry>

<cfoutput>OK</cfoutput>
