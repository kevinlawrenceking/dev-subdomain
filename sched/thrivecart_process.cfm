<!--- 
    PURPOSE: Process pending ThriveCart orders and send welcome emails
    AUTHOR: Kevin King
    DATE: 2025-08-29
    DESCRIPTION: Scheduled task to handle ThriveCart order processing
--->

<cfparam name="dbug" default="N" />

<!--- Use datasource from Application.cfc --->
<cfset dsn = application.dsn />
<cfset rev = application.rev />
<cfset suffix = application.suffix />
<cfset information_schema = application.information_schema />

<!--- Set host from CGI or default --->
<cfset host = ListFirst(cgi.server_name, ".") />
<cfif not len(host) or host eq "localhost">
    <cfset host = "app" />
</cfif>

<cfset to_email = "kevinking7135@gmail.com" />

<cfquery result="result"  name="U" datasource="#application.dsn#">
    SELECT th.id
    ,th.CustomerFirst
    ,th.CustomerLast
    ,th.CustomerEmail
    ,th.`status`
    ,th.BaseProductLabel
    ,pp.planName
    FROM thrivecart th
    INNER JOIN paymentplans pp ON pp.BasePaymentPlanId = th.BasePaymentPlanId
    WHERE th.STATUS = 'Pending'
</cfquery>


<cfloop query="U">
    <cftry>
        <cfset new_id = U.id />

        <cfoutput>
            <cfset new_uuid = "#CreateUUID()#" />
            <cfset new_customerfirst = "#u.CustomerFirst#" />
            <cfset new_customerlast = "#u.CustomerLast#" />
            <cfset new_customerEmail = "#u.CustomerEmail#" />
            <cfset new_BaseProductLabel = "#u.BaseProductLabel#" />
            <cfset new_planName = "#u.planName#" />
        </cfoutput>

        <cfquery result="result" name="update" datasource="#application.dsn#">
            UPDATE thrivecart
            SET uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#new_uuid#" />
            WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#new_id#" />
        </cfquery>

        <!--- TAO-SETUP-TEST-HARNESS-01 (D3): setup-test email redirect.
              A test thrivecart row is flagged IsDemo=1 and carries the admin userid in
              thrivecart_tbl.userid. For those rows, send the setup email to that admin
              (with a [TEST] subject) instead of the customer. Real rows (IsDemo=0) are
              unchanged. Fail-safe: IsDemo=1 with no resolvable admin email -> suppress +
              log, never fall through to the synthetic customer address. --->
        <cfset mailTo = new_customerEmail />
        <cfset subjectPrefix = "" />
        <cfset suppressSend = false />
        <!--- PROD-SAFE: if thrivecart_tbl has no IsDemo/userid columns (a prod schema
              without the test fields) or any error occurs, fall back to a normal
              customer send so real welcome emails are never blocked. --->
        <cftry>
            <cfquery name="qTestFlag" datasource="#application.dsn#">
                SELECT IsDemo, userid AS test_admin_userid
                FROM thrivecart_tbl
                WHERE id = <cfqueryparam value="#new_id#" cfsqltype="cf_sql_integer" />
            </cfquery>
            <cfif qTestFlag.recordCount AND val(qTestFlag.IsDemo) EQ 1>
                <cfif isNumeric(qTestFlag.test_admin_userid) AND val(qTestFlag.test_admin_userid) GT 0>
                    <cfquery name="qTestAdmin" datasource="#application.dsn#">
                        SELECT userEmail FROM taousers
                        WHERE userid = <cfqueryparam value="#val(qTestFlag.test_admin_userid)#" cfsqltype="cf_sql_integer" />
                    </cfquery>
                    <cfif qTestAdmin.recordCount AND len(trim(qTestAdmin.userEmail))>
                        <cfset mailTo = trim(qTestAdmin.userEmail) />
                        <cfset subjectPrefix = "[TEST] " />
                        <cflog file="TAO_setup_test_harness"
                               text="thrivecart_process: test row id=#new_id# -> redirecting setup email to admin #qTestFlag.test_admin_userid# (#mailTo#).">
                    <cfelse>
                        <cfset suppressSend = true />
                        <cflog file="TAO_setup_test_harness" type="warning"
                               text="thrivecart_process: test row id=#new_id# IsDemo=1 but admin userid=#qTestFlag.test_admin_userid# has no email; suppressing (fail-safe).">
                    </cfif>
                <cfelse>
                    <cfset suppressSend = true />
                    <cflog file="TAO_setup_test_harness" type="warning"
                           text="thrivecart_process: test row id=#new_id# IsDemo=1 but no admin userid; suppressing (fail-safe).">
                </cfif>
            </cfif>
            <cfcatch type="any">
                <!--- Missing test columns (prod schema) or any error: send normally. --->
                <cfset mailTo = new_customerEmail />
                <cfset subjectPrefix = "" />
                <cfset suppressSend = false />
                <cflog file="TAO_setup_test_harness" type="warning"
                       text="thrivecart_process: test-redirect resolver skipped for id=#new_id# (#cfcatch.message#); sending normally.">
            </cfcatch>
        </cftry>

        <cftry>
            <cfif suppressSend>
                <cflog file="TAO_setup_test_harness" type="warning"
                       text="thrivecart_process: test row id=#new_id# send suppressed; marking Emailed without sending.">
            <cfelse>
            <cfmail
                from="support@theactorsoffice.com"
                to="#mailTo#"
                bcc="kevinking7135@gmail.com"
                subject="#subjectPrefix##new_customerfirst#, set up your profile for The Actor's Office!"
                type="HTML">
            <HTML>

            <head>
                <title>The Actor's Office</title>

            </head>

            <body>
                <!--- Style Tag in the Body, not Head, for Email --->
                <style type="text/css">
                    body {
                        font-size: 14px;
                    }

                </style>
                <p>Hi #new_customerfirst#,</p>

                <p>Your purchase of The Actor's Office has been received.</p>

                <p>Now, it's time for you to create your user profile and get immediate access to the system.</p>

                <p>To get started, click the button below where you'll create your password and be walked through the setup process.</p>

                <p><a href="https://#host#.theactorsoffice.com/setup/?uuid=#new_uuid#"><button>GET STARTED</button></a></p>

                <p>If you have any questions, simply respond to this email.</p>

                <p>Welcome aboard!</p>

                <p>More to come...</p>
                <p>Jodie Bentley and The Actor's Office Team</p>

                <p>&nbsp;</p>

            </body>

            </HTML>
            </cfmail>
            </cfif>

            <cfcatch type="any">
                <cflog file="TAO_thrivecart_mail_errors" 
                       text="Mail error for ThriveCart ID #new_id# (#new_customerEmail#): #cfcatch.message# - #cfcatch.detail#" 
                       type="error" />
                
                <!--- Skip the status update if mail fails --->
                <cfcontinue />
            </cfcatch>
        </cftry>

        <cfquery result="result" name="update2" datasource="#application.dsn#">
            UPDATE thrivecart
            SET status = <cfqueryparam cfsqltype="cf_sql_varchar" value="Emailed" />
            WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#new_id#" />
        </cfquery>

        <cfcatch>
            <cflog file="TAO_thrivecart_errors" 
                   text="Error processing ThriveCart ID #new_id#: #cfcatch.message#" 
                   type="error" />
            
            <!--- Continue processing other records even if one fails --->
        </cfcatch>
    </cftry>
</cfloop>

<cfinclude template="thrivecart_process_audition.cfm" />
