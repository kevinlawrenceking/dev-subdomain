<cfparam name="u" default="" />
<cfset session.userid = 0 />
<CFPARAM name="refresh_yn" default="N" />
<cfparam name="NEW_USERID" default="0" />
<CFINCLUDE template="remote_load.cfm" />
<cfif #u# is "">
    <cfif #isdefined('userid')#>
        <cfquery name="default" datasource="#dsn#"> select left(passwordhash,10) as default_u,userid from taousers where userid = #userid# </cfquery>
        <cfelse> Invalid. <cfabort> `
    </cfif>
    <cfelse>
        <cfquery name="default" datasource="#dsn#"> select left(passwordhash,10) as default_u,userid from taousers where left(passwordhash,10) = '#u#' </cfquery>
</cfif>
<cfset u=default.default_u />
<cfinclude template="pgload.cfm" />
<cfset new_userid=default.userid />
<cfquery name="shares" datasource="#dsn#">
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