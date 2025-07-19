<!--- 
    PURPOSE: Main entry point for share directory
    AUTHOR: Updated by GitHub Copilot
    DATE: 2025-07-19
    NOTES: Updated to use a more secure shareToken system
--->

<cfparam name="url.shareToken" default="" />
<cfparam name="url.u" default="" />  <!--- Keep legacy parameter for backward compatibility --->
<cfparam name="url.uid" default="" /> <!--- Original legacy parameter --->

<!--- Ensure application variables are set --->
<cfif not structKeyExists(application, "dsn")>
    <cfset onApplicationStart() />
</cfif>

<!--- Handle new shareToken system --->
<cfif len(trim(url.shareToken)) gt 0>
    <cfinclude template="remote_load.cfm" />
    <cfabort />
</cfif>

<!--- Legacy system handling --->
<cfif len(trim(url.u)) gt 0 OR len(trim(url.uid)) gt 0>
    <cfset session.userid = 0 />
    <cfparam name="refresh_yn" default="N" />
    <cfparam name="NEW_USERID" default="0" />
    <cfset legacy_token = len(trim(url.u)) gt 0 ? url.u : url.uid />
    
    <!--- Get user ID from legacy token --->
    <cfquery name="default" datasource="#application.dsn#">
        SELECT 
            left(passwordhash,10) as default_u,
            userid 
        FROM 
            taousers 
        WHERE 
            left(passwordhash,10) = <cfqueryparam value="#legacy_token#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <cfoutput>default_u: #default_u#<cfabort></cfoutput>
    <cfif default.recordCount eq 0>
        <cfinclude template="invalid_token.cfm" />
        <cfabort>
    </cfif>
    
    <cfset u = default.default_u />
    <cfset new_userid = default.userid />
    
    <!--- Include legacy page --->
    <cfinclude template="pgload.cfm" />
<cfelse>
    <!--- No token provided - redirect to main site --->
    <cflocation url="https://theactorsoffice.com" addtoken="false" />
</cfif>
<cfquery name="shares" datasource="#application.dsn#">
SELECT `contactid`,`Name`,`Company`,`Title`,`Audition`,`WhereMet`,`WhenMet`,`NotesLog`,`userid`,`u`
FROM sharez where userid = #new_userid#
</cfquery>










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





</body>

</html>