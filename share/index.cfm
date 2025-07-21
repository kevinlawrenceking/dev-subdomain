<!--- 
    PURPOSE: Main entry point for share directory
    AUTHOR: Updated by GitHub Copilot
    DATE: 2025-07-19
    NOTES: Updated to use a more secure shareToken system
--->
<Cfset debug="no">
<cfparam name="url.shareToken" default="706C2C9EBECE60DA9F779903AC3FFE79" />
<cfparam name="url.u" default="" />  <!--- Keep legacy parameter for backward compatibility --->
<cfparam name="url.uid" default="" /> <!--- Original legacy parameter --->
<cfinclude template="remote_load_common.cfm" />
<!--- Debug Helper Function --->
<cffunction name="debugDump" returntype="void" output="true">
    <cfargument name="label" type="string" required="true">
    <cfargument name="value" required="true">
    <cfif debug is "YES">
        <cfdump var="#arguments.value#" label="#arguments.label#">
        <hr>
    </cfif>
</cffunction>
<!--- Ensure application variables are set --->
<cfif not structKeyExists(application, "dsn")>
    <cfif debug is "YES"><cfoutput><p class="alert alert-danger debug-info-sm">Application DSN not found, initializing...</p></cfoutput></cfif>
    <cfset onApplicationStart() />
</cfif>

<!--- Debug URL parameters --->
<cfif debug is "YES">
    <div class="debug-info info">
        <h3>URL Parameters</h3>
        <cfoutput>
            <ul>
                <li><strong>shareToken:</strong> #url.shareToken#</li>
                <li><strong>u:</strong> #url.u#</li>
                <li><strong>uid:</strong> #url.uid#</li>
            </ul>
        </cfoutput>
        
        <h3>Application Settings</h3>
        <cfdump var="#application#" label="Application Scope" expand="false">
    </div>
</cfif>

<!--- Handle new shareToken system --->
<cfif len(trim(url.shareToken)) gt 0>
    <cfif debug is "YES">
        <div class="debug-info success">
            <h3>Using New Token System</h3>
            <p>Token: <cfoutput>#url.shareToken#</cfoutput></p>
        </div>
    </cfif>
   
   
</cfif>

<!--- Legacy system handling --->
<cfif len(trim(url.u)) gt 0 OR len(trim(url.uid)) gt 0>
    <cfset session.userid = 0 />
    <cfparam name="refresh_yn" default="N" />
    <cfparam name="NEW_USERID" default="0" />
    <cfset legacy_token = len(trim(url.u)) gt 0 ? url.u : url.uid />
    
    <cfif debug is "YES">
        <div class="debug-info warning">
            <h3>Using Legacy Token System</h3>
            <p>Legacy token: <cfoutput>#legacy_token#</cfoutput></p>
            <p>Token source: <cfoutput>#len(trim(url.u)) gt 0 ? "u parameter" : "uid parameter"#</cfoutput></p>
            <p>Token length: <cfoutput>#len(legacy_token)#</cfoutput></p>
        </div>
    </cfif>
    <!--- Get user ID from legacy token --->
    <cfif debug is "YES">
        <div class="debug-info purple">
            <h3>SQL Query Information</h3>
            <p>Looking up user with token prefix: <cfoutput>#left(legacy_token,10)#</cfoutput></p>
            <code class="debug-code">
                SELECT 
                    left(t.UUID,10) as default_u,
                    u.userid 
                FROM 
                    taousers u inner join thrivecart t on t.id = u.customerid
                WHERE 
                    left(t.UUID,10) = '<cfoutput>#left(legacy_token,10)#</cfoutput>'
            </code>
        </div>
    </cfif>
    
    <cfquery name="default" datasource="#application.dsn#" maxrows="1">
        SELECT 
            left(t.UUID,10) as default_u,
            u.userid 
        FROM 
            taousers u inner join thrivecart t on t.id = u.customerid
        WHERE 
            left(t.UUID,10) = <cfqueryparam value="#left(legacy_token,10)#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfif debug is "YES">
        <div class="debug-info purple">
            <h3>Query Result</h3>
            <p>Records found: <cfoutput>#default.recordCount#</cfoutput></p>
            <cfdump var="#default#" label="Default Query Result">
        </div>
    </cfif>

    <cfif default.recordCount eq 0>
        <cfif debug is "YES">
            <div class="debug-info error">
                <h3>Authentication Failed</h3>
                <p>No user found with the provided token: <cfoutput>#legacy_token#</cfoutput></p>
                <p>Redirecting to invalid token page...</p>
            </div>
        </cfif>
        <cfinclude template="invalid_token.cfm" />
        <cfabort>
    </cfif>
    
    <cfset u = default.default_u />
    <cfset new_userid = default.userid />
    
    <cfif debug is "YES">
        <div class="debug-info success">
            <h3>Authentication Successful</h3>
            <p>User ID: <cfoutput>#new_userid#</cfoutput></p>
            <p>Token (u): <cfoutput>#u#</cfoutput></p>
        </div>
    </cfif>
    
    <!--- Include legacy page --->
    <cfif debug is "YES">
        <div class="debug-info info">
            <h3>Including Legacy Page</h3>
            <p>Template: pgload.cfm</p>
            <p>User ID: <cfoutput>#new_userid#</cfoutput></p>
        </div>
    </cfif>
 
