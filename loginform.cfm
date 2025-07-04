<cfapplication name="TAO" sessionmanagement="true">

<cfset currentURL = cgi.server_name />
<cfset host = ListFirst(currentURL, ".") />

<!--- Determine the datasource and schema based on the host --->
<cfif host is "app">
    <cfset dsn = "abo" />
    <cfset suffix = "_1.5" />
    <cfset information_schema = "actorsbusinessoffice" />
<cfelse>
    <cfset dsn = "abod" />
    <cfset suffix = "" />
    <cfset information_schema = "new_development" />
</cfif>

<cfif structKeyExists(cookie, "userid")>
    <cfset structDelete(cookie, "userid")>
</cfif>



<cfif structKeyExists(session, "userid")>
    <cfset structDelete(session, "userid")>
</cfif>



<cfquery result="result" name="fix" datasource="#dsn#"> 
    SELECT u.userID  
    FROM taousers u
    INNER JOIN thrivecart t ON t.id = u.customerid
    INNER JOIN userstatuses us ON us.userstatus = u.userstatus
    WHERE t.status = 'Completed' AND u.userstatus <> 'active'
</cfquery> 

<cfloop query="fix">
    <cfquery result="result" name="fix2" datasource="#dsn#"> 
        UPDATE taousers SET userstatus = 'active' WHERE userid = <cfqueryparam value="#fix.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery> 
</cfloop>

<!--- Default parameters for the page --->
<cfparam name="pgrecover" default="N" />
<cfparam name="pwrong" default="N" />
<cfparam name="u" default="" />
<cfparam name="p" default="" />

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Log In | The Actor's Office</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta content="The Actor's Office Application - The Actors Office" name="description" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="robots" content="noindex">
    <link rel="shortcut icon" href="/media/shared/images/favicon.ico">
    <link href="/app/assets/css/app.min.css" rel="stylesheet" type="text/css" />
    <link href="/app/assets/css/icons.min.css" rel="stylesheet" type="text/css" />
    <script src="/app/assets/js/jquery-3.6.0.min.js"></script>
</head>

<body class="loading" style="background-color: #406E8E; font-family: 'Source Sans Pro', sans-serif;">

    <div class="account-pages mt-5 mb-5">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-8 col-lg-6 col-xl-5">
                    <div class="card mb-3" style="background-color:white;bgcolor:white;">
                        <div class="card-body p-4">
                            <div class="text-center w-85 m-auto">
                                <div class="auth-logo">
                                    <a href="index.html" class="logo no-hover-effect logo-dark text-center">
                                        <span class="logo no-hover-effect-lg">
                                            <img src="/media/shared/taowhite.png" alt="" height="60" />
                                        </span>
                                    </a>
                                    <a href="index.html" class="logo no-hover-effect logo-light text-center">
                                        <span class="logo no-hover-effect-lg">
                                            <img src="/media/shared/images/logo-dark.png" alt="" height="22" />
                                        </span>
                                    </a>
                                </div>
                                <p class="text-muted mb-4 mt-3" style="font-size:14px;">Enter your email address and password.</p>
                            </div>

                            <!--- Display success or error messages --->
                            <cfoutput>
                                <cfif pgrecover eq "Y">
                                    <center><p style="color:green;">Password Changed!</p></center>
                                    <cfset pgrecover = "N" />
                                </cfif>

                                <cfif pwrong eq "Y">
                                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                            <span >
&times;</span>
                                        </button>
                                        Incorrect Email Address and Password!
                                    </div>
                                    <cfset pwrong = "N" />
                                </cfif>
                            </cfoutput>

                            <!--- Login form --->
                            <form id="demo-form" action="/login/login2.cfm" method="post">
                                <input type="hidden" name="pwrong" value="N" />
                                <input type="hidden" name="pwpass" value="Y" />
                                
                                <cfif structKeyExists(url, "xu")>
                                    <input type="hidden" name="xu" value="#url.xu#" />
                                </cfif>
<Cfoutput>
                                <div class="form-group mb-3">
                                    <label for="emailaddress">Email Address</label>
                                    <input class="form-control" type="email" id="j_username" name="j_username" value="#htmlEditFormat(u)#" required placeholder="Enter your email" />
                                </div>

                       <div class="form-group mb-3">
    <label for="password">Password</label>
    <div class="input-group input-group-merge">
        <input type="password" id="j_password" name="j_password" class="form-control" value="#htmlEditFormat(p)#" placeholder="Enter your password" />
        <div class="input-group-append">
            <div class="input-group-text">
                <span class="password-eye" onclick="togglePassword()" style="cursor: pointer;">
                   
                </span>
            </div>
        </div>
    </div>
</div>

</cfoutput>
                                <div class="form-group mb-3">
                                    <div class="custom-control custom-checkbox">
                                        <input type="checkbox" class="custom-control-input" id="checkbox-signin" checked />
                                        <label class="custom-control-label" for="checkbox-signin">Remember me</label>
                                    </div>
                                </div>

                                <div class="form-group mb-0 text-center">
                                    <button class="btn btn-primary btn-block" type="submit">Log In</button>
                                </div>
                            </form>

                            <div class="text-center mt-3">
                                <a href="auth-recoverpw.cfm"   >Forgot your password?</a>
                            </div>
                        </div> <!--- end card-body --->
                    </div> <!--- end card --->
                </div> <!--- end col --->
            </div> <!--- end row --->
        </div> <!--- end container --->
    </div> <!--- end page --->

    <footer class="footer footer-alt text-white-50">
        &reg; 2024 The Actor's Office &trade; - All Right Reserved.
    </footer>

    <script src="/app/assets/js/vendor.min.js"></script>
    <script src="/app/assets/js/app.min.js"></script>
<script>
    function togglePassword() {
        const passwordField = document.getElementById('j_password');
        const eyeIcon = document.getElementById('eyeIcon');

        // Toggle password field type
        if (passwordField.type === 'password') {
            passwordField.type = 'text';
            eyeIcon.classList.remove('fa-eye');
            eyeIcon.classList.add('fa-eye-slash');
        } else {
            passwordField.type = 'password';
            eyeIcon.classList.remove('fa-eye-slash');
            eyeIcon.classList.add('fa-eye');
        }
    }
</script>



</body>
</html>
