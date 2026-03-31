<cfsilent>
<!---
    Admin User Management - Send Email to User
    POST /app/admin-users/ajax/send-email.cfm

    Form Parameters:
    - userid (required): Target user ID
    - template (required): "welcome" or "password_reset"

    Returns JSON: { success, message, debug }

    Welcome email: Looks up or creates a setup UUID in the thrivecart table,
    then sends the standard welcome/setup email.

    Password reset: Generates a recover UUID, stores it in taousers.recover,
    then sends the password reset email.
--->

<cfset variables.isAjax = true>
<cfinclude template="../admin-guard.cfm">

<cfset variables.response = { "success": false, "message": "", "data": {} }>
<cfset variables.debugLog = []>

<!--- Helper to add timestamped debug entries --->
<cffunction name="addDebug" access="private" returntype="void" output="false">
    <cfargument name="msg" type="string" required="true">
    <cfset arrayAppend(variables.debugLog, "[" & timeFormat(now(), "HH:mm:ss.lll") & "] " & arguments.msg)>
</cffunction>

<cftry>
    <cfparam name="form.userid" default="0">
    <cfparam name="form.template" default="">

    <cfset variables.targetUserId = val(form.userid)>
    <cfset addDebug("start: userid=#variables.targetUserId# template=#form.template#")>

    <cfif variables.targetUserId lte 0>
        <cfset variables.response.message = "Valid userid is required">
        <cfset variables.response.debug = variables.debugLog>
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <cfset variables.templateName = lcase(trim(form.template))>
    <cfif not listFindNoCase("welcome,password_reset", variables.templateName)>
        <cfset variables.response.message = "Invalid template. Allowed: welcome, password_reset">
        <cfset variables.response.debug = variables.debugLog>
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <!--- Load user data --->
    <cfset addDebug("loading user data")>
    <cfset variables.svc = new services.UserService()>
    <cfset variables.userData = variables.svc.GetUserDetails(variables.targetUserId)>

    <cfif structIsEmpty(variables.userData) or (structKeyExists(variables.userData, "userid") and variables.userData.userid eq "")>
        <cfset addDebug("FAIL: user not found")>
        <cfset variables.response.message = "User not found">
        <cfset variables.response.debug = variables.debugLog>
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <cfset variables.userEmail = variables.userData.userEmail>
    <cfset variables.userFirst = variables.userData.userFirstName>
    <cfset variables.hostName = cgi.server_name>
    <cfset addDebug("user loaded: email=#variables.userEmail# firstName=#variables.userFirst# host=#variables.hostName#")>

    <!--- ================================================================
         WELCOME EMAIL
         ================================================================ --->
    <cfif variables.templateName eq "welcome">

        <!--- Get or create setup UUID via thrivecart table (linked by customerid) --->
        <cfset variables.customerId = variables.userData.customerid>
        <cfset addDebug("welcome: customerid=#variables.customerId#")>

        <cfif not isNumeric(variables.customerId) or variables.customerId lte 0>
            <!--- No thrivecart record exists. Create one so the setup flow works. --->
            <cfset addDebug("no customerid — creating thrivecart record for manual user")>
            <cfset variables.setupUUID = createUUID()>
            <cfset queryExecute(
                "INSERT INTO thrivecart_tbl (CustomerFirst, CustomerLast, CustomerEmail, BaseProductLabel, BaseProductID, BasePaymentPlanID, status, uuid)
                 VALUES (:first, :last, :email, 'Manual', '0', '0', 'Emailed', :uuid)",
                {
                    first: { value: variables.userFirst, cfsqltype: "cf_sql_varchar" },
                    last:  { value: variables.userData.userLastName, cfsqltype: "cf_sql_varchar" },
                    email: { value: variables.userEmail, cfsqltype: "cf_sql_varchar" },
                    uuid:  { value: variables.setupUUID, cfsqltype: "cf_sql_varchar" }
                },
                { datasource: application.datasource }
            )>
            <!--- Get the new thrivecart id and link it to the user --->
            <cfset variables.newTcId = queryExecute(
                "SELECT LAST_INSERT_ID() AS newid",
                {},
                { datasource: application.datasource }
            ).newid>
            <cfset queryExecute(
                "UPDATE taousers_tbl SET customerid = :cid WHERE userid = :uid",
                {
                    cid: { value: variables.newTcId, cfsqltype: "cf_sql_integer" },
                    uid: { value: variables.targetUserId, cfsqltype: "cf_sql_integer" }
                },
                { datasource: application.datasource }
            )>
            <cfset addDebug("created thrivecart record id=#variables.newTcId# and linked to user")>
        <cfelse>
            <!--- Look up existing UUID --->
            <cfset variables.qTC = queryExecute(
                "SELECT id, uuid FROM thrivecart WHERE id = :cid",
                { cid: { value: variables.customerId, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            )>

            <cfif variables.qTC.recordCount eq 0>
                <cfset addDebug("FAIL: no thrivecart record for customerid=#variables.customerId#")>
                <cfset variables.response.message = "No thrivecart record found for customerid " & variables.customerId>
                <cfset variables.response.debug = variables.debugLog>
                <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
            </cfif>

            <cfset variables.setupUUID = variables.qTC.uuid>

            <!--- Generate new UUID if empty --->
            <cfif not len(trim(variables.setupUUID))>
                <cfset variables.setupUUID = createUUID()>
                <cfset addDebug("generated new setup UUID")>
                <cfset queryExecute(
                    "UPDATE thrivecart_tbl SET uuid = :uuid WHERE id = :cid",
                    {
                        uuid: { value: variables.setupUUID, cfsqltype: "cf_sql_varchar" },
                        cid: { value: variables.customerId, cfsqltype: "cf_sql_integer" }
                    },
                    { datasource: application.datasource }
                )>
            <cfelse>
                <cfset addDebug("existing setup UUID found")>
            </cfif>
        </cfif>

        <!--- Send welcome email --->
        <cfset addDebug("sending welcome email to=#variables.userEmail# from=support@theactorsoffice.com")>
        <cftry>
            <cfmail
                from="support@theactorsoffice.com"
                to="#variables.userEmail#"
                bcc="kevinking7135@gmail.com"
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

            <cfset addDebug("cfmail executed OK (spooled)")>

            <!--- Set user status to Setup so admin knows they are awaiting setup --->
            <cfset queryExecute(
                "UPDATE taousers_tbl SET userstatus = 'Setup' WHERE userid = :uid",
                { uid: { value: variables.targetUserId, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            )>
            <cfset addDebug("user status changed to Setup")>

            <cflog file="admin_users" text="[send-email] WELCOME sent to userid=#variables.targetUserId# email=#variables.userEmail# by admin=#session.userid# | status set to Setup">

            <cfset variables.response.success = true>
            <cfset variables.response.message = "Welcome email sent to " & variables.userEmail & ". User status set to Setup.">

            <cfcatch type="any">
                <cfset addDebug("CFMAIL ERROR: " & cfcatch.message & " | " & cfcatch.detail)>
                <cfset variables.response.message = "Failed to send welcome email: " & cfcatch.message>
                <cfif len(cfcatch.detail)>
                    <cfset variables.response.message = variables.response.message & " - " & cfcatch.detail>
                </cfif>
                <cflog file="admin_users" text="[send-email] WELCOME FAILED userid=#variables.targetUserId#: #cfcatch.message# | #cfcatch.detail#">
            </cfcatch>
        </cftry>

    <!--- ================================================================
         PASSWORD RESET EMAIL
         ================================================================ --->
    <cfelseif variables.templateName eq "password_reset">

        <!--- Generate recover UUID and store it --->
        <cfset variables.recoverUUID = createUUID()>
        <cfset addDebug("password_reset: generated recover UUID")>
        <cfset queryExecute(
            "UPDATE taousers_tbl SET recover = :recover, recover_requested_at = NOW() WHERE userid = :uid",
            {
                recover: { value: variables.recoverUUID, cfsqltype: "cf_sql_varchar" },
                uid: { value: variables.targetUserId, cfsqltype: "cf_sql_integer" }
            },
            { datasource: application.datasource }
        )>

        <!--- Get customerid for the reset link --->
        <cfset variables.customerId = variables.userData.customerid>
        <cfset addDebug("sending password_reset email to=#variables.userEmail# from=support@theactorsoffice.com")>

        <!--- Send password reset email --->
        <cftry>
            <cfmail
                from="support@theactorsoffice.com"
                to="#variables.userEmail#"
                bcc="kevinking7135@gmail.com"
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

            <cfset addDebug("cfmail executed OK (spooled)")>
            <cflog file="admin_users" text="[send-email] PASSWORD_RESET sent to userid=#variables.targetUserId# email=#variables.userEmail# by admin=#session.userid#">

            <cfset variables.response.success = true>
            <cfset variables.response.message = "Password reset email sent to " & variables.userEmail>

            <cfcatch type="any">
                <cfset addDebug("CFMAIL ERROR: " & cfcatch.message & " | " & cfcatch.detail)>
                <cfset variables.response.message = "Failed to send password reset email: " & cfcatch.message>
                <cfif len(cfcatch.detail)>
                    <cfset variables.response.message = variables.response.message & " - " & cfcatch.detail>
                </cfif>
                <cflog file="admin_users" text="[send-email] PASSWORD_RESET FAILED userid=#variables.targetUserId#: #cfcatch.message# | #cfcatch.detail#">
            </cfcatch>
        </cftry>
    </cfif>

    <cfcatch type="any">
        <cfset addDebug("OUTER ERROR: " & cfcatch.message & " | " & cfcatch.detail)>
        <cfset variables.response.message = "Email send failed: " & cfcatch.message>
        <cflog file="admin_users" text="[send-email] ERROR: #cfcatch.message# #cfcatch.detail#">
    </cfcatch>
</cftry>

<cfset variables.response.debug = variables.debugLog>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
