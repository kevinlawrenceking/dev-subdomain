<!---
TAO Relationship System Health Dashboard
Admin-only page for monitoring and maintaining the relationship system

Access: /app/admin-relationship/
Security: Requires admin session (add appropriate check)
--->

<!--- Security check - uncomment and adjust based on TAO auth pattern --->
<!---
<cfif NOT isDefined("session.isAdmin") OR session.isAdmin NEQ true>
    <cflocation url="/app/dashboard_new/" addtoken="false" />
</cfif>
--->


<cfparam name="action" default="dashboard" />

<!--- Load RelationshipService for health metrics --->
<cfset relationshipService = createObject("component", "services.RelationshipService") />

<!--- Get health metrics --->
<cfset health = relationshipService.getSystemHealth() />

<!--- Get detailed audit counts --->
<cfset auditResults = {} />

<cfquery name="A1_orphan_suid" datasource="#dsn#">
    SELECT COUNT(*) AS cnt FROM funotifications n
    LEFT JOIN fusystemusers su ON su.suid = n.suid
    WHERE su.suid IS NULL AND n.isdeleted = 0
</cfquery>
<cfset auditResults.A1 = A1_orphan_suid.cnt />

<cfquery name="C1_multi_pending" datasource="#dsn#">
    SELECT COUNT(*) AS cnt FROM (
        SELECT suid FROM funotifications
        WHERE notstatus = 'Pending' AND notstartdate IS NOT NULL AND isdeleted = 0
        GROUP BY suid HAVING COUNT(*) > 1
    ) t
</cfquery>
<cfset auditResults.C1 = C1_multi_pending.cnt />

<cfquery name="D1_stuck" datasource="#dsn#">
    SELECT COUNT(*) AS cnt FROM fusystemusers su
    LEFT JOIN funotifications n ON n.suid = su.suid AND n.notstatus = 'Pending' AND n.isdeleted = 0
    WHERE su.sustatus = 'Active' AND su.isdeleted = 0 AND n.notid IS NULL
</cfquery>
<cfset auditResults.D1 = D1_stuck.cnt />

<cfquery name="E1_duplicates" datasource="#dsn#">
    SELECT COUNT(*) AS cnt FROM (
        SELECT userid, contactid, systemid FROM fusystemusers
        WHERE sustatus = 'Active' AND isdeleted = 0
        GROUP BY userid, contactid, systemid HAVING COUNT(*) > 1
    ) t
</cfquery>
<cfset auditResults.E1 = E1_duplicates.cnt />

<!--- Calculate overall health score --->
<cfset totalIssues = auditResults.A1 + auditResults.C1 + auditResults.D1 + auditResults.E1 />
<cfif totalIssues EQ 0>
    <cfset healthStatus = "healthy" />
    <cfset healthColor = "##28a745" />
    <cfset healthIcon = "check-circle" />
<cfelseif totalIssues LT 10>
    <cfset healthStatus = "warning" />
    <cfset healthColor = "##ffc107" />
    <cfset healthIcon = "alert-triangle" />
<cfelse>
    <cfset healthStatus = "critical" />
    <cfset healthColor = "##dc3545" />
    <cfset healthIcon = "alert-circle" />
</cfif>

<!--- Get top offenders (stuck systems) --->
<cfquery name="topOffenders" datasource="#dsn#" maxrows="10">
    SELECT
        su.suid,
        su.contactid,
        cd.recordname AS contact_name,
        s.systemname,
        su.sustartdate,
        DATEDIFF(CURDATE(), su.sustartdate) AS days_in_system
    FROM fusystemusers su
    INNER JOIN fusystems s ON s.systemid = su.systemid
    LEFT JOIN contactdetails cd ON cd.contactid = su.contactid AND cd.userid = su.userid
    LEFT JOIN funotifications n ON n.suid = su.suid AND n.notstatus = 'Pending' AND n.isdeleted = 0
    WHERE su.sustatus = 'Active'
      AND su.isdeleted = 0
      AND n.notid IS NULL
    ORDER BY su.sustartdate
    LIMIT 10
</cfquery>

<!--- Get reminders due today --->
<cfquery name="dueToday" datasource="#dsn#">
    SELECT COUNT(*) AS cnt
    FROM funotifications
    WHERE notstatus = 'Pending'
      AND notstartdate = CURDATE()
      AND isdeleted = 0
</cfquery>

<!--- Get overdue reminders --->
<cfquery name="overdue" datasource="#dsn#">
    SELECT COUNT(*) AS cnt
    FROM funotifications
    WHERE notstatus = 'Pending'
      AND notstartdate < CURDATE()
      AND isdeleted = 0
</cfquery>

