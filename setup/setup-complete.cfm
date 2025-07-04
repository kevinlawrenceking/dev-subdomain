<cfparam name="u" default="" />
<cfparam name="p" default="" />

<cfparam name="pwrong" default="N" />

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <title>Log In | The Actor's Office</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta content="The Actor's Office Application" name="description" />
        <meta content="Jodie Bentley" name="author" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />

<!--- App css --->
		<link href="/assets/css/bootstrap-modern.min.css" rel="stylesheet" type="text/css" id="bs-default-stylesheet" />
		<link href="/assets/css/app-modern.min.css" rel="stylesheet" type="text/css" id="app-default-stylesheet" />

		<link href="/assets/css/bootstrap-modern-dark.min.css" rel="stylesheet" type="text/css" id="bs-dark-stylesheet" />
		<link href="/assets/css/app-modern-dark.min.css" rel="stylesheet" type="text/css" id="app-dark-stylesheet" />

		<!--- icons --->
		<link href="/assets/css/icons.min.css" rel="stylesheet" type="text/css" />

    </head>

    <body class="loading" style="background-color: #406E8E;  font-family: 'Source Sans Pro', sans-serif;">

        <div class="account-pages mt-5 mb-5">
            <div class="container">
                <div class="row justify-content-center">
                    <div class="col-md-8 col-lg-6 col-xl-5">
                        <div class="card ">

                            <div class="card-body p-4">
                                
                                <div class="text-center w-85 m-auto">
                                    <div class="auth-logo">
                                        <a href="" class="logo no-hover-effect logo-dark text-center">
                                            <span class="logo no-hover-effect-lg">
                                                <img src="/assets/images/taowhite.png" alt="" height="60" />
                                            </span>
                                        </a>
                    
                                        <a href="" class="logo no-hover-effect logo-light text-center">
                                            <span class="logo no-hover-effect-lg">
                                                <img src="/assets/images/logo-dark.png" alt="" height="20" />
                                            </span>
                                        </a>
                                    </div>
                                    <h5>Setup Complete</h5>
                                    <p class="text-muted mb-4 mt-3" style="font-size:14px;">You may now log into your account.</p>
                                </div>
                            <form action="<cfoutput>https://#cgi.server_name#/</cfoutput>">
         <div class="form-group mb-0 text-center">
                                  <a href="">         <button class="btn btn-block" style="color: white;background-color: #406E8E;border-color:#406E8E;" type="submit" value="Log In"> Log In </button>
                                    </div>                      
                        </form>
                            </div> <!--- end card-body --->
                        </div>
                        <!--- end card --->

                      <!--- end row --->

                    </div> <!--- end col --->
                </div>
                <!--- end row --->
            </div>
            <!--- end container --->
        </div>
        <!--- end page --->

<footer class="footer footer-alt text-white-50">
              &copy; 2021 The Actor's Office &trade; - All Right Reserved.
        </footer>

        <!--- Vendor js --->
        <script src="/assets/js/vendor.min.js"></script>

        <script src="/assets/libs/parsleyjs/parsley.min.js"></script>
        
        <!--- App js --->
        <script src="/assets/js/app.min.js"></script>
   
    </body>
</html>