<cfelse>
    <cfif debug is "YES">
        <div class="debug-info error">
            <h3>No Token Provided</h3>
            <p>Redirecting to main site...</p>
        </div>
    </cfif>
    <!--- No token provided - redirect to main site --->
    <cflocation url="https://theactorsoffice.com" addtoken="false" />
</cfif>

<cfif debug is "YES">
    <div class="debug-info purple">
        <h3>Shares Query</h3>
        <code class="debug-code">
            SELECT `contactid`,`Name`,`Company`,`Title`,`Audition`,`WhereMet`,`WhenMet`,`NotesLog`,`userid`,`u`
            FROM sharez where userid = <cfoutput>#new_userid#</cfoutput>
        </code>
    </div>
</cfif>

<cfquery name="shares" datasource="#application.dsn#">
SELECT `contactid`,`Name`,`Company`,`Title`,`Audition`,`WhereMet`,`WhenMet`,`NotesLog`,`userid`,`u`
FROM sharez where userid = <cfqueryparam value="#new_userid#" cfsqltype="cf_sql_integer">
</cfquery>

<cfif debug is "YES">
    <div class="debug-info purple">
        <h3>Shares Query Result</h3>
        <p>Records found: <cfoutput>#shares.recordCount#</cfoutput></p>
        <cfdump var="#shares#" label="Shares Query Result">
    </div>
</cfif>








<cfparam name="TAOVERSION" default="0" />
<!DOCTYPE html>
<html lang="en">

