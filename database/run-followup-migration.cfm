<cfsilent>
<!--- Migration Runner: 2026-06-22 tickets_tbl.followupEmailSentAt + view rebuild.
      Extends TAO-SPEC-2026-005 (user-facing error management flow).
      Idempotent: guarded by information_schema; safe to re-run.
      Env-agnostic: uses application.dsn and DATABASE(); no hardcoded schema/DSN.
      Usage: /database/run-followup-migration.cfm?run=yes --->
<cfinclude template="/database/admin-guard.cfm">
</cfsilent>
<cfset response = {success: false, step: "", message: "", results: []}>
<cftry>
<cfif not structKeyExists(url, "run") or url.run neq "yes">
    <cfset response.message = "Add ?run=yes to execute migration">
    <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
    <cfabort>
</cfif>

<!--- Step 0: environment guard - only proceed on the view/base-table split --->
<cfset response.step = "Step 0: environment guard">
<cfquery name="qGuard" datasource="#application.dsn#">
    SELECT
        (SELECT COUNT(*) FROM information_schema.tables
            WHERE table_schema = DATABASE() AND table_name = 'tickets' AND table_type = 'VIEW') AS isView,
        (SELECT COUNT(*) FROM information_schema.tables
            WHERE table_schema = DATABASE() AND table_name = 'tickets_tbl' AND table_type = 'BASE TABLE') AS hasTbl
</cfquery>
<cfif qGuard.isView neq 1 or qGuard.hasTbl neq 1>
    <cfset response.success = true>
    <cfset response.message = "No-op: this schema does not have the tickets view / tickets_tbl base-table split.">
    <cfset arrayAppend(response.results, "isView=" & qGuard.isView & " hasTbl=" & qGuard.hasTbl)>
    <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
    <cfabort>
</cfif>

<!--- Step 1: add followupEmailSentAt to tickets_tbl (idempotent) --->
<cfset response.step = "Step 1: add tickets_tbl.followupEmailSentAt">
<cfquery name="qCol" datasource="#application.dsn#">
    SELECT COUNT(*) AS cnt FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'tickets_tbl'
      AND column_name = 'followupEmailSentAt'
</cfquery>
<cfif qCol.cnt eq 0>
    <cfquery datasource="#application.dsn#">
        ALTER TABLE tickets_tbl ADD COLUMN followupEmailSentAt DATETIME NULL AFTER resolvedEmailSentAt
    </cfquery>
    <cfset arrayAppend(response.results, "Added tickets_tbl.followupEmailSentAt")>
<cfelse>
    <cfset arrayAppend(response.results, "tickets_tbl.followupEmailSentAt already exists")>
</cfif>

<!--- Step 2: drop the view --->
<cfset response.step = "Step 2: drop tickets view">
<cfquery datasource="#application.dsn#">
    DROP VIEW IF EXISTS tickets
</cfquery>
<cfset arrayAppend(response.results, "Dropped tickets view")>

<!--- Step 3: recreate the view with all 29 columns.
      DEFINER intentionally omitted here (defaults to the current connection user)
      so CREATE VIEW never requires SUPER on prod. SQL SECURITY DEFINER preserved.
      The canonical raw .sql migration retains the original kingk436@% definer for
      direct DBA execution. --->
<cfset response.step = "Step 3: recreate tickets view (29 cols)">
<cfquery datasource="#application.dsn#">
    CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `tickets` AS
    SELECT
        `tickets_tbl`.`ticketID` AS `ticketID`,
        `tickets_tbl`.`pgID` AS `pgID`,
        `tickets_tbl`.`ticketName` AS `ticketName`,
        `tickets_tbl`.`ticketDetails` AS `ticketDetails`,
        `tickets_tbl`.`ticketResponse` AS `ticketResponse`,
        `tickets_tbl`.`userid` AS `userid`,
        `tickets_tbl`.`ticketCreatedDate` AS `ticketCreatedDate`,
        `tickets_tbl`.`ticketCompletedDate` AS `ticketCompletedDate`,
        `tickets_tbl`.`ticketStatus` AS `ticketStatus`,
        `tickets_tbl`.`ticketActive` AS `ticketActive`,
        `tickets_tbl`.`ticketType` AS `ticketType`,
        `tickets_tbl`.`recordname` AS `recordname`,
        `tickets_tbl`.`IsDeleted` AS `IsDeleted`,
        `tickets_tbl`.`initial_email` AS `initial_email`,
        `tickets_tbl`.`complete_email` AS `complete_email`,
        `tickets_tbl`.`ticketstring` AS `ticketstring`,
        `tickets_tbl`.`verid` AS `verid`,
        `tickets_tbl`.`patchNote` AS `patchNote`,
        `tickets_tbl`.`environ` AS `environ`,
        `tickets_tbl`.`ticketPriority` AS `ticketPriority`,
        `tickets_tbl`.`estHours` AS `estHours`,
        `tickets_tbl`.`testingScript` AS `testingScript`,
        `tickets_tbl`.`customTestPageName` AS `customTestPageName`,
        `tickets_tbl`.`customTestPageLink` AS `customTestPageLink`,
        `tickets_tbl`.`errorid` AS `errorid`,
        `tickets_tbl`.`developerResponse` AS `developerResponse`,
        `tickets_tbl`.`resolvedEmailSentAt` AS `resolvedEmailSentAt`,
        `tickets_tbl`.`ackEmailSentAt` AS `ackEmailSentAt`,
        `tickets_tbl`.`followupEmailSentAt` AS `followupEmailSentAt`
    FROM `tickets_tbl` WHERE (`tickets_tbl`.`IsDeleted` = 0)
</cfquery>
<cfset arrayAppend(response.results, "Recreated tickets view with followupEmailSentAt")>

<!--- Post-check --->
<cfset response.step = "Post-check">
<cfquery name="qVerify" datasource="#application.dsn#">
    SELECT table_name, column_name FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name IN ('tickets','tickets_tbl')
      AND column_name = 'followupEmailSentAt'
    ORDER BY table_name
</cfquery>
<cfset arrayAppend(response.results, "Post-check rows (expect 2): " & qVerify.recordCount)>

<cfset response.success = true>
<cfset response.message = "Follow-up migration completed successfully">

<cfcatch type="any">
    <cfset response.message = "Error at step [" & response.step & "]: " & cfcatch.message>
    <cfif structKeyExists(cfcatch, "detail") and len(cfcatch.detail)>
        <cfset response.message = response.message & " | Detail: " & cfcatch.detail>
    </cfif>
    <cfif structKeyExists(cfcatch, "sql") and len(cfcatch.sql)>
        <cfset response.message = response.message & " | SQL: " & left(cfcatch.sql, 200)>
    </cfif>
</cfcatch>
</cftry>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
