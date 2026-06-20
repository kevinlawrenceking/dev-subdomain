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

<!--- Banner: brand blue, logo only (no menu) --->
<div class="aa-banner">
    <div class="aa-banner-inner">
        <img src="/app/assets/images/logo-light.png" class="aa-logo" alt="The Actor's Office">
        <a href="/app/" class="btn btn-light btn-sm aa-back">Return to Dashboard</a>
    </div>
</div>

<div class="container-fluid aa-content">

    <div class="row align-items-end mb-3">
        <div class="col">
            <h1 class="h3 mb-1">Activity Analytics</h1>
            <p class="text-muted mb-0">System-wide activity across all users.</p>
        </div>
        <div class="col-auto">
            <button type="button" class="btn btn-outline-secondary me-2" data-bs-toggle="modal" data-bs-target="#aboutModal">
                How these numbers work
            </button>
            <button type="button" id="exportCsv" class="btn btn-outline-secondary me-2">
                Export CSV
            </button>
            <label for="rangeSelect" class="form-label small mb-1 d-block">Date range</label>
            <select id="rangeSelect" class="form-select d-inline-block" style="width:auto;">
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
        <div class="col-md-3 col-6 mb-3"><div class="card aa-tile h-100"><div class="card-body text-center">
            <div class="aa-value" id="tile-auditions">--</div>
            <div class="aa-label">Auditions logged</div>
        </div></div></div>
        <div class="col-md-3 col-6 mb-3"><div class="card aa-tile h-100"><div class="card-body text-center">
            <div class="aa-value" id="tile-relationships">--</div>
            <div class="aa-label">Relationships added</div>
        </div></div></div>
        <div class="col-md-3 col-6 mb-3"><div class="card aa-tile h-100"><div class="card-body text-center">
            <div class="aa-value" id="tile-remindersCompleted">--</div>
            <div class="aa-label">Reminders completed</div>
        </div></div></div>
        <div class="col-md-3 col-6 mb-3"><div class="card aa-tile h-100"><div class="card-body text-center">
            <div class="aa-value" id="tile-bookings">--</div>
            <div class="aa-label">Bookings logged</div>
        </div></div></div>
    </div>

    <!--- Charts (small multiples) --->
    <div class="row">
        <div class="col-md-6 mb-3"><div class="card h-100"><div class="card-body">
            <h6 class="card-title">Auditions logged</h6>
            <div class="aa-chart-wrap"><canvas id="chart-auditions"></canvas></div>
        </div></div></div>
        <div class="col-md-6 mb-3"><div class="card h-100"><div class="card-body">
            <h6 class="card-title">Relationships added</h6>
            <div class="aa-chart-wrap"><canvas id="chart-relationships"></canvas></div>
        </div></div></div>
        <div class="col-md-6 mb-3"><div class="card h-100"><div class="card-body">
            <h6 class="card-title">Reminders completed</h6>
            <div class="aa-chart-wrap"><canvas id="chart-remindersCompleted"></canvas></div>
        </div></div></div>
        <div class="col-md-6 mb-3"><div class="card h-100"><div class="card-body">
            <h6 class="card-title">Bookings logged</h6>
            <div class="aa-chart-wrap"><canvas id="chart-bookings"></canvas></div>
        </div></div></div>
    </div>

</div>

<!--- About modal: plain-language explanation of how each number is counted --->
<div class="modal fade" id="aboutModal" tabindex="-1" aria-labelledby="aboutModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="aboutModalLabel">How these numbers are counted</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <p><strong>Auditions logged.</strong> We link the audition project and audition role records (one-to-one) and count those. We deliberately do not count from the auditions (events) table, because one role can produce several event entries -- the first audition, a callback, a redirect, and so on -- so counting events would multiply one real opportunity into many. Counting at the role level gives one clean count per audition.</p>
        <p><strong>Bookings logged.</strong> The same set of audition records, narrowed to the ones that actually booked. That includes a role that auditioned and booked, and a "direct booking" where the actor was booked without auditioning. Bookings is always a subset of auditions.</p>
        <p><strong>Relationships added.</strong> New people added to the system -- the contacts that make up an actor's network -- based on each contact's creation date. We exclude the actor's own profile record so it doesn't pad the count. This measures network growth, not enrollment into any follow-up workflow.</p>
        <p><strong>Reminders completed.</strong> Reminders that were actually marked done, using the date they were completed (not the date they were due). This reflects real activity finished, not just what was scheduled.</p>
        <p class="mb-0"><strong>Time window and charts.</strong> Every number reflects the range selected at the top (last 30 days, 90 days, 12 months, or all time). The four charts show those same totals broken out month by month. All figures are system-wide across every user.</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>

<script src="/app/assets/js/bootstrap.bundle.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
<script src="/app/admin-analytics/assets/analytics.js"></script>
</body>
</html>