<head>
    <cfoutput>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <title>#appName# #shares.recordcount#| #pgTitle#</title>

    </cfoutput>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Source+Sans+Pro:wght@300&display=swap');
    </style>
    <!--- Include styles and scripts from FindLinksT query --->
    <cfif isDefined("FindLinksT") AND isQuery(FindLinksT)>
        <cfloop query="FindLinksT">
            <cfoutput>
                <cfif FindLinksT.linktype is "script">
                    <script src="#FindLinksT.linkurl#"></script>
                </cfif>

                <cfif FindLinksT.linktype is "script_include">
                    <script>
                        <cfinclude template = "#FindLinksT.linkurl#?rev=#RandRange(1, 1000000)#" >
                    </script>
                </cfif>
                <cfif FindLinksT.linktype is "css" or FindLinksT.linktype is "text/css" or FindLinksT.linktype is "ico">
                    <link href="#FindLinksT.linkurl#?rev=#RandRange(1, 1000000)#" 
                    <cfif len(trim(FindLinksT.rel))>rel="#FindLinksT.rel#"</cfif>
                    type="text/css" 
                    <cfif len(trim(FindLinksT.hrefid))>id="#FindLinksT.hrefid#"</cfif> />
                </cfif>
            </cfoutput>
        </cfloop>
    <cfelse>

        <!--- Fallback if FindLinksT query is not defined --->
        <link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/js/bootstrap.bundle.min.js"></script>
    </cfif>
    
    <style>
        /* Loading Spinner */
        .spinner {
            display: inline-block;
            width: 80px;
            height: 80px;
            border: 8px solid #f3f3f3;
            border-radius: 50%;
            border-top: 8px solid #3498db;
            animation: spin 2s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .loading {
            display: flex;
            justify-content: center;
            align-items: center;
            width: 100%;
            height: 100vh;
            position: absolute;
            top: 0;
            left: 0;
            background: rgba(255, 255, 255, 0.8);
            z-index: 9999;
        }

        /* Debug Panels */
        .debug-info {
            padding: 10px;
            margin: 10px 0;
            border: 1px solid;
            border-radius: 4px;
        }

        .debug-info.info {
            background: #f0f8ff;
            border-color: #add8e6;
        }

        .debug-info.success {
            background: #e6ffe6;
            border-color: #90ee90;
        }

        .debug-info.warning {
            background: #fff8e6;
            border-color: #ffd700;
        }

        .debug-info.error {
            background: #ffe6e6;
            border-color: #ff0000;
        }

        .debug-info.purple {
            background: #e6e6ff;
            border-color: #9370db;
        }

        .debug-info-sm {
            padding: 5px;
            border-radius: 3px;
        }

        .debug-info-lg {
            padding: 20px;
            margin: 20px 0;
        }

        .debug-code {
            display: block;
            background: #f8f8f8;
            padding: 10px;
            white-space: pre-wrap;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
            border: 1px solid #ddd;
        }

        /* Custom navbar colors */
        .navbar-custom.dev {
            background-color: #8b0000 !important;
        }

        .navbar-custom.production {
            background-color: var(--top-bar-color) !important;
        }

        /* Content spacing */
        .content-main {
            margin-top: 35px;
        }
    </style>

</head>

<body class="loading">
    

    
    
    <div id="wrapper">
        <cfif #host# is "dev">
            <div class="navbar-custom dev">
                <cfelse>
                    <div class="navbar-custom production" style="--top-bar-color: <cfoutput>#colorTopBar#</cfoutput>;">
        </cfif>
        <div class="container-fluid">
            <cfinclude template="topmenu_main.cfm" />
             <div class="logo-box">
            <a href="/app/" class="logo logo-dark text-center">
                <span class="logo-sm"><cfoutput
                    <img src="/media-#dsn#/images/logo-sm.png" alt="" height="30">
                    <!--- <span class="logo-lg-text-light">UBold</span> --->
                </cfoutput> </span>



                
<cfoutput>
 

                <span class="logo-lg">
                    <img src="/media-#dsn#/images/logo-sm.png" alt="" height="30">
                    <!--- <span class="logo-lg-text-light">U</span> --->
                </span>
            </a>
    
            <a href="/app/" class="logo logo-light text-center">
                <span class="logo-sm">
                    <img src="/media-#dsn#/images/logo-sm.png" alt="" height="30">
                </span>
                <span class="logo-lg">
                    <img src="/media-#dsn#/images/logo-light.png" alt="" height="30">
                </span>
            </a>

            </cfoutput>
        </div>
    
        </div>
        <div class="content-pag">
            <div class="content content-main">
                <div class="container-fluid">
                    <cfinclude template="share.cfm" />
                </div>
            </div>
            <cfparam name="pgdir" default="">
                <cfparam name="pgid" default="0" />
        </div>
    </div>
    <cfif isDefined("FindLinksB") AND isQuery(FindLinksB)>
        <cfloop query="FindLinksB">
            <cfoutput>
                <cfif FindLinksB.linktype is "script">
                    <script src="#FindLinksB.linkurl#?ver=#RandRange(1, 1000000)#"></script>
                </cfif>
                <cfif FindLinksB.linktype is "script_include">
                    <script>
                        <cfinclude template = "#FindLinksB.linkurl#?rev=#RandRange(1, 1000000)#" >
                    </script>
                </cfif>
                <cfif FindLinksB.linktype is "css" or FindLinksB.linktype is "text/css" or FindLinksB.linktype is "ico">
                    <link href="#FindLinksB.linkurl#?rev=#RandRange(1, 1000000)#" 
                          <cfif len(trim(FindLinksB.rel))>rel="#FindLinksB.rel#"</cfif>
                          type="text/css"
                                                    <cfif len(trim(FindLinksB.hrefid))>id="#FindLinksB.hrefid#"</cfif> />
                </cfif>
            </cfoutput>
        </cfloop>
    </cfif>
    
    <!--- Process shares modal views --->
    <cfif isDefined("shares") AND isQuery(shares)>
        <!--- Modal handlers for each contact --->
        <cfoutput>
        <script>
        $(document).ready(function() {
            // Remove loading spinner
            $('body').removeClass('loading');
            
            <cfloop query="shares">
                $("##remoteShareViewC#shares.contactid#").on("show.bs.modal", function(event) {
                    $(this).find(".modal-body").load("remoteShareViewC.cfm?contactid=#shares.contactid#");
                });
            </cfloop>
        });  
        </script>
        </cfoutput>
        
        <!--- Modal HTML structures --->
        <cfoutput>
        <cfloop query="shares">
            <div id="remoteShareViewC#shares.contactid#" class="modal modal-lg fade" tabindex="-1" role="dialog" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h4 class="modal-title">#shares.name#</h4>
                            <button type="button" class="close" data-bs-dismiss="modal" aria-hidden="true"><i class="mdi mdi-close-thick"></i></button>
                        </div>
                        <div class="modal-body">
                            <!--- Content will be loaded via AJAX --->
                        </div>
                    </div>
                </div>
            </div>
        </cfloop>
        </cfoutput>
    <cfelse>
        <!--- If no shares, still remove loading spinner --->
        <script>
        $(document).ready(function() {
            $('body').removeClass('loading');
        });
        </script>
    </cfif>

    <cfif debug is "YES">
        <div class="debug-info debug-info-lg info">
            <h2>Debug Information Summary</h2>
            
            <h3>URL Parameters</h3>
            <cfdump var="#url#" label="URL Scope">
            
            <h3>Form Parameters</h3>
            <cfdump var="#form#" label="Form Scope">
            
            <h3>Cookie Values</h3>
            <cfdump var="#cookie#" label="Cookie Scope">
            
            <h3>Session Values</h3>
            <cfdump var="#session#" label="Session Scope" expand="false">
            
            <h3>CGI Variables</h3>
            <cfdump var="#cgi#" label="CGI Scope" expand="false">
            
            <h3>Server Information</h3>
            <cfdump var="#server#" label="Server Scope" expand="false">
            
            <h3>Application Settings</h3>
            <cfdump var="#application#" label="Application Scope" expand="false">
            
            <hr>
            <p>Debug mode is enabled. Set debug="NO" at the top of the page to disable.</p>
        </div>
    </cfif>


</body>

</html>