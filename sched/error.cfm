<cfparam name="errorInfo" default="" />
<cfparam name="devEmail" default="kevinking7135@gmail.com" />
<cfparam name="showDebugInfo" default="false" />

<!--- Log all errors for analysis --->
<cfset errorLogID = createUUID() />

<cftry>
    <!--- Capture error info from available scopes --->
    <cfif isDefined("ERROR")>
        <cfset errorInfo = ERROR>
    <cfelseif isDefined("cfcatch")>
        <cfset errorInfo = cfcatch>
    <cfelseif isDefined("request.error")>
        <cfset errorInfo = request.error>
    </cfif>
    
    <!--- Prepare error email content --->
    <cfsavecontent variable="errorEmailContent">
        <cfoutput>
        <h2>Error Details (ID: #errorLogID#)</h2>
        
        <h3>Error Message:</h3>
        <p>#encodeForHtml(errorInfo.message)#</p>
        
        <cfif structKeyExists(errorInfo, "detail")>
            <h3>Detail:</h3>
            <pre>#encodeForHtml(errorInfo.detail)#</pre>
        </cfif>
        
        <h3>Request Information:</h3>
        <ul>
            <li><strong>Timestamp:</strong> #dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss")#</li>
            <li><strong>Page:</strong> #cgi.script_name#</li>
            <li><strong>Query String:</strong> #cgi.query_string#</li>
            <li><strong>Remote IP:</strong> #cgi.remote_addr#</li>
            <li><strong>User Agent:</strong> #cgi.http_user_agent#</li>
            <li><strong>Referrer:</strong> #cgi.http_referer#</li>
        </ul>
        
        <cfif structKeyExists(errorInfo, "stackTrace")>
            <h3>Stack Trace:</h3>
            <pre>#encodeForHtml(errorInfo.stackTrace)#</pre>
        </cfif>
        
        <cfif structKeyExists(errorInfo, "tagContext") AND isArray(errorInfo.tagContext)>
            <h3>Tag Context:</h3>
            <cfloop array="#errorInfo.tagContext#" index="tc">
                <p><strong>File:</strong> #tc.template# (Line: #tc.line#)</p>
                <cfif structKeyExists(tc, "codePrintPlain")>
                    <pre>#encodeForHtml(tc.codePrintPlain)#</pre>
                </cfif>
            </cfloop>
        </cfif>
        
        <cfif isDefined("session") AND isStruct(session)>
            <h3>Session Information:</h3>
            <ul>
                <cfif structKeyExists(session, "userid")>
                    <li><strong>User ID:</strong> #session.userid#</li>
                </cfif>
                <cfif structKeyExists(session, "loggedin")>
                    <li><strong>Logged In:</strong> #session.loggedin#</li>
                </cfif>
            </ul>
        </cfif>
        </cfoutput>
    </cfsavecontent>
    
    <!--- Send error email to developer --->
    <cfmail to="#devEmail#" 
            from="support@theactorsoffice.com" 
            subject="TAO Error: #left(errorInfo.message, 100)#" 
            type="html">
        #errorEmailContent#
    </cfmail>
    
    <!--- Log detailed error to file --->
    <cflog file="TAO_errors" 
           text="Error ID: #errorLogID# - #errorInfo.message# - Page: #cgi.script_name#" 
           type="error" />
    
    <!--- Display user-friendly error page --->
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>The Actor's Office - Something Went Wrong</title>
        <style>
            body {
                font-family: 'Helvetica Neue', Arial, sans-serif;
                line-height: 1.6;
                color: #333;
                max-width: 800px;
                margin: 0 auto;
                padding: 20px;
                text-align: center;
            }
            .error-container {
                background-color: #fff;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                padding: 40px;
                margin-top: 50px;
            }
            .logo-container {
                background-color: #406E8E;
                padding: 20px;
                border-radius: 8px 8px 0 0;
                margin: -40px -40px 30px -40px;
                display: flex;
                justify-content: center;
                align-items: center;
            }
            .logo {
                max-width: 200px;
            }
            h1 {
                color: #e74c3c;
                font-weight: 500;
                margin-bottom: 20px;
            }
            .error-message {
                font-size: 18px;
                margin-bottom: 30px;
            }
            .error-id {
                color: #7f8c8d;
                font-size: 14px;
                margin-top: 30px;
            }
            .btn {
                display: inline-block;
                background-color: #3498db;
                color: white;
                padding: 12px 25px;
                text-decoration: none;
                border-radius: 4px;
                font-weight: 500;
                margin: 10px;
                transition: background-color 0.2s;
            }
            .btn:hover {
                background-color: #2980b9;
            }
        </style>
    </head>
    <body>
        <div class="error-container">
            <div class="logo-container">
                <img src="/app/assets/images/taologo.png" alt="The Actor's Office" class="logo">
            </div>
            <h1>Oops! Something went wrong</h1>
            <div class="error-message">
                We apologize for the inconvenience. Our technical team has been notified and is working to resolve the issue.
            </div>
            <div>
                <a href="/" class="btn">Go to Homepage</a>
                <a href="javascript:history.back()" class="btn">Go Back</a>
            </div>
            <div class="error-id">
                Error ID: #errorLogID#
            </div>
        </div>
        
        <!--- Detailed error information (only shown in development) --->
        <cfif showDebugInfo>
            <div style="text-align: left; margin-top: 50px; padding: 20px; border: 1px solid #ddd; background: #f9f9f9;">
                <h3>Developer Debug Information</h3>
                <p><strong>Error:</strong> #encodeForHtml(errorInfo.message)#</p>
                
                <cfif structKeyExists(errorInfo, "detail")>
                    <p><strong>Detail:</strong> #encodeForHtml(errorInfo.detail)#</p>
                </cfif>
                
                <cfif structKeyExists(errorInfo, "tagContext") AND isArray(errorInfo.tagContext) AND arrayLen(errorInfo.tagContext)>
                    <p><strong>Location:</strong> #errorInfo.tagContext[1].template# (Line: #errorInfo.tagContext[1].line#)</p>
                </cfif>
            </div>
        </cfif>
    </body>
    </html>
    
    <cfcatch>
        <cfoutput>
            <h2>Error in Error Handler</h2>
            <p>A secondary error occurred while processing the original error:</p>
            <p>#cfcatch.message#</p>
            <cfif structKeyExists(cfcatch, "detail")>
                <p>#cfcatch.detail#</p>
            </cfif>
            
            <cflog file="TAO_errors" 
                   text="Error in error handler: #cfcatch.message#" 
                   type="error" />
        </cfoutput>
    </cfcatch>
</cftry>
