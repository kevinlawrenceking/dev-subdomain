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


<cfparam name="pwrong" default="" />
<cfparam name="u" default="" />
<cfparam name="p" default="" />
<cfparam name="pgaction" default="view">
<cfparam name="header" default="Password Recovery" />
<cfparam name="instruct"   default="We'll send you an email with instructions to reset your password." />

<cfif IsDefined("userid")>

    <cfcookie name="userid" value = "#Now()#" Expires="now" domain=".theactorsoffice.com">

    <cfset delete_cookie=StructDelete(cookie,"userid")>

</cfif>

<cfif #pgaction# is "recover">
    <cfset instruct = "An email has been sent to you with instructions on how to reset your password." />
    <cfset header = "Email Sent" />
    
    <cfquery result="result" name="find" datasource="#dsn#" >
    Select * from taousers where useremail = '#email#'
    </cfquery>
    
    <cfif #find.recordcount# is "1">
    
        <cfset recover = CreateUUID()/>
    
        <cfquery result="result" name="update" datasource="#dsn#">
        update taousers set recover = <cfqueryparam value="#recover#" cfsqltype="cf_sql_varchar" />
        where useremail = '#email#'
        </cfquery> 
        
        <cfmail from="support@theactorsoffice.com" to="#find.useremail#"  bcc="kevinking7135@gmail.com" subject="The Actor's Office - Password Recovery" type="HTML">
        <HTML>
       <head><title>The Actor's Office</title></head>
      <body class="loading" style="background-color: white; font-family: 'Source Sans Pro', sans-serif;">
           
           <style type="text/css">
               body { font-size: 14px; }
           </style>
           
            <p>Hi #find.userfirstname#,</p>

            <p>We've received a request for your password to be reset.</p>

            <p>Click on the link below to get started:</p>

            <p>To get started, click the button below where you'll create your password and be walked through the setup process.</p>

            <a href="https://#cgi.server_name#/recover/?cid=#find.contactid#&email=#find.useremail#&recover=#recover#"><button>RESET MY PASSWORD</button></a>

            <p>If you have any questions, simply respond to this email.</p>

            <p>The Actor's Office Support Team</p>

            <p>&nbsp;</p> 

            </body>

            </HTML>
            
            </cfmail>
        
        <cfelse>
        
            <cfset pgaction = "fail">
   
    </cfif>

</cfif> 

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <title>Password Recovery | The Actor's Office</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta content="The Actor's Office Application" name="description" />
        <meta content="Jodie Bentley" name="author" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <link rel="shortcut icon" href="/media/shared/images/favicon.ico">

        <!--- App css --->
        <link href="/app/assets/css/app.min.css?ver=#rand()#" rel="stylesheet" type="text/css" id="app-style" />
        <!--- icons --->
        <link href="/app/assets/css/icons.min.css" rel="stylesheet" type="text/css" />
 
    </head>

    <body class="loading" style="background-color: #406E8E;  font-family: 'Source Sans Pro', sans-serif;">

        <div class="account-pages mt-5 mb-5">
            <div class="container">
                <div class="row justify-content-center">
                    <div class="col-md-8 col-lg-6 col-xl-5">
                         <div class="card mb-3" style="background-color:white;bgcolor:white;">

                            <div class="card-body p-4">
                                
                                <div class="text-center w-85 m-auto">
                                    <div class="auth-logo">
                                        <a href="index.html" class="logo no-hover-effect logo-dark text-center>
                                            <span class="logo no-hover-effect-lg">
                                                <img src="<cfoutput>#application.imagesUrl#/taowhite.png</cfoutput>" alt="" class="w-100">
                                            </span>
                                        </a>
                    
                                        <a href="index.html" class="logo no-hover-effect logo-light text-center">
                                            <span class="logo no-hover-effect-lg">
                                                <img src="/media/shared/images/logo-dark.png" alt="" class="w-100 no-hover-effect" />
                                            </span>
                                        </a>
                                        <h5><cfoutput>#header#</cfoutput></h5>
                                    </div>
                                    <p class="text-muted mb-4 mt-3" style="font-size:14px;"><cfoutput>#instruct#</cfoutput>            <p class="text-muted mb-4 mt-3"></p></p>
                                </div>

<cfif #pgaction# is "fail">
        <Cfoutput>
	 <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                
                                     Email not found! 

</div> <P></P>
            <A href="/auth-recoverpw.cfm?pgaction=view"><button class="btn btn-primary" type="submit"> Try Again </button></A>
         
		<cfset pwrong = "N" />	</Cfoutput>  
	</cfif>
	
	<cfif #pgaction# is "view">
                                <form id="demo-form" action="auth-recoverpw.cfm" method="post" >
<input type="hidden" name="pwrong" value="N" />
                                    <input type="hidden" name="pgaction" value="recover" />
                                    <div class="form-group mb-3">
                                        <label for="emailaddress">Email address</label>
                                        <input class="form-control" type="email"   id="email" name="email" required="" placeholder="Enter your email" />
                                    </div>

<div class="form-group mb-0 text-center">
                                        <button class="btn btn-primary"  type="submit" value="Log In"> Reset Password </button>
                                    </div>

                                </form>
                          
                            </cfif>

                            </div> <!--- end card-body --->
                        </div>
                        <!--- end card --->
 
                        <!--- end row --->
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
        <script src="/app/assets/js/vendor.min.js"></script>

<!--- App js --->
        <script src="/app/assets/js/app.min.js"></script>
        
    </body>
</html>
