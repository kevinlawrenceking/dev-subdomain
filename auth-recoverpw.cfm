<cfapplication name="TAO" sessionmanagement="true">

<!--- Ensure required application variables exist --->
<cfif NOT structKeyExists(application, "dsn")>
    <cfset host = ListFirst(cgi.server_name, ".") />
    <cfif host EQ "app">
        <cfset application.dsn = "abo" />
    <cfelse>
        <cfset application.dsn = "abod" />
    </cfif>
</cfif>

<cfif NOT structKeyExists(application, "baseMediaUrl")>
    <cfset application.baseMediaUrl = "/media-" & application.dsn />
</cfif>

<cfset dsn = application.dsn />

<!--- Clear any lingering auth cookies --->
<cfif structKeyExists(cookie, "userid")>
    <cfcookie name="userid" value="" expires="now">
    <cfset structDelete(cookie, "userid")>
</cfif>

<!--- Defaults --->
<cfparam name="pgaction" default="view">
<cfparam name="email" default="">
<cfset recoverLink = "" />

<!--- Merge form-submitted values (cfparam only sets Variables scope, which shadows Form scope) --->
<cfif structKeyExists(form, "pgaction")>
    <cfset pgaction = form.pgaction>
</cfif>
<cfif structKeyExists(form, "email")>
    <cfset email = trim(form.email)>
</cfif>

<!--- Process recovery request --->
<cfif pgaction IS "recover">

    <cfif NOT len(email)>
        <cfset pgaction = "view">

    <!--- Rate limit: 1 request per 60 seconds per session --->
    <cfelseif structKeyExists(session, "recoveryLastRequest")
             AND dateDiff("s", session.recoveryLastRequest, now()) LT 60>
        <cfset pgaction = "ratelimit">

    <cfelse>
        <cfset session.recoveryLastRequest = now() />

        <!--- Look up user (result is never revealed to the client) --->
        <cfquery name="find" datasource="#dsn#">
            SELECT userid, useremail, userfirstname
            FROM taousers
            WHERE useremail = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">
            LIMIT 1
        </cfquery>

        <cfif find.recordcount IS 1>
            <cfset recover = CreateUUID() />

            <cfquery datasource="#dsn#">
                UPDATE taousers_tbl
                SET recover = <cfqueryparam value="#recover#" cfsqltype="cf_sql_varchar">,
                    recover_requested_at = NOW()
                WHERE userid = <cfqueryparam value="#find.userid#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset recoverLink = "https://#cgi.server_name#/recover/?recover=#recover#" />

            <cftry>
                <cfmail from="support@theactorsoffice.com"
                        to="#find.useremail#"
                        subject="The Actor's Office - Password Recovery"
                        type="HTML">
<html>
<head><title>The Actor's Office</title></head>
<body style="background-color: white; font-family: 'Source Sans Pro', sans-serif; font-size: 14px; color: ##333;">
    <p>Hi #find.userfirstname#,</p>
    <p>We received a request to reset your password.</p>
    <p>Click the button below to create a new password. This link expires in 1 hour.</p>
    <p style="margin: 24px 0;">
        <a href="#recoverLink#"
           style="display:inline-block;padding:12px 28px;background-color:##406E8E;color:white;text-decoration:none;border-radius:4px;font-weight:600;">
            Reset My Password
        </a>
    </p>
    <p style="font-size:13px;color:##666;">If you did not request this, you can safely ignore this email.</p>
    <p>The Actor's Office Support Team</p>
</body>
</html>
                </cfmail>
            <cfcatch type="any">
                <cflog file="tao_errors" type="error"
                       text="Password recovery email failed for #find.useremail#: #cfcatch.message# #cfcatch.detail#">
            </cfcatch>
            </cftry>
        </cfif>

        <!--- Always show "sent" regardless of whether email was found (anti-enumeration) --->
        <cfset pgaction = "sent">
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
    <meta name="robots" content="noindex">
    <link rel="shortcut icon" href="/media/shared/images/favicon.ico">
    <link href="/app/assets/css/app.min.css" rel="stylesheet" type="text/css" id="app-style" />
    <link href="/app/assets/css/icons.min.css" rel="stylesheet" type="text/css" />
