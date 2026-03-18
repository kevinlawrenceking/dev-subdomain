<!--- This ColdFusion page handles Google OAuth authentication and token storage --->

<cfoauth 
    type="google" 
    clientid="764716537559-ncfiag8dl4p05v7c9kcoltss0ou3heki.apps.googleusercontent.com" 
    secretkey="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" 
    redirecturi="https://dev.theactorsoffice.com/include/google_auth.cfm" 
    result="authResult" 
    scope="https://www.googleapis.com/auth/calendar">
</cfoauth>

<!--- Save the access token and refresh token in the database --->
<cfinclude template="/include/qry/updateUserToken_133_1.cfm" />

<!--- Redirect to a success page or continue with your application's flow --->
<cflocation url="/app/contacts/" addtoken="no">
