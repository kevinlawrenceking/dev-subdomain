<cfsilent>
<!---
  TAO-SPEC-2026-005 (user-facing error mgmt flow): 3-day ticket follow-up job.

  Sends a single follow-up email 3+ days after the resolution email was sent,
  only when a resolution email actually went out (resolvedEmailSentAt IS NOT NULL)
  and the user has an email on file. The 3-day window is measured from
  resolvedEmailSentAt (NOT ticketCompletedDate).

  SECURITY: runs under the existing sched/Application.cfc gate (localhost / same-server
  scheduler bypass, or an authenticated session). No public unauthenticated trigger.

  IDEMPOTENT: claims each row atomically (UPDATE ... WHERE followupEmailSentAt IS NULL)
  before sending; only the winning request sends. On send failure the claim is reverted
  so a later run retries. A second run finds followupEmailSentAt set and is a no-op.

  Usage (manual/admin or scheduler): /sched/ticket_followup.cfm
--->
</cfsilent>
<cfset summary = { success = false, scanned = 0, claimed = 0, sent = 0, failed = 0, skipped = 0, results = [] }>
<cftry>

<!--- Candidates: resolution email sent 3+ days ago, no follow-up yet, user has email. --->
<cfquery name="qDue" datasource="#application.dsn#">
    SELECT t.ticketID, t.errorid, t.resolvedEmailSentAt,
           u.useremail, u.userfirstname,
           et.ticket_id AS errRef
    FROM tickets_tbl t
    INNER JOIN taousers_tbl u ON u.userid = t.userid
    LEFT JOIN error_tickets et ON et.id = t.errorid
    WHERE t.IsDeleted = 0
      AND t.resolvedEmailSentAt IS NOT NULL
      AND t.resolvedEmailSentAt <= (NOW() - INTERVAL 3 DAY)
      AND t.followupEmailSentAt IS NULL
      AND u.useremail IS NOT NULL
      AND u.useremail <> ''
    ORDER BY t.resolvedEmailSentAt
    LIMIT 500
</cfquery>
<cfset summary.scanned = qDue.recordCount>

<cfloop query="qDue">
    <cfset rowOutcome = { ticketID = qDue.ticketID, status = "" }>

    <!--- Atomic claim: only the request that flips NULL -> NOW() proceeds. --->
    <cfquery result="claimRes" datasource="#application.dsn#">
        UPDATE tickets_tbl
        SET followupEmailSentAt = NOW()
        WHERE ticketID = <cfqueryparam value="#qDue.ticketID#" cfsqltype="cf_sql_integer" />
          AND followupEmailSentAt IS NULL
    </cfquery>

    <cfif claimRes.recordCount NEQ 1>
        <cfset rowOutcome.status = "skipped (already claimed)">
        <cfset summary.skipped = summary.skipped + 1>
        <cfset arrayAppend(summary.results, rowOutcome)>
        <cfcontinue>
    </cfif>
    <cfset summary.claimed = summary.claimed + 1>

    <!--- Single user-facing reference: ERR-xxxx when linked, else TAO-#ticketID#. --->
    <cfset ref = (len(trim(qDue.errRef)) ? qDue.errRef : "TAO-" & qDue.ticketID)>

    <!--- Non-prod recipient redirect: never email a real user from dev/UAT. --->
    <cfset effectiveTo = (findNoCase("app", cgi.SERVER_NAME) GT 0) ? qDue.useremail : "kevinking7135@gmail.com">

    <cftry>
        <cfset request._userFollowupDiag = { reference = ref, userName = qDue.userfirstname }>
        <cfsavecontent variable="followupBody">
            <cfinclude template="/templates/email/user-followup.cfm" />
        </cfsavecontent>
        <cfset structDelete(request, "_userFollowupDiag")>

        <cfmail to="#effectiveTo#"
                from="support@theactorsoffice.com"
                replyto="support@theactorsoffice.com"
                subject="Following up on your support request -- #ref#"
                type="html"
                usessl="true"
                usetls="true">#followupBody#</cfmail>

        <cfquery datasource="#application.dsn#">
            INSERT INTO ticketslog_tbl (tlogDetails, userID, ticketid, ticketstatus)
            VALUES (
                <cfqueryparam value="Follow-up email sent to #effectiveTo# (#ref#)" cfsqltype="cf_sql_varchar" />,
                <cfqueryparam value="#qDue.userid#" cfsqltype="cf_sql_integer" />,
                <cfqueryparam value="#qDue.ticketID#" cfsqltype="cf_sql_integer" />,
                <cfqueryparam value="followup_email_sent" cfsqltype="cf_sql_varchar" />
            )
        </cfquery>

        <cfset rowOutcome.status = "sent">
        <cfset summary.sent = summary.sent + 1>
        <cflog file="TAO_ticket_followup" type="info"
               text="Follow-up sent for ticket #qDue.ticketID# (#ref#) to #effectiveTo#">

        <cfcatch type="any">
            <!--- Revert the claim so a later run retries; do not log a marker. --->
            <cftry>
                <cfquery datasource="#application.dsn#">
                    UPDATE tickets_tbl SET followupEmailSentAt = NULL
                    WHERE ticketID = <cfqueryparam value="#qDue.ticketID#" cfsqltype="cf_sql_integer" />
                </cfquery>
                <cfcatch></cfcatch>
            </cftry>
            <cfset rowOutcome.status = "failed: " & cfcatch.message>
            <cfset summary.failed = summary.failed + 1>
            <cflog file="TAO_ticket_followup" type="error"
                   text="Follow-up failed for ticket #qDue.ticketID# (#ref#) -- #cfcatch.message#; claim reverted">
        </cfcatch>
    </cftry>

    <cfset arrayAppend(summary.results, rowOutcome)>
</cfloop>

<cfset summary.success = true>

<cfcatch type="any">
    <cfset summary.message = "Follow-up job error: " & cfcatch.message>
    <cflog file="TAO_ticket_followup" type="error" text="Follow-up job aborted: #cfcatch.message#">
</cfcatch>
</cftry>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(summary)#</cfoutput>
