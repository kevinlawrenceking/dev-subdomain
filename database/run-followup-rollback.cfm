<cfsilent>
<!--- Rollback Runner: removes tickets_tbl.followupEmailSentAt and rebuilds the
      tickets view to its 28-column (post-2026-04-18) shape.
      Idempotent / env-agnostic. Usage: /database/run-followup-rollback.cfm?run=yes --->
<cfinclude template="/database/admin-guard.cfm">
</cfsilent>
<cfset response = {success: false, step: "", message: "", results: []}>
<cftry>
<cfif not structKeyExists(url, "run") or url.run neq "yes">
    <cfset response.message = "Add ?run=yes to execute rollback">
    <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
    <cfabort>
</cfif>

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
    <cfset response.message = "No-op: schema lacks the tickets view / tickets_tbl split.">
    <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
    <cfabort>
</cfif>

<!--- Step 1: drop view --->
<cfset response.step = "Step 1: drop tickets view">
<cfquery datasource="#application.dsn#">DROP VIEW IF EXISTS tickets</cfquery>
<cfset arrayAppend(response.results, "Dropped tickets view")>

<!--- Step 2: recreate 28-column view (no followupEmailSentAt) --->
<cfset response.step = "Step 2: recreate 28-col tickets view">
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
        `tickets_tbl`.`ackEmailSentAt` AS `ackEmailSentAt`
    FROM `tickets_tbl` WHERE (`tickets_tbl`.`IsDeleted` = 0)
</cfquery>
<cfset arrayAppend(response.results, "Recreated 28-column tickets view")>

<!--- Step 3: drop column (idempotent) --->
<cfset response.step = "Step 3: drop tickets_tbl.followupEmailSentAt">
<cfquery name="qCol" datasource="#application.dsn#">
    SELECT COUNT(*) AS cnt FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'tickets_tbl' AND column_name = 'followupEmailSentAt'
</cfquery>
<cfif qCol.cnt eq 1>
    <cfquery datasource="#application.dsn#">ALTER TABLE tickets_tbl DROP COLUMN followupEmailSentAt</cfquery>
    <cfset arrayAppend(response.results, "Dropped tickets_tbl.followupEmailSentAt")>
<cfelse>
    <cfset arrayAppend(response.results, "tickets_tbl.followupEmailSentAt already absent")>
</cfif>

<cfset response.success = true>
<cfset response.message = "Rollback completed successfully">
<cfcatch type="any">
    <cfset response.message = "Error at step [" & response.step & "]: " & cfcatch.message>
    <cfif structKeyExists(cfcatch, "sql") and len(cfcatch.sql)>
        <cfset response.message = response.message & " | SQL: " & left(cfcatch.sql, 200)>
    </cfif>
</cfcatch>
</cftry>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
