<cfparam name="u" default="" />
<cfparam name="p" default="" />
<cfparam name="recover" default="" />
<cfparam name="uuid" default="" />

<cfquery result="result" name="U" >
SELECT th.id
,th.CustomerFirst
,th.CustomerLast
,th.CustomerEmail
,th.`status`
,th.BaseProductLabel 
,pp.planName
,th.uuid
,'' as 'newpassword'
FROM thrivecart th 
LEFT JOIN paymentplans pp ON pp.BasePaymentPlanId = th.BasePaymentPlanId
LEFT JOIN products pr ON pr.BaseProductId = th.BaseProductId
WHERE th.STATUS = 'Emailed' and th.uuid = '#uuid#'
</cfquery>

<cfif #u.recordcount# is not "1">
<cflocation url="/app/dashboard_new/" />

</cfif>

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
        <!--- App favicon --->
        <link rel="shortcut icon" href="/media/shared/images/favicon.ico">

		<!--- App css --->
                                <link href="/media/shared/images/favicon.ico"  rel="shortcut icon"
                 type="text/css"  />
                
                    <script src="/app/assets/js/jquery-3.6.0.min.js?version=1.4"></script>
                    
                                <link href="/app/assets/css/icons.min.css"  rel="stylesheet"
                 type="text/css"  />
                
                                <link href="/assets/css/utilityclasses.css"  rel="stylesheet"
                 type="text/css"  />
                
                    <script src="/app/assets/js/jquery.chained.js?version=1.4"></script>
                    
                     
              <link href="/app/assets/css/app.min.css?ver=13.3.1.20.102243915958" rel="stylesheet"  type="text/css" id="app-style"/>
                
                                <link href="/app/assets/css/dragula.min.css"  type="text/css"  />

    </head>

    <body class="loading" style="background-color: white;  font-family: 'Source Sans Pro', sans-serif;">

        <div class="account-pages mt-5 mb-5">
            <div class="container">
                <div class="row justify-content-center">
                    <div class="col-md-8 col-lg-6 col-xl-5">
                        <div class="card ">

                            <div class="card-body p-4">
                                
                                <div class="text-center w-85 m-auto">
                                    <div class="auth-logo">
                                        <a href="index.html" class="logo no-hover-effect logo-dark text-center">
                                            <span class="logo no-hover-effect-lg">
                                                <img src="<cfoutput>#application.imagesUrl#/taowhite.png</cfoutput>" alt="" height="60">
                                            </span>
                                        </a>
                    
                                        <a href="index.html" class="logo no-hover-effect logo-light text-center">
                                            <span class="logo no-hover-effect-lg">
                                                <img src="<cfoutput>#application.imagesUrl#</cfoutput>/logo-dark.png" alt="" height="20">
                                            </span>
                                        </a>
                                    </div>
                                    <h5>Account Setup</h5>
                                    <p class="text-muted mb-4 mt-3" style="font-size:14px;">Enter your information below to setup your account.</p>
                                </div>
<Cfoutput>

<cfif #pwrong# is "Y">
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
                                <form action="setup2.cfm" method="post"  autocomplete="off" class="parsley-examples"
                                       data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden"
  data-parsley-trigger="keyup" data-parsley-validate>

<input type="hidden" name="pwrong" value="N" />
                                    
                                    <Cfoutput>
                  <input type="hidden" name="id" value="#u.id#" />      
                                    <div class="row">
                                    
                                                    <div class="form-group mb-2 col-md-6">
                                        <label for="customerfirst">First Name<span class="text-danger">*</span></label>
                                        <input class="form-control" type="text"  value="#u.customerfirst#" id="customerfirst" name="customerfirst" data-parsley-required data-parsley-error-message="First Name is required" placeholder="Enter your First Name" />
                                    </div>

<div class="form-group mb-2 col-md-6">
                                        <label for="emailaddress">Last Name<span class="text-danger">*</span></label>
                                        <input class="form-control" type="text"   value="#u.customerlast#" id="customerlast" name="customerlast"  data-parsley-required data-parsley-error-message="Last Name is required" placeholder="Enter your Last Name" />
                                    </div>

<div class="form-group mb-2 col-md-12">
                                        <label for="emailaddress">Email address<span class="text-danger">*</span></label>
                                        <input class="form-control"   value="#u.customeremail#" id="email_address" name="customeremail"  
                                               
                                               placeholder="Enter your email">
                                    </div>
                                    
                                        </cfoutput>
                                        
                                                <div class="form-group mb-2  col-md-12">
                                            <label for="pass1">Password<span class="text-danger">*</span></label>
                                            <input id="pass1" type="password" name="pass1" placeholder="Password" 
                                                    data-parsley-minlength="8" data-parsley-required 
                                                     data-parsley-minlength-message="Password must be a min of 8 chars"
                                                   
                                                   class="form-control">
                                        </div>
                                        <div class="form-group mb-2  col-md-12">
                                            <label for="passWord2">Confirm Password <span class="text-danger">*</span></label>
                                            <input data-parsley-equalto="#pass1" name="pass2" type="password"   data-parsley-error-message="Passwords must match" 
                                                   data-parsley-minlength="8" data-parsley-required  data-parsley-minlength-message="Password must be a min of 8 chars"
                                                   placeholder="Password" class="form-control" id="passWord2">
                                        </div>

<div class="form-group mb-3 col-md-12">
                                        <div class="custom-control custom-checkbox">
                                            <input type="checkbox" class="custom-control-input" id="checkbox-signin" checked />
                                            <label class="custom-control-label" for="checkbox-signin">I agree to the <A href="#">Terms & Conditions</A></label>
                                        </div>
                                    </div>

                                    <div class="form-group mb-0 text-center col-md-12">
                                        <button class="btn btn-block" style="color: white;background-color: #406E8E;border-color:#406E8E;" type="submit" value="create"> Create Account </button>
                                    </div>
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
 <script>      
 $(document).ready(function() {
    $(".parsley-examples").parsley()
});
 </script>  
        
<script>
  $(document).ready(function(){
      
    $('#email_address').parsley();

    window.ParsleyValidator.addValidator('checkemail', {
      validateString: function(value)
      {
        return $.ajax({
          url:'fetch.php',
          method:"POST",
          data:{email:value},
          dataType:"json",
          success:function(data)
          {
            return true;
          }
        });
      }
    });

  });
</script>
        
    </body>
</html>
