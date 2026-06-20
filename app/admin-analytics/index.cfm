<!---
    TAO-ADMIN-ANALYTICS-01 -- Admin Activity Analytics dashboard (read-only).
    Access: /app/admin-analytics/
    Admin-gated inline below (pg_comps governs nav only; this guard enforces access).
    Data loads via AJAX from ajax/stats.cfm. No writes anywhere on this page.
--->
<cfif NOT structKeyExists(session, "userid")>
    <cflocation url="/loginform.cfm" addtoken="false">
</cfif>
<cfquery name="qAdmin" datasource="#application.dsn#" maxrows="1">
    SELECT userRole FROM taousers
    WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer">
</cfquery>
<cfif qAdmin.recordCount EQ 0
      OR (qAdmin.userRole NEQ "Admin" AND qAdmin.userRole NEQ "Administrator")>
    <cflocation url="/app/" addtoken="false">
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Activity Analytics | TAO Admin</title>
    <link href="/app/assets/css/bootstrap.css" rel="stylesheet">
    <link href="/app/assets/css/app.min.css" rel="stylesheet">
    <link href="/app/admin-analytics/assets/analytics.css" rel="stylesheet">
</head>
<body>
<div class="container-fluid" style="padding:20px;">

    <div class="row align-items-end mb-3">
        <div class="col">
            <h1 class="h3 mb-1">Activity Analytics</h1>
            <p class="text-muted mb-0">System-wide activity across all users.</p>
        </div>
        <div class="col-auto">
            <label for="rangeSelect" class="form-label small mb-1 d-block">Date range</label>
            <select id="rangeSelect" class="form-control">
                <option value="30d">Last 30 days</option>
                <option value="90d" selected>Last 90 days</option>
                <option value="12m">Last 12 months</option>
                <option value="all">All time</option>
            </select>
        </div>
    </div>

    <div id="analyticsError" class="alert alert-danger d-none" role="alert"></div>

    <!--- Stat tiles --->
    <div class="row mb-2">
        <div class="col-md-3 col-6 mb-3">
            <div class="card aa-tile h-100"><div class="card-body text-center">
                <div class="aa-value" id="tile-auditions">--</div>
                <div class="aa-label">Auditions logged</div>
            </div></div>
        </div>
        <div class="col-md-3 col-6 mb-3">
            <div class="card aa-tile h-100"><div class="card-body text-center">
                <div class="aa-value" id="tile-relationships">--</div>
                <div class="aa-label">Relationships added</div>
            </div></div>
        </div>
        <div class="col-md-3 col-6 mb-3">
            <div class="card aa-tile h-100"><div class="card-body text-center">
                <div class="aa-value" id="tile-remindersCompleted">--</div>
                <div class="aa-label">Reminders completed</div>
            </div></div>
        </div>
        <div class="col-md-3 col-6 mb-3">
            <div class="card aa-tile h-100"><div class="card-body text-center">
                <div class="aa-value" id="tile-bookings">--</div>
                <div class="aa-label">Bookings logged</div>
            </div></div>
        </div>
    </div>

    <!--- Charts (small multiples) --->
    <div class="row">
        <div class="col-md-6 mb-3">
            <div class="card h-100"><div class="card-body">
                <h6 class="card-title">Auditions logged</h6>
                <div class="aa-chart-wrap"><canvas id="chart-auditions"></canvas></div>
            </div></div>
        </div>
        <div class="col-md-6 mb-3">
            <div class="card h-100"><div class="card-body">
                <h6 class="card-title">Relationships added</h6>
                <div class="aa-chart-wrap"><canvas id="chart-relationships"></canvas></div>
            </div></div>
        </div>
        <div class="col-md-6 mb-3">
            <div class="card h-100"><div class="card-body">
                <h6 class="card-title">Reminders completed</h6>
                <div class="aa-chart-wrap"><canvas id="chart-remindersCompleted"></canvas></div>
            </div></div>
        </div>
        <div class="col-md-6 mb-3">
            <div class="card h-100"><div class="card-body">
                <h6 class="card-title">Bookings logged</h6>
                <div class="aa-chart-wrap"><canvas id="chart-bookings"></canvas></div>
            </div></div>
        </div>
    </div>

</div>

<script src="/app/assets/js/bootstrap.bundle.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
<script src="/app/admin-analytics/assets/analytics.js"></script>
</body>
</html>