<!DOCTYPE html>
<html>
<head>
    <title>Relationship System Health | TAO Admin</title>
    <link href="/app/assets/css/bootstrap.css" rel="stylesheet" />
    <link href="/app/assets/css/app.min.css" rel="stylesheet" />
    <style>
        .health-card {
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .health-healthy { background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%); }
        .health-warning { background: linear-gradient(135deg, #fff3cd 0%, #ffeeba 100%); }
        .health-critical { background: linear-gradient(135deg, #f8d7da 0%, #f5c6cb 100%); }
        .metric-card {
            background: white;
            border-radius: 8px;
            padding: 15px;
            text-align: center;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .metric-value {
            font-size: 2rem;
            font-weight: bold;
            margin: 5px 0;
        }
        .metric-label {
            color: #666;
            font-size: 0.9rem;
        }
        .issue-count { color: #dc3545; font-weight: bold; }
        .ok-count { color: #28a745; font-weight: bold; }
        .action-btn {
            margin: 5px;
        }
        .offender-table {
            font-size: 0.85rem;
        }
        .offender-table th {
            background: #f5f5f5;
        }
    </style>
</head>
<body>
    <div class="container-fluid" style="padding: 20px;">

        <!--- Header --->
        <div class="row mb-4">
            <div class="col-12">
                <h1>
                    <i class="fe-activity"></i>
                    Relationship System Health Dashboard
                </h1>
                <p class="text-muted">
                    Monitor and maintain the TAO relationship system |
                    Last updated: <cfoutput>#DateTimeFormat(Now(), "yyyy-mm-dd HH:nn:ss")#</cfoutput>
                </p>
            </div>
        </div>

        <!--- Health Status Banner --->
        <div class="row mb-4">
            <div class="col-12">
                <div class="health-card health-<cfoutput>#healthStatus#</cfoutput>">
                    <div class="row align-items-center">
                        <div class="col-auto">
                            <i class="fe-<cfoutput>#healthIcon#</cfoutput>" style="font-size: 3rem; color: <cfoutput>#healthColor#</cfoutput>;"></i>
                        </div>
                        <div class="col">
                            <h3 style="margin: 0; color: <cfoutput>#healthColor#</cfoutput>;">
                                System Status:
                                <cfoutput>#UCase(healthStatus)#</cfoutput>
                            </h3>
                            <p style="margin: 5px 0 0 0;">
                                <cfoutput>#totalIssues#</cfoutput> issue(s) detected
                                <cfif totalIssues GT 0>
                                    - <a href="/scripts/relationship_system/repair_relationship_system.cfm?dryRun=Y&applyAll=Y">Run Repair (Dry Run)</a>
                                </cfif>
                            </p>
                        </div>
                        <div class="col-auto">
                            <a href="?action=refresh" class="btn btn-light">
                                <i class="fe-refresh-cw"></i> Refresh
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!--- Key Metrics Row --->
        <div class="row mb-4">
            <div class="col-md-2">
                <div class="metric-card">
                    <div class="metric-value" style="color: #007bff;">
                        <cfoutput>#NumberFormat(health.activeSystems, ",")#</cfoutput>
                    </div>
                    <div class="metric-label">Active Systems</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="metric-card">
                    <div class="metric-value" style="color: #6f42c1;">
                        <cfoutput>#NumberFormat(health.pendingNotifications, ",")#</cfoutput>
                    </div>
                    <div class="metric-label">Pending Reminders</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="metric-card">
                    <div class="metric-value" style="color: #17a2b8;">
                        <cfoutput>#NumberFormat(dueToday.cnt, ",")#</cfoutput>
                    </div>
                    <div class="metric-label">Due Today</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="metric-card">
                    <div class="metric-value" style="color: #ffc107;">
                        <cfoutput>#NumberFormat(overdue.cnt, ",")#</cfoutput>
                    </div>
                    <div class="metric-label">Overdue</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="metric-card">
                    <div class="metric-value" style="color: #dc3545;">
                        <cfoutput>#NumberFormat(health.stuckSystems, ",")#</cfoutput>
                    </div>
                    <div class="metric-label">Stuck Systems</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="metric-card">
                    <div class="metric-value" style="color: #fd7e14;">
                        <cfoutput>#NumberFormat(health.duplicateEnrollments, ",")#</cfoutput>
                    </div>
                    <div class="metric-label">Duplicates</div>
                </div>
            </div>
        </div>

        <!--- Issue Details --->
        <div class="row mb-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0">Issue Breakdown</h5>
                    </div>
                    <div class="card-body">
                        <table class="table table-sm">
                            <thead>
                                <tr>
                                    <th>Code</th>
                                    <th>Description</th>
                                    <th class="text-right">Count</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfoutput>
                                <tr>
                                    <td>A1</td>
                                    <td>Orphaned notifications</td>
                                    <td class="text-right #auditResults.A1 EQ 0 ? 'ok-count' : 'issue-count'#">#auditResults.A1#</td>
                                </tr>
                                <tr>
                                    <td>C1</td>
                                    <td>Multiple active pending per system</td>
                                    <td class="text-right #auditResults.C1 EQ 0 ? 'ok-count' : 'issue-count'#">#auditResults.C1#</td>
                                </tr>
                                <tr>
                                    <td>D1</td>
                                    <td>Stuck systems (no pending)</td>
                                    <td class="text-right #auditResults.D1 EQ 0 ? 'ok-count' : 'issue-count'#">#auditResults.D1#</td>
                                </tr>
                                <tr>
                                    <td>E1</td>
                                    <td>Duplicate enrollments</td>
                                    <td class="text-right #auditResults.E1 EQ 0 ? 'ok-count' : 'issue-count'#">#auditResults.E1#</td>
                                </tr>
                                </cfoutput>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <th colspan="2">Total Issues</th>
                                    <th class="text-right <cfoutput>#totalIssues EQ 0 ? 'ok-count' : 'issue-count'#</cfoutput>">
                                        <cfoutput>#totalIssues#</cfoutput>
                                    </th>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0">Quick Actions</h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <a href="/scripts/relationship_system/run_audit.cfm" class="btn btn-info action-btn" target="_blank">
                                <i class="fe-search"></i> Run Full Audit
                            </a>
                            <a href="/scripts/relationship_system/repair_relationship_system.cfm?dryRun=Y&applyAll=Y" class="btn btn-warning action-btn" target="_blank">
                                <i class="fe-tool"></i> Preview All Repairs
                            </a>
                        </div>
                        <div class="mb-3">
                            <a href="/scripts/relationship_system/repair_relationship_system.cfm?dryRun=Y&fixD=Y" class="btn btn-outline-primary action-btn" target="_blank">
                                Fix Stuck Systems (Dry)
                            </a>
                            <a href="/scripts/relationship_system/repair_relationship_system.cfm?dryRun=Y&fixC=Y" class="btn btn-outline-primary action-btn" target="_blank">
                                Fix Multi-Pending (Dry)
                            </a>
                        </div>
                        <div>
                            <a href="/docs/relationship_system/RELATIONSHIP_SYSTEM_HEALTH_REPORT.md" class="btn btn-outline-secondary action-btn" target="_blank">
                                <i class="fe-file-text"></i> View Health Report
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!--- Top Offenders --->
        <cfif topOffenders.recordCount GT 0>
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0">Top Offenders - Stuck Systems</h5>
                    </div>
                    <div class="card-body">
                        <table class="table table-sm offender-table">
                            <thead>
                                <tr>
                                    <th>SUID</th>
                                    <th>Contact</th>
                                    <th>System</th>
                                    <th>Start Date</th>
                                    <th>Days in System</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfoutput query="topOffenders">
                                <tr>
                                    <td>#suid#</td>
                                    <td>
                                        <a href="/app/contact/?contactid=#contactid#&t4=1">#contact_name#</a>
                                    </td>
                                    <td>#systemname#</td>
                                    <td>#DateFormat(sustartdate, "yyyy-mm-dd")#</td>
                                    <td>#days_in_system# days</td>
                                    <td>
                                        <a href="/app/contact/?contactid=#contactid#&t4=1" class="btn btn-sm btn-outline-primary">
                                            View
                                        </a>
                                    </td>
                                </tr>
                                </cfoutput>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        </cfif>

        <!--- Documentation Links --->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0">Documentation & Resources</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-4">
                                <h6>Audit Queries</h6>
                                <p class="small text-muted">
                                    Full SQL audit queries are available at:<br>
                                    <code>/scripts/relationship_system/audit_relationship_system.sql</code>
                                </p>
                            </div>
                            <div class="col-md-4">
                                <h6>Repair Script</h6>
                                <p class="small text-muted">
                                    Idempotent repair runner with dry-run mode:<br>
                                    <code>/scripts/relationship_system/repair_relationship_system.cfm</code>
                                </p>
                            </div>
                            <div class="col-md-4">
                                <h6>Index Script</h6>
                                <p class="small text-muted">
                                    Performance indexes for relationship tables:<br>
                                    <code>/scripts/relationship_system/add_indexes.sql</code>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!--- JSON Data for API access --->
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0">API Data (JSON)</h5>
                    </div>
                    <div class="card-body">
                        <pre style="max-height: 200px; overflow: auto;"><cfoutput>#SerializeJSON({
    "timestamp": DateTimeFormat(Now(), "yyyy-mm-dd HH:nn:ss"),
    "status": healthStatus,
    "metrics": health,
    "issues": auditResults,
    "totalIssues": totalIssues
})#</cfoutput></pre>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <script src="/app/assets/js/bootstrap.bundle.js"></script>
</body>
</html>
