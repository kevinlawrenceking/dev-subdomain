<!--- This ColdFusion page sets up the application environment and includes necessary resources for rendering the page. --->

<CFSILENT>
    <cfparam name="pgaction" default="view" />
    <cfparam name="subdomain" default="app" />
    <cfparam name="thispage2" default="" />
    
    <!--- Set current URL and host based on server name --->
    <cfset currentURL = cgi.server_name />
    <cfset host = ListFirst(currentURL, ".") />
    
    <!--- Determine the data source name and version based on the host --->
    <cfif #host# is "app">
        <cfset dsn = "abo" />
        <cfset rev = "1.4" />
        <cfset suffix = "_1.4" />
    <cfelse>
        <cfset dsn = "abod" />
        <cfset rev = rand() />
        <cfset suffix = "" />
    </cfif>
    
    <cfoutput>
        <!--- Set path and page variables --->
        <cfset thisPath = ExpandPath("*.*") />
        <cfset thisDirectory = "#GetDirectoryFromPath(thisPath)#" />
        <cfset thispage = "#replace('#thisDirectory#','C:\home\theactorsoffice.com\wwwroot\#host#-subdomain#suffix#\app\','')#" />
        <cfset thispage = "#replace('#thispage#','\','')#" />
        <cfset currentpage = "#cgi.script_name#?#cgi.query_string#" />
        <cfset returnpage = "#cgi.script_name#?#cgi.query_string#" />
    </cfoutput>
    
    <cfinclude template="/include/pgload_setup.cfm" />
    <cfparam name="rpgid" default="0" />
</CFSILENT>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <cfoutput>
            <title>#appName# | #pgTitle#</title>
        </cfoutput>  
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta content="The Actor's Office Setup" name="description" />
        <meta content="Jodie Bentley" name="author" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        
        <!--- App favicon --->
        <link rel="shortcut icon" href="/media/shared/images/favicon.ico">
        
        <!--- App css --->
        <link href="/app/assets/css/bootstrap-modern.min.css" rel="stylesheet" type="text/css" id="bs-default-stylesheet" />
        <link href="/app/assets/css/app-modern.min.css" rel="stylesheet" type="text/css" id="app-default-stylesheet" />
        <link href="/app/assets/css/app-modern-dark.min.css" rel="stylesheet" type="text/css" id="app-dark-stylesheet" />
        
        <!--- icons --->
        <link href="/app/assets/css/icons.min.css" rel="stylesheet" type="text/css" />
        
        <!--- Include additional links based on query --->
        <cfloop query="FindLinksT">
            <cfoutput>
                <cfif "#findlinkst.linktype#" is "script">
                    <script src="#findlinkst.linkurl#?ver=#rand()#"></script>
                <cfelse>
                    <link href="#findlinkst.linkurl#?ver=#rand()#" 
                          <cfif #findlinkst.rel# is not ""> rel="#rel#"</cfif> 
                          type="text/css" 
                          <cfif #findlinkst.hrefid# is not ""> id="#findlinkst.hrefid#"</cfif> />
                </cfif>
            </cfoutput>
        </cfloop>
    </head>

    <body class="loading" style="background-color: #406E8E; font-family: 'Source Sans Pro', sans-serif;">
        <div class="account-pages mt-3 mb-3">
            <div class="container">
                <div class="row justify-content-center">
                    <div class="col-md-11">
                        <div class="card ">
                            <div class="card-body p-4">
                                <div class="text-center w-85 m-auto">
                                    <div class="auth-logo">
                                        <a href="index.html" class="logo no-hover-effect logo-dark text-center">
                                            <span class="logo no-hover-effect-lg">
                                                <img src="<cfoutput>#application.imagesUrl#/taowhite.png</cfoutput>" alt="" height="40">
                                            </span>
                                        </a>
                                        <a href="index.html" class="logo no-hover-effect logo-light text-center">
                                            <span class="logo no-hover-effect-lg">
                                                <img src="<cfoutput>#application.imagesUrl#/taowhite.png</cfoutput>" alt="" height="40">
                                            </span>
                                        </a>
                                    </div>
                                    <p class="text-muted mb-3 mt-2" style="font-size:16px;">
                                        <cfoutput>#pgheading# for #userfirstname# #userlastname#</cfoutput>
                                    </p>
                                </div>

                                <!--- Include the main page content --->
                                <cfinclude template="/include/#pgFilename#" />
                            </div> <!--- end card-body --->
                        </div> <!--- end card --->
                    </div> <!--- end col --->
                </div> <!--- end row --->
            </div> <!--- end container --->
        </div> <!--- end page --->

        <footer class="footer footer-alt text-white-50">
            &copy; 2021 The Actor's Office &trade; - All Right Reserved.
        </footer>

        <!--- Vendor js --->
        <script src="/assets/js/vendor.min.js"></script>
        
        <!--- Include additional scripts based on query --->
        <cfloop query="FindLinksB">
            <cfoutput>
                <cfif "#findlinksb.linktype#" is "script">
                    <script src="#findlinksb.linkurl#?ver=#randomize(1000000)#"></script>
                <cfelse>
                    <link href="#findlinksb.linkurl#" 
                          <cfif #findlinksb.rel# is not ""> rel="#findlinksb.rel#"</cfif> 
                          type="text/css" 
                          <cfif #findlinksb.hrefid# is not ""> id="#findlinksb.hrefid#"</cfif> />
                </cfif>
            </cfoutput>
        </cfloop>

        <!--- App js --->
        <script src="/assets/js/app.min.js"></script>
    </body>
</html>
