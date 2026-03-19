<!---
TAO Relationship System Audit Runner
Run this against the test database (new_development) to get audit counts
Access via: /scripts/relationship_system/run_audit.cfm

Security: This should be restricted to admin users only in production
--->
<!--- Derive dsn from host, never hardcode --->
<cfset host = ListFirst(cgi.server_name, ".") />
<cfparam name="dsn" default="#(host EQ 'app') ? 'abo' : 'abod'#" />
<cfparam name="showDetails" default="N" />

<!DOCTYPE html>
<html>
<head>
    <title>TAO Relationship System Audit</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 20px; }
        h1 { color: #333; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
        h2 { color: #555; margin-top: 30px; }
        table { border-collapse: collapse; margin: 10px 0; width: 100%; max-width: 1200px; }
        th, td { border: 1px solid #ddd; padding: 8px 12px; text-align: left; }
        th { background: #f5f5f5; font-weight: 600; }
        tr:nth-child(even) { background: #fafafa; }
        .count-zero { color: #28a745; font-weight: bold; }
        .count-warning { color: #ffc107; font-weight: bold; }
        .count-danger { color: #dc3545; font-weight: bold; }
        .summary-box { background: #f8f9fa; border: 1px solid #dee2e6; padding: 15px; margin: 20px 0; border-radius: 5px; }
        .timestamp { color: #666; font-size: 0.9em; }
        pre { background: #f5f5f5; padding: 10px; overflow-x: auto; font-size: 12px; }
        .toggle-details { cursor: pointer; color: #007bff; text-decoration: underline; }
    </style>
</head>
<body>

<h1>TAO Relationship System - Data Audit Report</h1>
<p class="timestamp">Generated: <cfoutput>#DateTimeFormat(Now(), "yyyy-mm-dd HH:nn:ss")#</cfoutput></p>
<p>Database: <cfoutput>#dsn#</cfoutput></p>

<cfset auditResults = {} />
<cfset startTime = GetTickCount() />

<!--- CATEGORY A: Orphaned Notifications --->
<cfquery name="A1_orphan_suid" datasource="#dsn#">
    SELECT COUNT(*) AS issue_count
    FROM funotifications n
    LEFT JOIN fusystemusers su ON su.suid = n.suid
    WHERE su.suid IS NULL
      AND n.isdeleted = 0
</cfquery>
<cfset auditResults.A1_orphan_suid = A1_orphan_suid.issue_count />

<cfquery name="A2_orphan_actionid" datasource="#dsn#">
    SELECT COUNT(*) AS issue_count
    FROM funotifications n
    LEFT JOIN fuactions a ON a.actionid = n.actionid
    WHERE a.actionid IS NULL
      AND n.isdeleted = 0
</cfquery>
<cfset auditResults.A2_orphan_actionid = A2_orphan_actionid.issue_count />

<cfquery name="A3_orphan_userid" datasource="#dsn#">
    SELECT COUNT(*) AS issue_count
    FROM funotifications n
    LEFT JOIN taousers u ON u.userid = n.userid
    WHERE u.userid IS NULL
      AND n.isdeleted = 0
</cfquery>
<cfset auditResults.A3_orphan_userid = A3_orphan_userid.issue_count />

<!--- CATEGORY B: Missing ActionUsers --->
<cfquery name="B1_missing_actionusers" datasource="#dsn#">
    SELECT COUNT(DISTINCT CONCAT(u.userid, '-', a.actionid)) AS issue_count
    FROM taousers u
    CROSS JOIN fuactions a
    LEFT JOIN actionusers au ON au.userid = u.userid AND au.actionid = a.actionid
    WHERE au.id IS NULL
      AND u.userstatus = 'Active'
</cfquery>
<cfset auditResults.B1_missing_actionusers = B1_missing_actionusers.issue_count />

<!--- CATEGORY C: Multiple Active Pending --->
<cfquery name="C1_multiple_active_pending" datasource="#dsn#">
    SELECT COUNT(*) AS issue_count
    FROM (
        SELECT suid
        FROM funotifications
        WHERE notstatus = 'Pending'
          AND notstartdate IS NOT NULL
          AND isdeleted = 0
        GROUP BY suid
        HAVING COUNT(*) > 1
    ) violations
</cfquery>
<cfset auditResults.C1_multiple_active_pending = C1_multiple_active_pending.issue_count />

<!--- CATEGORY D: Stuck Systems --->
<cfquery name="D1_stuck_no_pending" datasource="#dsn#">
    SELECT COUNT(*) AS issue_count
    FROM fusystemusers su
    LEFT JOIN funotifications n ON n.suid = su.suid
        AND n.notstatus = 'Pending'
        AND n.isdeleted = 0
    WHERE su.sustatus = 'Active'
      AND su.isdeleted = 0
      AND n.notid IS NULL
</cfquery>
<cfset auditResults.D1_stuck_no_pending = D1_stuck_no_pending.issue_count />

<cfquery name="D2_stuck_null_startdate" datasource="#dsn#">
    SELECT COUNT(DISTINCT su.suid) AS issue_count
    FROM fusystemusers su
    INNER JOIN funotifications n ON n.suid = su.suid
    WHERE su.sustatus = 'Active'
      AND su.isdeleted = 0
      AND n.notstatus = 'Pending'
      AND n.notstartdate IS NULL
      AND n.isdeleted = 0
      AND NOT EXISTS (
          SELECT 1 FROM funotifications n2
          WHERE n2.suid = su.suid
            AND n2.notstatus = 'Pending'
            AND n2.notstartdate IS NOT NULL
            AND n2.isdeleted = 0
      )
</cfquery>
<cfset auditResults.D2_stuck_null_startdate = D2_stuck_null_startdate.issue_count />

<!--- CATEGORY E: Duplicates --->
<cfquery name="E1_duplicate_active_enrollments" datasource="#dsn#">
    SELECT COUNT(*) AS issue_count
    FROM (
        SELECT userid, contactid, systemid
        FROM fusystemusers
        WHERE sustatus = 'Active'
          AND isdeleted = 0
        GROUP BY userid, contactid, systemid
        HAVING COUNT(*) > 1
    ) dups
</cfquery>
<cfset auditResults.E1_duplicate_active_enrollments = E1_duplicate_active_enrollments.issue_count />

<cfquery name="E2_duplicate_maintenance" datasource="#dsn#">
    SELECT COUNT(*) AS issue_count
    FROM (
        SELECT su.userid, su.contactid
        FROM fusystemusers su
        INNER JOIN fusystems s ON s.systemid = su.systemid
        WHERE s.systemtype = 'Maintenance List'
          AND su.sustatus = 'Active'
          AND su.isdeleted = 0
        GROUP BY su.userid, su.contactid
        HAVING COUNT(*) > 1
    ) dups
</cfquery>
<cfset auditResults.E2_duplicate_maintenance = E2_duplicate_maintenance.issue_count />

<!--- CATEGORY F: Uniqueness Violations --->
<cfquery name="F1_uniqueness_violations" datasource="#dsn#">
    SELECT COUNT(*) AS issue_count
    FROM (
        SELECT su.contactid, n.actionid
        FROM funotifications n
        INNER JOIN fusystemusers su ON su.suid = n.suid
        INNER JOIN fuactions a ON a.actionid = n.actionid
        WHERE a.isunique = 1
          AND n.notstatus = 'Completed'
          AND n.isdeleted = 0
        GROUP BY su.contactid, n.actionid
        HAVING COUNT(*) > 1
    ) violations
</cfquery>
<cfset auditResults.F1_uniqueness_violations = F1_uniqueness_violations.issue_count />

<!--- CATEGORY G: Scheduling Issues --->
<cfquery name="G1_overdue_future_status" datasource="#dsn#">
    SELECT COUNT(*) AS issue_count
    FROM funotifications
    WHERE notstatus = 'Future'
      AND notstartdate <= CURDATE()
      AND isdeleted = 0
</cfquery>
<cfset auditResults.G1_overdue_future_status = G1_overdue_future_status.issue_count />

<cfquery name="G2_ancient_pending" datasource="#dsn#">
    SELECT COUNT(*) AS issue_count
    FROM funotifications
    WHERE notstatus = 'Pending'
      AND notstartdate < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
      AND isdeleted = 0
</cfquery>
<cfset auditResults.G2_ancient_pending = G2_ancient_pending.issue_count />

<!--- CATEGORY H: Data Consistency --->
<cfquery name="H1_completed_with_pending" datasource="#dsn#">
    SELECT COUNT(*) AS issue_count
    FROM fusystemusers su
    INNER JOIN funotifications n ON n.suid = su.suid
    WHERE su.sustatus = 'Completed'
      AND n.notstatus = 'Pending'
      AND n.isdeleted = 0
      AND su.isdeleted = 0
</cfquery>
<cfset auditResults.H1_completed_with_pending = H1_completed_with_pending.issue_count />

<cfquery name="H2_pending_with_enddate" datasource="#dsn#">
    SELECT COUNT(*) AS issue_count
    FROM funotifications
    WHERE notstatus = 'Pending'
      AND notenddate IS NOT NULL
      AND isdeleted = 0
</cfquery>
<cfset auditResults.H2_pending_with_enddate = H2_pending_with_enddate.issue_count />

<!--- TOTALS --->
<cfquery name="totals" datasource="#dsn#">
    SELECT 'Active Systems' AS metric, COUNT(*) AS value
    FROM fusystemusers WHERE sustatus = 'Active' AND isdeleted = 0
    UNION ALL
    SELECT 'Completed Systems', COUNT(*)
    FROM fusystemusers WHERE sustatus = 'Completed' AND isdeleted = 0
    UNION ALL
    SELECT 'Pending Notifications', COUNT(*)
    FROM funotifications WHERE notstatus = 'Pending' AND isdeleted = 0
    UNION ALL
    SELECT 'Completed Notifications', COUNT(*)
    FROM funotifications WHERE notstatus = 'Completed' AND isdeleted = 0
    UNION ALL
    SELECT 'Skipped Notifications', COUNT(*)
    FROM funotifications WHERE notstatus = 'Skipped' AND isdeleted = 0
    UNION ALL
    SELECT 'Total Actions (fuactions)', COUNT(*)
    FROM fuactions
    UNION ALL
    SELECT 'Total ActionUsers', COUNT(*)
    FROM actionusers WHERE isdeleted = 0
    UNION ALL
    SELECT 'Active Users', COUNT(*)
    FROM taousers WHERE userstatus = 'Active'
</cfquery>

<cfset endTime = GetTickCount() />
<cfset executionTime = endTime - startTime />

<!--- Calculate total issues --->
<cfset totalIssues = 0 />
<cfloop collection="#auditResults#" item="key">
    <cfset totalIssues = totalIssues + auditResults[key] />
</cfloop>

<!--- Display Results --->
<div class="summary-box">
    <h2 style="margin-top: 0;">Summary</h2>
    <p><strong>Total Issues Found:</strong>
        <span class="<cfoutput>#totalIssues EQ 0 ? 'count-zero' : (totalIssues LT 10 ? 'count-warning' : 'count-danger')#</cfoutput>">
            <cfoutput>#totalIssues#</cfoutput>
        </span>
    </p>
    <p><strong>Execution Time:</strong> <cfoutput>#executionTime#</cfoutput> ms</p>
</div>

<h2>Issue Counts by Category</h2>
<table>
    <thead>
        <tr>
            <th>Issue Code</th>
            <th>Description</th>
            <th style="text-align: right;">Count</th>
            <th>Status</th>
        </tr>
    </thead>
    <tbody>
        <cfoutput>
        <tr>
            <td>A1</td>
            <td>Orphaned notifications (missing suid)</td>
            <td style="text-align: right;" class="#auditResults.A1_orphan_suid EQ 0 ? 'count-zero' : 'count-danger'#">#auditResults.A1_orphan_suid#</td>
            <td>#auditResults.A1_orphan_suid EQ 0 ? 'OK' : 'NEEDS FIX'#</td>
        </tr>
        <tr>
            <td>A2</td>
            <td>Orphaned notifications (missing actionid)</td>
            <td style="text-align: right;" class="#auditResults.A2_orphan_actionid EQ 0 ? 'count-zero' : 'count-danger'#">#auditResults.A2_orphan_actionid#</td>
            <td>#auditResults.A2_orphan_actionid EQ 0 ? 'OK' : 'NEEDS FIX'#</td>
        </tr>
        <tr>
            <td>A3</td>
            <td>Orphaned notifications (missing userid)</td>
            <td style="text-align: right;" class="#auditResults.A3_orphan_userid EQ 0 ? 'count-zero' : 'count-danger'#">#auditResults.A3_orphan_userid#</td>
            <td>#auditResults.A3_orphan_userid EQ 0 ? 'OK' : 'NEEDS FIX'#</td>
        </tr>
        <tr>
            <td>B1</td>
            <td>Missing actionusers rows</td>
            <td style="text-align: right;" class="#auditResults.B1_missing_actionusers EQ 0 ? 'count-zero' : 'count-warning'#">#auditResults.B1_missing_actionusers#</td>
            <td>#auditResults.B1_missing_actionusers EQ 0 ? 'OK' : 'REVIEW'#</td>
        </tr>
        <tr>
            <td>C1</td>
            <td>Multiple active pending per suid (violates one-at-a-time rule)</td>
            <td style="text-align: right;" class="#auditResults.C1_multiple_active_pending EQ 0 ? 'count-zero' : 'count-danger'#">#auditResults.C1_multiple_active_pending#</td>
            <td>#auditResults.C1_multiple_active_pending EQ 0 ? 'OK' : 'NEEDS FIX'#</td>
        </tr>
        <tr>
            <td>D1</td>
            <td>Stuck systems (Active with no pending notifications)</td>
            <td style="text-align: right;" class="#auditResults.D1_stuck_no_pending EQ 0 ? 'count-zero' : 'count-danger'#">#auditResults.D1_stuck_no_pending#</td>
            <td>#auditResults.D1_stuck_no_pending EQ 0 ? 'OK' : 'NEEDS FIX'#</td>
        </tr>
        <tr>
            <td>D2</td>
            <td>Stuck notifications (Pending with NULL notstartdate, no other active)</td>
            <td style="text-align: right;" class="#auditResults.D2_stuck_null_startdate EQ 0 ? 'count-zero' : 'count-danger'#">#auditResults.D2_stuck_null_startdate#</td>
            <td>#auditResults.D2_stuck_null_startdate EQ 0 ? 'OK' : 'NEEDS FIX'#</td>
        </tr>
        <tr>
            <td>E1</td>
            <td>Duplicate active system enrollments</td>
            <td style="text-align: right;" class="#auditResults.E1_duplicate_active_enrollments EQ 0 ? 'count-zero' : 'count-danger'#">#auditResults.E1_duplicate_active_enrollments#</td>
            <td>#auditResults.E1_duplicate_active_enrollments EQ 0 ? 'OK' : 'NEEDS FIX'#</td>
        </tr>
        <tr>
            <td>E2</td>
            <td>Duplicate maintenance systems for same contact</td>
            <td style="text-align: right;" class="#auditResults.E2_duplicate_maintenance EQ 0 ? 'count-zero' : 'count-danger'#">#auditResults.E2_duplicate_maintenance#</td>
            <td>#auditResults.E2_duplicate_maintenance EQ 0 ? 'OK' : 'NEEDS FIX'#</td>
        </tr>
        <tr>
            <td>F1</td>
            <td>Uniqueness violations (unique action completed multiple times)</td>
            <td style="text-align: right;" class="#auditResults.F1_uniqueness_violations EQ 0 ? 'count-zero' : 'count-warning'#">#auditResults.F1_uniqueness_violations#</td>
            <td>#auditResults.F1_uniqueness_violations EQ 0 ? 'OK' : 'REVIEW'#</td>
        </tr>
        <tr>
            <td>G1</td>
            <td>Overdue Future status (should be Pending/Active)</td>
            <td style="text-align: right;" class="#auditResults.G1_overdue_future_status EQ 0 ? 'count-zero' : 'count-warning'#">#auditResults.G1_overdue_future_status#</td>
            <td>#auditResults.G1_overdue_future_status EQ 0 ? 'OK' : 'REVIEW'#</td>
        </tr>
        <tr>
            <td>G2</td>
            <td>Ancient pending (> 1 year old)</td>
            <td style="text-align: right;" class="#auditResults.G2_ancient_pending EQ 0 ? 'count-zero' : 'count-warning'#">#auditResults.G2_ancient_pending#</td>
            <td>#auditResults.G2_ancient_pending EQ 0 ? 'OK' : 'REVIEW'#</td>
        </tr>
        <tr>
            <td>H1</td>
            <td>Completed systems with pending notifications</td>
            <td style="text-align: right;" class="#auditResults.H1_completed_with_pending EQ 0 ? 'count-zero' : 'count-danger'#">#auditResults.H1_completed_with_pending#</td>
            <td>#auditResults.H1_completed_with_pending EQ 0 ? 'OK' : 'NEEDS FIX'#</td>
        </tr>
        <tr>
            <td>H2</td>
            <td>Pending notifications with enddate set</td>
            <td style="text-align: right;" class="#auditResults.H2_pending_with_enddate EQ 0 ? 'count-zero' : 'count-warning'#">#auditResults.H2_pending_with_enddate#</td>
            <td>#auditResults.H2_pending_with_enddate EQ 0 ? 'OK' : 'REVIEW'#</td>
        </tr>
        </cfoutput>
    </tbody>
</table>

<h2>System Totals (Reference)</h2>
<table style="max-width: 500px;">
    <thead>
        <tr>
            <th>Metric</th>
            <th style="text-align: right;">Value</th>
        </tr>
    </thead>
    <tbody>
        <cfoutput query="totals">
        <tr>
            <td>#metric#</td>
            <td style="text-align: right;">#NumberFormat(value, ",")#</td>
        </tr>
        </cfoutput>
    </tbody>
</table>

<!--- JSON output for programmatic access --->
<h2>JSON Output (for programmatic use)</h2>
<pre><cfoutput>#SerializeJSON(auditResults)#</cfoutput></pre>

<hr>
<p><a href="run_audit.cfm?showDetails=Y">Run with Details</a> | <a href="/admin/relationship_system_health.cfm">Admin Dashboard</a></p>

</body>
</html>
