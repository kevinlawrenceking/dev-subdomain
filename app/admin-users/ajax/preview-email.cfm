<cfsilent>
<!---
    Admin User Management - Preview Email Template
    GET /app/admin-users/ajax/preview-email.cfm

    URL Parameters:
    - userid (required): Target user ID
    - template (required): "welcome" or "password_reset"

    Returns JSON: { success, message, data: { subject, body (HTML), to } }
--->

<cfset variables.isAjax = true>
<cfinclude template="../admin-guard.cfm">

<cfset variables.response = { "success": false, "message": "", "data": {} }>

<cftry>
    <cfparam name="url.userid" default="0">
    <cfparam name="url.template" default="">

    <cfset variables.targetUserId = val(url.userid)>
    <cfif variables.targetUserId lte 0>
        <cfset variables.response.message = "Valid userid is required">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <cfset variables.templateName = lcase(trim(url.template))>
    <cfif not listFindNoCase("welcome,password_reset", variables.templateName)>
        <cfset variables.response.message = "Invalid template. Allowed: welcome, password_reset">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <!--- Load user data --->
    <cfset variables.svc = new services.UserService()>
    <cfset variables.userData = variables.svc.GetUserDetails(variables.targetUserId)>

    <cfif structIsEmpty(variables.userData) or (structKeyExists(variables.userData, "userid") and variables.userData.userid eq "")>
        <cfset variables.response.message = "User not found">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <!--- Build email data struct for template rendering --->
    <cfset variables.emailData = {
        "firstName": variables.userData.userFirstName,
        "lastName": variables.userData.userLastName,
        "email": variables.userData.userEmail,
        "recordname": variables.userData.recordname,
        "host": cgi.server_name
    }>

    <!--- Render template --->
    <cfset variables.subject = "">
    <cfset variables.body = "">

    <cfif variables.templateName eq "welcome">
        <cfset variables.subject = variables.emailData.firstName & ", set up your profile for The Actor's Office!">
        <cfsavecontent variable="variables.body">
            <cfoutput>
            <html>
            <head><title>The Actor's Office</title></head>
            <body>
                <style type="text/css">body { font-size: 14px; }</style>
                <p>Hi #encodeForHTML(variables.emailData.firstName)#,</p>
                <p>Your account for The Actor's Office has been created.</p>
                <p>Now, it's time for you to create your user profile and get immediate access to the system.</p>
                <p>To get started, click the button below where you'll create your password and be walked through the setup process.</p>
                <p><a href="https://#encodeForHTML(variables.emailData.host)#/setup/?uuid=[SETUP_UUID]" style="display:inline-block;padding:10px 20px;background-color:##4CAF50;color:white;text-decoration:none;border-radius:4px;">GET STARTED</a></p>
                <p>If you have any questions, simply respond to this email.</p>
                <p>Welcome aboard!</p>
                <p>More to come...</p>
                <p>Jodie Bentley and The Actor's Office Team</p>
            </body>
            </html>
            </cfoutput>
        </cfsavecontent>

    <cfelseif variables.templateName eq "password_reset">
        <cfset variables.subject = "The Actor's Office - Password Reset">
        <cfsavecontent variable="variables.body">
            <cfoutput>
            <html>
            <head><title>The Actor's Office</title></head>
            <body style="background-color: white; font-family: 'Source Sans Pro', sans-serif;">
                <style type="text/css">body { font-size: 14px; }</style>
                <p>Hi #encodeForHTML(variables.emailData.firstName)#,</p>
                <p>An administrator has requested a password reset for your account.</p>
                <p>Click on the link below to set a new password:</p>
                <p><a href="https://#encodeForHTML(variables.emailData.host)#/recover/?cid=[CUSTOMER_ID]&email=#encodeForURL(variables.emailData.email)#&recover=[RECOVER_UUID]" style="display:inline-block;padding:10px 20px;background-color:##4CAF50;color:white;text-decoration:none;border-radius:4px;">RESET MY PASSWORD</a></p>
                <p>If you did not request this, you can safely ignore this email.</p>
                <p>The Actor's Office Support Team</p>
            </body>
            </html>
            </cfoutput>
        </cfsavecontent>
    </cfif>

    <cfset variables.response.success = true>
    <cfset variables.response.data = {
        "subject": variables.subject,
        "body": trim(variables.body),
        "to": variables.emailData.email,
        "from": "support@theactorsoffice.com",
        "template": variables.templateName
    }>

    <cfcatch type="any">
        <cfset variables.response.message = "Preview failed: " & cfcatch.message>
        <cflog file="admin_users" text="[preview-email] ERROR: #cfcatch.message# #cfcatch.detail#">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