</head>

<body class="loading" style="background-color: #406E8E; font-family: 'Source Sans Pro', sans-serif;">

    <div class="account-pages mt-5 mb-5">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-8 col-lg-6 col-xl-5">
                    <div class="card mb-3" style="background-color: white;">
                        <div class="card-body p-4">

                            <div class="text-center w-85 m-auto">
                                <div class="auth-logo">
                                    <a href="/loginform.cfm" class="logo no-hover-effect logo-dark text-center">
                                        <span class="logo no-hover-effect-lg">
                                            <cfoutput><img src="/media-#application.dsn#/images/taowhite.png" alt="The Actor's Office" class="w-100"></cfoutput>
                                        </span>
                                    </a>
                                </div>

                                <cfif pgaction IS "sent">
                                    <h5>Check Your Email</h5>
                                    <p class="text-muted mb-4 mt-3" style="font-size: 14px;">
                                        If an account exists with that email address, we've sent instructions to reset your password.
                                    </p>
                                <cfelseif pgaction IS "ratelimit">
                                    <h5>Please Wait</h5>
                                    <p class="text-muted mb-4 mt-3" style="font-size: 14px;">
                                        You recently requested a recovery email. Please wait a minute before trying again.
                                    </p>
                                <cfelse>
                                    <h5>Password Recovery</h5>
                                    <p class="text-muted mb-4 mt-3" style="font-size: 14px;">
                                        Enter your email address and we'll send you instructions to reset your password.
                                    </p>
                                </cfif>
                            </div>

                            <!--- Form state: show the email input --->
                            <cfif pgaction IS "view">
                                <form id="recovery-form" action="/auth-recoverpw.cfm" method="post">
                                    <input type="hidden" name="pgaction" value="recover" />
                                    <div class="form-group mb-3">
                                        <label for="email">Email Address</label>
                                        <input class="form-control" type="email" id="email" name="email"
                                               required placeholder="Enter your email" autocomplete="email" />
                                    </div>
                                    <div class="form-group mb-0 text-center">
                                        <button class="btn btn-primary btn-block" type="submit" id="submitBtn">
                                            Reset Password
                                        </button>
                                    </div>
                                </form>
                            </cfif>

                            <!--- Sent state: dev-mode link for testing --->
                            <cfif pgaction IS "sent">
                                <cfoutput>
                                <cfif listFirst(cgi.server_name, ".") EQ "dev" AND len(recoverLink)>
                                    <div class="alert alert-info mt-3" style="font-size: 13px; word-break: break-all;">
                                        <strong>Dev mode:</strong> <a href="#recoverLink#">#recoverLink#</a>
                                    </div>
                                </cfif>
                                </cfoutput>
                            </cfif>

                            <!--- Back to Login link on all states --->
                            <div class="text-center mt-3">
                                <a href="/loginform.cfm">Back to Login</a>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <footer class="footer footer-alt text-white-50">
        <cfoutput>&copy; #year(now())# The Actor's Office &trade; - All Rights Reserved.</cfoutput>
    </footer>

    <script src="/app/assets/js/vendor.min.js"></script>
    <script src="/app/assets/js/app.min.js"></script>
    <script>
    (function() {
        var form = document.getElementById('recovery-form');
        if (form) {
            form.addEventListener('submit', function() {
                var btn = document.getElementById('submitBtn');
                btn.disabled = true;
                btn.innerHTML = '<span class="spinner-border spinner-border-sm mr-1" role="status" aria-hidden="true"></span> Sending...';
            });
        }
    })();
    </script>

</body>
</html>
