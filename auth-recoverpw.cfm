<cfapplication name="TAO" sessionmanagement="true">

<!--- Ensure required application variables exist (matches loginform.cfm pattern) --->
<cfif NOT structKeyExists(application, "dsn")>
    <cfset host = ListFirst(cgi.server_name, ".") />
    <cfif host EQ "app">
        <cfset application.dsn = "abo" />
    <cfelse>
        <cfset application.dsn = "abod" />
    </cfif>
</cfif>

<cfif NOT structKeyExists(application, "information_schema")>
    <cfset application.information_schema = "actorsbusinessoffice" />
</cfif>

<cfif NOT structKeyExists(application, "suffix")>
    <cfset application.suffix = "_1.5" />
</cfif>

<cfif NOT structKeyExists(application, "baseMediaUrl")>
    <cfset application.baseMediaUrl = "/media-" & application.dsn />
</cfif>
<cfif NOT structKeyExists(application, "imagesUrl")>
    <cfset application.imagesUrl = application.baseMediaUrl & "/images" />
</cfif>

<cfset dsn = application.dsn />
<cfset suffix = application.suffix />
<cfset information_schema = application.information_schema />

<cfparam name="pwrong" default="" />
<cfparam name="u" default="" />
<cfparam name="p" default="" />
<cfparam name="pgaction" default="view">
<cfparam name="header" default="Password Recovery" />
<cfparam name="instruct" default="We'll send you an email with instructions to reset your password." />

<cfif structKeyExists(cookie, "userid")>
    <cfcookie name="userid" value="#Now()#" Expires="now" domain=".theactorsoffice.com">
    <cfset structDelete(cookie, "userid")>
</cfif>

<cfparam name="email" default="" />
<cfset recoverLink = "" />
<cfset mailError = "" />

<cfif pgaction is "recover">

    <cfif NOT len(trim(email))>
        <cfset pgaction = "fail">
    <cfelse>
        <cfset instruct = "An email has been sent to you with instructions on how to reset your password." />
        <cfset header = "Email Sent" />

        <cfquery result="result" name="find" datasource="#dsn#">
            SELECT userid, useremail, userfirstname, contactid
            FROM taousers
            WHERE useremail = <cfqueryparam value="#trim(email)#" cfsqltype="cf_sql_varchar">
            LIMIT 1
        </cfquery>

        <cfif find.recordcount is "1">

            <cfset recover = CreateUUID() />

            <cfquery result="result" name="update" datasource="#dsn#">
                UPDATE taousers
                SET recover = <cfqueryparam value="#recover#" cfsqltype="cf_sql_varchar" />
                WHERE useremail = <cfqueryparam value="#trim(email)#" cfsqltype="cf_sql_varchar">
            </cfquery>

            <cfset recoverLink = "https://#cgi.server_name#/recover/?cid=#find.contactid#&email=#encodeForURL(find.useremail)#&recover=#recover#" />

            <cftry>
                <cfmail from="support@theactorsoffice.com" to="#find.useremail#" subject="The Actor's Office - Password Recovery" type="HTML">
                <HTML>
                <head><title>The Actor's Office</title></head>
                <body style="background-color: white; font-family: 'Source Sans Pro', sans-serif; font-size: 14px;">

                    <p>Hi #find.userfirstname#,</p>

                    <p>We've received a request for your password to be reset.</p>

                    <p>To get started, click the link below where you'll create your password.</p>

                    <p><a href="#recoverLink#" style="display:inline-block;padding:10px 24px;background-color:##406E8E;color:white;text-decoration:none;border-radius:4px;">RESET MY PASSWORD</a></p>

                    <p>If you have any questions, simply respond to this email.</p>

                    <p>The Actor's Office Support Team</p>

                </body>
                </HTML>
                </cfmail>
            <cfcatch type="any">
                <cflog file="tao_errors" type="error"
                       text="Password recovery email failed for #find.useremail#: #cfcatch.message# #cfcatch.detail#">
                <cfset mailError = "We could not send the recovery email. Please contact support." />
            </cfcatch>
            </cftry>

        <cfelse>
            <cfset pgaction = "fail">
        </cfif>
    </cfif>

