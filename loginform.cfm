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

<cfif NOT structKeyExists(application, "information_schema")>
    <cfset application.information_schema = "actorsbusinessoffice" />
</cfif>

<cfif NOT structKeyExists(application, "suffix")>
    <cfset application.suffix = "_1.5" />
</cfif>

<cfset dsn = application.dsn />

<!--- Clear session on login page view (acts as logout mechanism) --->
<cfif structKeyExists(cookie, "userid")>
    <cfset structDelete(cookie, "userid")>
</cfif>
<cfif structKeyExists(session, "userid")>
    <cfset structDelete(session, "userid")>
</cfif>

<!--- Default parameters (from URL redirect after login attempt) --->
<cfparam name="pgrecover" default="N" />
<cfparam name="pwrong" default="N" />
<cfparam name="u" default="" />

<!--- Merge URL values explicitly (scope shadowing fix) --->
<cfif structKeyExists(url, "pgrecover")>
    <cfset pgrecover = url.pgrecover />
</cfif>
<cfif structKeyExists(url, "pwrong")>
    <cfset pwrong = url.pwrong />
</cfif>
<cfif structKeyExists(url, "u")>
    <cfset u = url.u />
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Log In | The Actor's Office</title>
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
                                            <cfoutput><img src="/media-#application.dsn#/images/taowhite.png" alt="The Actor's Office" height="60" /></cfoutput>
                                        </span>
                                    </a>
                                </div>
                                <p class="text-muted mb-4 mt-3" style="font-size: 14px;">Enter your email address and password.</p>
                            </div>

                            <!--- Success notification: password was changed --->
                            <cfif pgrecover EQ "Y">
                                <div class="alert alert-success alert-dismissible fade show" role="alert" id="successAlert">
                                    <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span>&times;</span></button>
                                    Password changed successfully. Please log in.
                                </div>
                            </cfif>

                            <!--- Error notification: wrong credentials --->
                            <cfif pwrong EQ "Y">
                                <div class="alert alert-danger alert-dismissible fade show" role="alert" id="errorAlert">
                                    <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span>&times;</span></button>
                                    Incorrect email address or password. Please try again.
                                </div>
                            </cfif>

                            <!--- Login form --->
                            <form id="login-form" action="/login/login2.cfm" method="post">
                                <input type="hidden" name="pwrong" value="N" />
                                <input type="hidden" name="pwpass" value="Y" />
                                <cfif structKeyExists(url, "xu")>
                                    <cfoutput><input type="hidden" name="xu" value="#encodeForHTMLAttribute(url.xu)#" /></cfoutput>
                                </cfif>

                                <div class="form-group mb-3">
                                    <label for="j_username">Email Address</label>
                                    <cfoutput>
                                    <input class="form-control" type="email" id="j_username" name="j_username"
                                           value="#encodeForHTMLAttribute(u)#" required
                                           placeholder="Enter your email" autocomplete="email" />
                                    </cfoutput>
                                </div>

                                <div class="form-group mb-3">
                                    <label for="j_password">Password</label>
                                    <div class="input-group input-group-merge">
                                        <input type="password" id="j_password" name="j_password" class="form-control"
                                               placeholder="Enter your password" required
                                               autocomplete="current-password" />
                                        <div class="input-group-append" style="cursor: pointer;" onclick="togglePassword()">
                                            <div class="input-group-text">
                                                <i class="fa fa-eye" id="eyeIcon"></i>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group mb-0 text-center">
                                    <button class="btn btn-primary btn-block" type="submit">Log In</button>
                                </div>
                            </form>

                            <div class="text-center mt-3">
                                <a href="/auth-recoverpw.cfm">Forgot your password?</a>
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
    function togglePassword() {
        var field = document.getElementById('j_password');
        var icon = document.getElementById('eyeIcon');
        if (field.type === 'password') {
            field.type = 'text';
            icon.className = 'fa fa-eye-slash';
        } else {
            field.type = 'password';
            icon.className = 'fa fa-eye';
        }
    }

    // Auto-dismiss alerts after 6 seconds
    (function() {
        setTimeout(function() {
            var alerts = document.querySelectorAll('.alert-dismissible');
            for (var i = 0; i < alerts.length; i++) {
                (function(alert) {
                    alert.style.transition = 'opacity 0.5s ease';
                    alert.style.opacity = '0';
                    setTimeout(function() { alert.remove(); }, 500);
                })(alerts[i]);
            }
        }, 6000);
    })();
    </script>

</body>
</html>
