<!--- 
    PURPOSE: Main entry point for share directory
    AUTHOR: Updated by GitHub Copilot
    DATE: 2025-07-19
    NOTES: Updated to use a more secure shareToken system
--->
<Cfset debug="No">
<cfparam name="url.shareToken" default="706C2C9EBECE60DA9F779903AC3FFE79" />
<cfparam name="url.u" default="" />  <!--- Keep legacy parameter for backward compatibility --->
<cfparam name="url.uid" default="" /> <!--- Original legacy parameter --->

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
    <cfif debug is "YES"><cfoutput><p style="background:##ffe6e6;padding:5px;border:1px solid red">Application DSN not found, initializing...</p></cfoutput></cfif>
    <cfset onApplicationStart() />
</cfif>

<!--- Debug URL parameters --->
<cfif debug is "YES">
    <div style="background:##f0f8ff;padding:10px;margin:10px 0;border:1px solid ##add8e6;">
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
        <div style="background:##e6ffe6;padding:10px;margin:10px 0;border:1px solid ##90ee90;">
            <h3>Using New Token System</h3>
            <p>Token: <cfoutput>#url.shareToken#</cfoutput></p>
        </div>
    </cfif>
    <cfinclude template="remote_load.cfm" />
   
</cfif>

<!--- Legacy system handling --->
<cfif len(trim(url.u)) gt 0 OR len(trim(url.uid)) gt 0>
    <cfset session.userid = 0 />
    <cfparam name="refresh_yn" default="N" />
    <cfparam name="NEW_USERID" default="0" />
    <cfset legacy_token = len(trim(url.u)) gt 0 ? url.u : url.uid />
    
    <cfif debug is "YES">
        <div style="background:##fff8e6;padding:10px;margin:10px 0;border:1px solid ##ffd700;">
            <h3>Using Legacy Token System</h3>
            <p>Legacy token: <cfoutput>#legacy_token#</cfoutput></p>
            <p>Token source: <cfoutput>#len(trim(url.u)) gt 0 ? "u parameter" : "uid parameter"#</cfoutput></p>
            <p>Token length: <cfoutput>#len(legacy_token)#</cfoutput></p>
        </div>
    </cfif>
    <!--- Get user ID from legacy token --->
    <cfif debug is "YES">
        <div style="background:##e6e6ff;padding:10px;margin:10px 0;border:1px solid ##9370db;">
            <h3>SQL Query Information</h3>
            <p>Looking up user with token prefix: <cfoutput>#left(legacy_token,10)#</cfoutput></p>
            <code style="display:block;background:##f8f8f8;padding:10px;white-space:pre-wrap;">
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
        WHERE u.userid = 30
         <!---   left(t.UUID,10) = <cfqueryparam value="#left(legacy_token,10)#" cfsqltype="cf_sql_varchar"> --->
    </cfquery>
S
    <cfif debug is "YES">
        <div style="background:##e6e6ff;padding:10px;margin:10px 0;border:1px solid ##9370db;">
            <h3>Query Result</h3>
            <p>Records found: <cfoutput>#default.recordCount#</cfoutput></p>
            <cfdump var="#default#" label="Default Query Result">
        </div>
    </cfif>

    <cfif default.recordCount eq 0>
        <cfif debug is "YES">
            <div style="background:##ffe6e6;padding:10px;margin:10px 0;border:1px solid ##ff0000;">
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
        <div style="background:##e6ffe6;padding:10px;margin:10px 0;border:1px solid ##90ee90;">
            <h3>Authentication Successful</h3>
            <p>User ID: <cfoutput>#new_userid#</cfoutput></p>
            <p>Token (u): <cfoutput>#u#</cfoutput></p>
        </div>
    </cfif>
    
    <!--- Include legacy page --->
    <cfif debug is "YES">
        <div style="background:##f0f8ff;padding:10px;margin:10px 0;border:1px solid ##add8e6;">
            <h3>Including Legacy Page</h3>
            <p>Template: pgload.cfm</p>
            <p>User ID: <cfoutput>#new_userid#</cfoutput></p>
        </div>
    </cfif>
    <cfinclude template="pgload.cfm" />
<cfelse>
    <cfif debug is "YES">
        <div style="background:##ffe6e6;padding:10px;margin:10px 0;border:1px solid ##ff0000;">
            <h3>No Token Provided</h3>
            <p>Redirecting to main site...</p>
        </div>
    </cfif>
    <!--- No token provided - redirect to main site --->
    <cflocation url="https://theactorsoffice.com" addtoken="false" />
</cfif>

<cfif debug is "YES">
    <div style="background:##e6e6ff;padding:10px;margin:10px 0;border:1px solid ##9370db;">
        <h3>Shares Query</h3>
        <code style="display:block;background:##f8f8f8;padding:10px;white-space:pre-wrap;">
            SELECT `contactid`,`Name`,`Company`,`Title`,`Audition`,`WhereMet`,`WhenMet`,`NotesLog`,`userid`,`u`
            FROM sharez where userid = <cfoutput>#new_userid#</cfoutput>
        </code>
    </div>
</cfif>

