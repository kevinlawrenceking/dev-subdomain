<cfsilent>
<!---
    Admin User Management - Send Email to User
    POST /app/admin-users/ajax/send-email.cfm

    Form Parameters:
    - userid (required): Target user ID
    - template (required): "welcome" or "password_reset"

    Returns JSON: { success, message }

    Welcome email: Looks up or creates a setup UUID in the thrivecart table,
    then sends the standard welcome/setup email.

    Password reset: Generates a recover UUID, stores it in taousers.recover,
    then sends the password reset email.
--->

<cfset variables.isAjax = true>
<cfinclude template="../admin-guard.cfm">

<cfset variables.response = { "success": false, "message": "", "data": {} }>

<cftry>
    <cfparam name="form.userid" default="0">
    <cfparam name="form.template" default="">

    <cfset variables.targetUserId = val(form.userid)>
    <cfif variables.targetUserId lte 0>
        <cfset variables.response.message = "Valid userid is required">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <cfset variables.templateName = lcase(trim(form.template))>
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

    <cfset variables.userEmail = variables.userData.userEmail>
    <cfset variables.userFirst = variables.userData.userFirstName>
    <cfset variables.hostName = cgi.server_name>

    <!--- ================================================================
         WELCOME EMAIL
         ================================================================ --->
    <cfif variables.templateName eq "welcome">

        <!--- Get or create setup UUID via thrivecart table (linked by customerid) --->
        <cfset variables.customerId = variables.userData.customerid>

        <cfif not isNumeric(variables.customerId) or variables.customerId lte 0>
            <cfset variables.response.message = "This user has no customer/thrivecart record. Welcome email requires a customerid.">
            <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
        </cfif>

        <!--- Look up existing UUID --->
        <cfset variables.qTC = queryExecute(
            "SELECT id, uuid FROM thrivecart WHERE id = :cid",
            { cid: { value: variables.customerId, cfsqltype: "cf_sql_integer" } },
            { datasource: application.datasource }
        )>

        <cfif variables.qTC.recordCount eq 0>
            <cfset variables.response.message = "No thrivecart record found for customerid " & variables.customerId>
            <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
        </cfif>

        <cfset variables.setupUUID = variables.qTC.uuid>

        <!--- Generate new UUID if empty --->
        <cfif not len(trim(variables.setupUUID))>
            <cfset variables.setupUUID = createUUID()>
            <cfset queryExecute(
                "UPDATE thrivecart SET uuid = :uuid WHERE id = :cid",
                {
                    uuid: { value: variables.setupUUID, cfsqltype: "cf_sql_varchar" },
                    cid: { value: variables.customerId, cfsqltype: "cf_sql_integer" }
                },
                { datasource: application.datasource }
            )>
        </cfif>

        <!--- Send welcome email --->
        <cftry>
            <cfmail
                from="support@theactorsoffice.com"
                to="#variables.userEmail#"
                subject="#variables.userFirst#, set up your profile for The Actor's Office!"
                type="HTML">
            <cfoutput>
            <HTML>
            <head><title>The Actor's Office</title></head>
            <body>
                <style type="text/css">body { font-size: 14px; }</style>
                <p>Hi #encodeForHTML(variables.userFirst)#,</p>
                <p>Your account for The Actor's Office has been created.</p>
                <p>Now, it's time for you to create your user profile and get immediate access to the system.</p>
                <p>To get started, click the button below where you'll create your password and be walked through the setup process.</p>
                <p><a href="https://#encodeForHTML(variables.hostName)#/setup/?uuid=#encodeForURL(variables.setupUUID)#"><button>GET STARTED</button></a></p>
                <p>If you have any questions, simply respond to this email.</p>
                <p>Welcome aboard!</p>
                <p>More to come...</p>
                <p>Jodie Bentley and The Actor's Office Team</p>
            </body>
            </HTML>
            </cfoutput>
            </cfmail>

            <cflog file="admin_users" text="[send-email] WELCOME sent to userid=#variables.targetUserId# email=#variables.userEmail# by admin=#session.userid#">

            <cfset variables.response.success = true>
            <cfset variables.response.message = "Welcome email sent to " & variables.userEmail>

            <cfcatch type="any">
                <cfset variables.response.message = "Failed to send welcome email: " & cfcatch.message>
                <cflog file="admin_users" text="[send-email] WELCOME FAILED userid=#variables.targetUserId#: #cfcatch.message#">
            </cfcatch>
        </cftry>

    <!--- ================================================================
         PASSWORD RESET EMAIL
         ================================================================ --->
    <cfelseif variables.templateName eq "password_reset">

        <!--- Generate recover UUID and store it --->
        <cfset variables.recoverUUID = createUUID()>
        <cfset queryExecute(
            "UPDATE taousers SET recover = :recover WHERE userid = :uid",
            {
                recover: { value: variables.recoverUUID, cfsqltype: "cf_sql_varchar" },
                uid: { value: variables.targetUserId, cfsqltype: "cf_sql_integer" }
            },
            { datasource: application.datasource }
        )>

        <!--- Get customerid for the reset link --->
        <cfset variables.customerId = variables.userData.customerid>

        <!--- Send password reset email --->
        <cftry>
            <cfmail
                from="support@theactorsoffice.com"
                to="#variables.userEmail#"
                subject="The Actor's Office - Password Reset"
                type="HTML">
            <cfoutput>
            <HTML>
            <head><title>The Actor's Office</title></head>
            <body style="background-color: white; font-family: 'Source Sans Pro', sans-serif;">
                <style type="text/css">body { font-size: 14px; }</style>
                <p>Hi #encodeForHTML(variables.userFirst)#,</p>
                <p>An administrator has requested a password reset for your account.</p>
                <p>Click on the link below to set a new password:</p>
                <p><a href="https://#encodeForHTML(variables.hostName)#/recover/?cid=#encodeForURL(variables.customerId)#&email=#encodeForURL(variables.userEmail)#&recover=#encodeForURL(variables.recoverUUID)#"><button>RESET MY PASSWORD</button></a></p>
                <p>If you did not request this, you can safely ignore this email.</p>
                <p>The Actor's Office Support Team</p>
            </body>
            </HTML>
            </cfoutput>
            </cfmail>

            <cflog file="admin_users" text="[send-email] PASSWORD_RESET sent to userid=#variables.targetUserId# email=#variables.userEmail# by admin=#session.userid#">

            <cfset variables.response.success = true>
            <cfset variables.response.message = "Password reset email sent to " & variables.userEmail>

            <cfcatch type="any">
                <cfset variables.response.message = "Failed to send password reset email: " & cfcatch.message>
                <cflog file="admin_users" text="[send-email] PASSWORD_RESET FAILED userid=#variables.targetUserId#: #cfcatch.message#">
            </cfcatch>
        </cftry>
    </cfif>

    <cfcatch type="any">
        <cfset variables.response.message = "Email send failed: " & cfcatch.message>
        <cflog file="admin_users" text="[send-email] ERROR: #cfcatch.message# #cfcatch.detail#">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
