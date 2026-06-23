<cfsilent>
<!--- Verification for 2026-06-22 follow-up migration + supporting facts for the
      proof bundle. Read-only. Usage: /database/verify-followup-migration.cfm --->
<cfinclude template="/database/admin-guard.cfm">
</cfsilent>
<cfset response = {success: false, message: "", checks: {}}>
<cftry>

<!--- Check 1: followupEmailSentAt present in BOTH tickets_tbl and tickets view --->
<cfquery name="q1" datasource="#application.dsn#">
    SELECT table_name, column_name, ordinal_position
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name IN ('tickets','tickets_tbl')
      AND column_name = 'followupEmailSentAt'
    ORDER BY table_name
</cfquery>
<cfset response.checks.followup_column = { found_rows: q1.recordCount, expected: 2 }>

<!--- Check 2: ticketslog_tbl timestamp column (informs cooldown design / proof) --->
<cfquery name="q2" datasource="#application.dsn#">
    SELECT column_name, data_type, column_default, extra
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'ticketslog_tbl'
      AND data_type IN ('datetime','timestamp')
    ORDER BY ordinal_position
</cfquery>
<cfset tsCols = []>
<cfloop query="q2"><cfset arrayAppend(tsCols, q2.column_name & " (" & q2.data_type & ", default=" & q2.column_default & ", extra=" & q2.extra & ")")></cfloop>
<cfset response.checks.ticketslog_timestamp_columns = tsCols>

<!--- Check 3: tickets_tbl.IsDeleted default (base-table INSERT lands in the view) --->
<cfquery name="q3" datasource="#application.dsn#">
    SELECT column_name, column_default, is_nullable
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'tickets_tbl'
      AND column_name = 'IsDeleted'
</cfquery>
<cfset response.checks.tickets_isdeleted_default = (q3.recordCount gt 0 ? q3.column_default : "N/A")>

<!--- Check 4: tickets_tbl.errorid present (initial-email link target) --->
<cfquery name="q4" datasource="#application.dsn#">
    SELECT column_name FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'tickets_tbl' AND column_name = 'errorid'
</cfquery>
<cfset response.checks.tickets_errorid_present = (q4.recordCount gt 0)>

<!--- Check 5: BACKLOG NON-GOAL PROOF. Existing Completed tickets have
      resolvedEmailSentAt NULL, so the follow-up job (which requires
      resolvedEmailSentAt IS NOT NULL) selects ZERO of them. No backfill. --->
<cfquery name="q5" datasource="#application.dsn#">
    SELECT
        SUM(CASE WHEN ticketStatus = 'Completed' THEN 1 ELSE 0 END) AS completed_total,
        SUM(CASE WHEN ticketStatus = 'Completed' AND resolvedEmailSentAt IS NULL THEN 1 ELSE 0 END) AS completed_no_resolved_email,
        SUM(CASE WHEN ticketStatus = 'Completed' AND resolvedEmailSentAt IS NOT NULL THEN 1 ELSE 0 END) AS completed_with_resolved_email
    FROM tickets_tbl
    WHERE IsDeleted = 0
</cfquery>
<cfset response.checks.backlog_non_goal = {
    completed_total: val(q5.completed_total),
    completed_no_resolved_email: val(q5.completed_no_resolved_email),
    completed_with_resolved_email_eligible: val(q5.completed_with_resolved_email),
    note: "Follow-up requires resolvedEmailSentAt IS NOT NULL; pre-deploy Completed tickets are excluded."
}>

<cfset response.success = true>
<cfset response.message = "Verification completed">
<cfcatch type="any">
    <cfset response.message = "Error: " & cfcatch.message>
</cfcatch>
</cftry>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