</cfif>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <title>Password Recovery | The Actor's Office</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta content="The Actor's Office Application" name="description" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <link rel="shortcut icon" href="/media/shared/images/favicon.ico">
        <link href="/app/assets/css/app.min.css" rel="stylesheet" type="text/css" id="app-style" />
        <link href="/app/assets/css/icons.min.css" rel="stylesheet" type="text/css" />
    </head>

    <body class="loading" style="background-color: #406E8E; font-family: 'Source Sans Pro', sans-serif;">

        <div class="account-pages mt-5 mb-5">
            <div class="container">
                <div class="row justify-content-center">
                    <div class="col-md-8 col-lg-6 col-xl-5">
                        <div class="card mb-3" style="background-color:white;">

                            <div class="card-body p-4">

                                <div class="text-center w-85 m-auto">
                                    <div class="auth-logo">
                                        <a href="index.html" class="logo no-hover-effect logo-dark text-center">
                                            <span class="logo no-hover-effect-lg">
                                                <cfoutput><img src="/media-#application.dsn#/images/taowhite.png" alt="" class="w-100"></cfoutput>
                                            </span>
                                        </a>

                                        <a href="index.html" class="logo no-hover-effect logo-light text-center">
                                            <span class="logo no-hover-effect-lg">
                                                <cfoutput><img src="/media-#application.dsn#/images/logo-dark.png" alt="" class="w-100" /></cfoutput>
                                            </span>
                                        </a>
                                    </div>
                                    <h5><cfoutput>#header#</cfoutput></h5>
                                    <p class="text-muted mb-4 mt-3" style="font-size:14px;"><cfoutput>#instruct#</cfoutput></p>
                                </div>

                                <cfif pgaction is "fail">
                                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                        Email not found!
                                    </div>
                                    <p class="text-center">
                                        <a href="/auth-recoverpw.cfm"><button class="btn btn-primary" type="button">Try Again</button></a>
                                    </p>
                                </cfif>

                                <cfif pgaction is "view">
                                    <form id="demo-form" action="/auth-recoverpw.cfm" method="post">
                                        <input type="hidden" name="pwrong" value="N" />
                                        <input type="hidden" name="pgaction" value="recover" />
                                        <div class="form-group mb-3">
                                            <label for="email">Email address</label>
                                            <input class="form-control" type="email" id="email" name="email" required placeholder="Enter your email" />
                                        </div>

                                        <div class="form-group mb-0 text-center">
                                            <button class="btn btn-primary" type="submit">Reset Password</button>
                                        </div>
                                    </form>
                                </cfif>

                                <cfif pgaction is "recover">
                                    <cfif len(mailError)>
                                        <div class="alert alert-warning mt-3">
                                            <cfoutput>#mailError#</cfoutput>
                                        </div>
                                    </cfif>
                                    <cfoutput>
                                    <cfif listFirst(cgi.server_name, ".") EQ "dev" AND len(recoverLink)>
                                        <div class="alert alert-info mt-3" style="font-size:13px;word-break:break-all;">
                                            <strong>Dev mode:</strong> <a href="#recoverLink#">#recoverLink#</a>
                                        </div>
                                    </cfif>
                                    </cfoutput>
                                    <div class="text-center mt-3">
                                        <a href="/loginform.cfm">Back to Login</a>
                                    </div>
                                </cfif>

                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>

        <footer class="footer footer-alt text-white-50">
            &copy; 2021 The Actor's Office &trade; - All Right Reserved.
        </footer>

        <script src="/app/assets/js/vendor.min.js"></script>
        <script src="/app/assets/js/app.min.js"></script>

    </body>
</html>
