<!--- 
    ONE-TIME BACKFILL: Send "Implemented" notification emails
    for tickets whose status was changed via Claude Code (not via form).
    
    HOW TO USE:
    1. Upload to /app/admin-support/ (or wherever you have access)
    2. Hit it in the browser: https://dev.theactorsoffice.com/app/admin-support/backfill_implemented_emails.cfm
    3. Review the output
    4. DELETE THIS FILE when done
    
    TECH-DEBT: This file should be deleted after use. It exists only for the backfill.
--->

<!--- Determine host for email links --->
<cfset variables.host = cgi.SERVER_NAME />

<!--- DRY RUN by default — change to false to actually send --->
<cfset variables.dryRun = true />

<cfoutput>
<html>
<head><title>Backfill: Implemented Ticket Emails</title></head>
<body style="font-family: Arial, sans-serif; padding: 20px;">
<h2>Backfill: "Implemented" Ticket Notification Emails</h2>
<p><strong>Mode: <cfif variables.dryRun><span style="color:orange;">DRY RUN</span> — no emails will be sent<cfelse><span style="color:red;">LIVE</span> — emails WILL be sent</cfif></strong></p>
<hr />
</cfoutput>

<!--- Pull the tickets that need backfill --->
<cfquery name="qBackfillTickets" datasource="abo">
    SELECT
        ticketid,
        ticketName,
        ticketStatus,
        esthours,
        ticketCompletedDate,
        LEFT(ticketResponse, 100) AS response_preview,
        LEFT(testingscript, 60)   AS script_preview
    FROM tickets
    WHERE ticketresponse LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%triage%" />
      AND ticketstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="Implemented" />
    ORDER BY ticketid
</cfquery>

<cfoutput><p>Found <strong>#qBackfillTickets.recordCount#</strong> ticket(s) to process.</p></cfoutput>

<cfif qBackfillTickets.recordCount EQ 0>
    <cfoutput><p>Nothing to do.</p></body></html></cfoutput>
    <cfabort />
</cfif>

<!--- Set email details (matches your existing ticket status change logic) --->
<cfset variables.emailto = "cansoff@gmail.com" />
<cfset variables.emailcc = "jodie@jodiebentley.com, support@theactorsoffice.com" />

<cfset variables.sentCount = 0 />
<cfset variables.errorCount = 0 />

<cfoutput>
<table border="1" cellpadding="8" cellspacing="0" style="border-collapse: collapse; width: 100%;">
    <tr style="background: ##e0e0e0;">
        <th>##</th>
        <th>Ticket ID</th>
        <th>Name</th>
        <th>Est Hours</th>
        <th>Completed</th>
        <th>Status</th>
    </tr>
</cfoutput>

<cfloop query="qBackfillTickets">
    <cftry>
        <!--- Set the variables the email template expects --->
        <cfset emailto = variables.emailto />
        <cfset emailcc = variables.emailcc />
        <cfset emailsubject = "Ready for Testing Approval — #qBackfillTickets.ticketName#" />
        <cfset emailmessage = "Please review the Testing Script and approve for Testing." />
        <cfset emaillink = "https://#variables.host#/app/admin-support-details/?recid=#qBackfillTickets.ticketid#" />
        <cfset emaillinkname = "REVIEW" />

        <cfif NOT variables.dryRun>
            <cfinclude template="ticketemail.cfm" />
        </cfif>

        <cfset variables.sentCount++ />

        <cfoutput>
        <tr>
            <td>#variables.sentCount#</td>
            <td>#qBackfillTickets.ticketid#</td>
            <td>#htmlEditFormat(qBackfillTickets.ticketName)#</td>
            <td>#qBackfillTickets.esthours#</td>
            <td>#isDate(qBackfillTickets.ticketCompletedDate) ? dateFormat(qBackfillTickets.ticketCompletedDate, "mm/dd/yyyy") : "—"#</td>
            <td style="color: green;"><cfif variables.dryRun>Would send<cfelse>Sent</cfif></td>
        </tr>
        </cfoutput>

        <cfcatch type="any">
            <cfset variables.errorCount++ />
            <cfoutput>
            <tr style="background: ##ffe0e0;">
                <td>#variables.sentCount + variables.errorCount#</td>
                <td>#qBackfillTickets.ticketid#</td>
                <td>#htmlEditFormat(qBackfillTickets.ticketName)#</td>
                <td>#qBackfillTickets.esthours#</td>
                <td>—</td>
                <td style="color: red;">ERROR: #htmlEditFormat(cfcatch.message)#</td>
            </tr>
            </cfoutput>
            <cflog file="TAO_backfill" text="Backfill email error for ticketid=#qBackfillTickets.ticketid#: #cfcatch.message#" />
        </cfcatch>
    </cftry>
</cfloop>

<cfoutput>
</table>

<hr />
<h3>Summary</h3>
<p><cfif variables.dryRun>Would send<cfelse>Sent</cfif>: <strong>#variables.sentCount#</strong></p>
<p>Errors: <strong>#variables.errorCount#</strong></p>

<cfif variables.dryRun>
    <p style="margin-top: 20px; padding: 12px; background: ##fff3cd; border: 1px solid ##ffc107; border-radius: 4px;">
        This was a <strong>DRY RUN</strong>. To send emails for real, edit the script and set 
        <code>variables.dryRun = false</code>, then reload.
    </p>
</cfif>

<p style="margin-top: 20px; color: ##999;"><em>Delete this file when done.</em></p>
</body>
</html>
</cfoutput>
