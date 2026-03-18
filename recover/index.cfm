<!--- Password Reset Form
     Validates the recovery token from URL, checks expiration, and shows the new password form.
     Token is stored in session for setup2.cfm to verify. --->

<!--- dsn is set by Application.cfm --->
<cfif NOT isDefined("dsn") OR NOT len(dsn)>
    <cfset dsn = listFirst(cgi.server_name, ".") EQ "app" ? "abo" : "abod" />
</cfif>

<cfset tokenValid = false />
<cfset tokenError = "" />

<!--- Only accept token-based recovery (no userid bypass) --->
<cfif structKeyExists(url, "recover") AND len(trim(url.recover))>

    <cfquery name="u" datasource="#dsn#">
        SELECT userid, userfirstname, userlastname, recover_requested_at
        FROM taousers
        WHERE recover = <cfqueryparam value="#trim(url.recover)#" cfsqltype="cf_sql_varchar">
        LIMIT 1
    </cfquery>

    <cfif u.recordcount IS 1>
        <!--- Check token expiration (1 hour) --->
        <cfif isDate(u.recover_requested_at)
              AND dateDiff("n", u.recover_requested_at, now()) LT 60>
            <cfset tokenValid = true />
            <cfset session.recoverToken = trim(url.recover) />
        <cfelse>
            <cfset tokenError = "This recovery link has expired. Please request a new one." />
        </cfif>
    <cfelse>
        <cfset tokenError = "This recovery link is invalid or has already been used." />
    </cfif>

<cfelse>
    <cflocation url="/loginform.cfm" addtoken="false" />
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Password Change | The Actor's Office</title>
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
                                            <cfoutput><img src="/media-#dsn#/images/taowhite.png" alt="The Actor's Office" class="w-100"></cfoutput>
                                        </span>
                                    </a>
                                </div>

                                <cfif tokenValid>
                                    <h5>Create New Password</h5>
                                    <p class="text-muted mb-4 mt-3" style="font-size: 14px;">
                                        <cfoutput>Hi #encodeForHTML(u.userfirstname)#,</cfoutput> enter your new password below.
                                    </p>
                                <cfelse>
                                    <h5>Link Expired</h5>
                                </cfif>
                            </div>

                            <cfif tokenValid>
                                <form id="reset-form" action="setup2.cfm" method="post" autocomplete="off"
                                      class="parsley-examples" data-parsley-trigger="keyup" data-parsley-validate>

                                    <div class="form-group mb-3">
                                        <label for="pass1">New Password <span class="text-danger">*</span></label>
                                        <input id="pass1" type="password" name="pass1" class="form-control"
                                               placeholder="Minimum 8 characters"
                                               data-parsley-minlength="8"
                                               data-parsley-required
                                               data-parsley-minlength-message="Password must be at least 8 characters"
                                               autocomplete="new-password" />
                                    </div>

                                    <div class="form-group mb-3">
                                        <label for="pass2">Confirm Password <span class="text-danger">*</span></label>
                                        <input id="pass2" type="password" name="pass2" class="form-control"
                                               placeholder="Re-enter password"
                                               data-parsley-equalto="#pass1"
                                               data-parsley-required
                                               data-parsley-error-message="Passwords must match"
                                               autocomplete="new-password" />
                                    </div>

                                    <p class="text-muted mb-3" style="font-size: 12px;">
                                        Password must be at least 8 characters.
                                    </p>

                                    <div class="form-group mb-0 text-center">
                                        <button class="btn btn-primary btn-block" type="submit" id="submitBtn">
                                            Update Password
                                        </button>
                                    </div>
                                </form>

                            <cfelse>
                                <div class="alert alert-warning mt-3">
                                    <cfoutput>#tokenError#</cfoutput>
                                </div>
                                <div class="text-center">
                                    <a href="/auth-recoverpw.cfm" class="btn btn-primary">Request New Link</a>
                                </div>
                            </cfif>

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
    <cfif tokenValid>
    <script src="/app/assets/libs/parsleyjs/parsley.min.js"></script>
    </cfif>
    <script src="/app/assets/js/app.min.js"></script>
    <cfif tokenValid>
    <script>
    $(document).ready(function() {
        $('.parsley-examples').parsley();
    });

    (function() {
        var form = document.getElementById('reset-form');
        if (form) {
            form.addEventListener('submit', function(e) {
                var instance = $(form).parsley();
                if (instance.isValid()) {
                    var btn = document.getElementById('submitBtn');
                    btn.disabled = true;
                    btn.innerHTML = '<span class="spinner-border spinner-border-sm mr-1" role="status" aria-hidden="true"></span> Updating...';
                }
            });
        }
    })();
    </script>
    </cfif>

</body>
</html>