<cfquery name="shares" datasource="#application.dsn#">
SELECT `contactid`,`Name`,`Company`,`Title`,`Audition`,`WhereMet`,`WhenMet`,`NotesLog`,`userid`,`u`
FROM sharez where userid = #new_userid#
</cfquery>

<cfif debug is "YES">
    <div style="background:##e6e6ff;padding:10px;margin:10px 0;border:1px solid ##9370db;">
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
        <meta content="#appDescription#" name="description" />
        <meta content="#appAuthor#" name="author" />
    </cfoutput>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Source+Sans+Pro:wght@300&display=swap');
    </style>
    <cfloop query="FindLinksT">
        <cfoutput>
            <cfif "#findlinkst.linktype#" is "script">
                <script src="#findlinkst.linkurl#"></script>
            </cfif>

            <cfif "#findlinkst.linktype#" is "script_include">
                <script>
                    <cfinclude template = "#findlinkst.linkurl#?rev=#rand()#" >
                </script>
            </cfif>
            <cfif "#findlinkst.linktype#" is "css" or "#findlinkst.linktype#" is "text/css" or "#findlinkst.linktype#" is "ico">
                <link href="#findlinkst.linkurl#?rev=#rand()#" <cfif #findlinkst.rel# is not "">
                rel="#rel#"

            </cfif>

            type="text/css" <cfif #findlinkst.hrefid# is not "">id="#findlinkst.hrefid#"</cfif> />

            </cfif>
        </cfoutput>
    </cfloop>
    
    <style>
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
</style>

</head>

<body class="loading">
    

    
    
    <div id="wrapper">
        <cfif #host# is "dev">
            <div class="navbar-custom" style="background-color: #8b0000 !important;">
                <cfelse>
                    <div class="navbar-custom" style="background-color: <cfoutput>#colorTopBar#</cfoutput> !important;">
        </cfif>
        <div class="container-fluid">
            <cfinclude template="topmenu_main.cfm" />
             <div class="logo-box">
            <a href="/app/" class="logo logo-dark text-center">
                <span class="logo-sm">
                    <img src="/assets/images/logo-sm.png" alt="" height="30">
                    <!-- <span class="logo-lg-text-light">UBold</span> -->
                </span>
                <span class="logo-lg">
                    <img src="/assets/images/logo-sm.png" alt="" height="30">
                    <!-- <span class="logo-lg-text-light">U</span> -->
                </span>
            </a>
    
            <a href="/app/" class="logo logo-light text-center">
                <span class="logo-sm">
                    <img src="/assets/images/logo-sm.png" alt="" height="30">
                </span>
                <span class="logo-lg">
                    <img src="/assets/images/logo-light.png" alt="" height="30">
                </span>
            </a>
        </div>
    
        </div>
        <div class="content-pag">
            <div class="content" STYLE="margin-top:35px;">
                <div class="container-fluid">
     
                    <cfinclude template="share.cfm" />
                </div>
            </div>
            <cfparam name="pgdir" default="">
                <cfparam name="pgid" default="0" />
        </div>
    </div>
    <cfloop query="FindLinksB">
        <cfoutput>
            <cfif "#findlinksb.linktype#" is "script">
                <script src="#findlinksb.linkurl#?ver=#rand()#"></script>

            </cfif>
            <cfif "#findlinksb.linktype#" is "script_include">
     
                    <cfinclude template = "#findlinksb.linkurl#" >
       
            </cfif>
            <cfif "#findlinksb.linktype#" is "css" or "#findlinksb.linktype#" is "text/css" or "#findlinksb.linktype#" is "ico">
                <link href="#findlinksb.linkurl#" <cfif #findlinksb.rel# is not ""> rel="#findlinksb.rel#"
            </cfif>

            type="text/css"

            <cfif #findlinksb.hrefid# is not "">

                id="#findlinksb.hrefid#"

            </cfif> />

            </cfif>
        </cfoutput>
    </cfloop>










    <cfloop query="shares">



<script>
$(document).ready(function() {
    $("#remoteShareViewC<cfoutput>#shares.contactid#</cfoutput>").on("show.bs.modal", function(event) {
            $(this).find(".modal-body").load("remoteShareViewC.cfm?contactid=<cfoutput>#shares.contactid#</cfoutput>"
            );
        });
});  
</script>





        <div id="remoteShareViewC<cfoutput>#shares.contactid#</cfoutput>" class="modal modal-lg fade" tabindex="-1" role="dialog" aria-hidden="true">

            <div class="modal-dialog">

                <div class="modal-content">

                    <div class="modal-header">

                        <h4 class="modal-title"><CFOUTPUT>#shares.name#</CFOUTPUT>

                        </h4>

                        <button type="button" class="close" data-bs-dismiss="modal" aria-hidden="true"><i class="mdi mdi-close-thick"></i></button>

                    </div>

                    <div class="modal-body">

                    </div>

                </div>

            </div>

        </div>

    </cfloop>

    <cfif debug is "YES">
        <div style="background:##f0f8ff;padding:20px;margin:20px 0;border:1px solid ##add8e6;">
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