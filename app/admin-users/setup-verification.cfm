<!---
    PURPOSE: User Setup Verification Report - record counts for every per-user table,
             with a master-totals reference row so discrepancies are obvious.
    AUTHOR:  Kevin King
    NOTE:    Self-contained page (renders its own full HTML). Admin-only via the
             canonical admin-guard (DB role lookup). All dynamic output is inside
             <cfoutput> -- the previous version left most of the body unwrapped, so
             #expressions# printed literally.
--->
<cfinclude template="admin-guard.cfm">

<!--- Get all active users --->
<cfquery name="getAllUsers" datasource="#application.dsn#">
    SELECT userid, userfirstname, userlastname,
           CONCAT(userfirstname, ' ', userlastname) AS fullname,
           userstatus, issetup, userEmail
    FROM taousers
    WHERE userstatus = 'Active'
    ORDER BY userlastname, userfirstname
</cfquery>

<!--- Per-user tables and their master source (for the totals row) --->
<cfset userTables = [
    {name: "auddialects_user",        description: "Audition Dialects",         masterTable: "auddialects",          masterWhere: "isdeleted = 0"},
    {name: "audgenres_user",          description: "Audition Genres",           masterTable: "audgenres",            masterWhere: "isdeleted = 0"},
    {name: "audnetworks_user",        description: "Audition Networks",         masterTable: "audnetworks",          masterWhere: "isdeleted = 0"},
    {name: "audopencalloptions_user", description: "Audition Open Call Options", masterTable: "audopencalloptions",   masterWhere: "1=1"},
    {name: "audplatforms_user",       description: "Audition Platforms",        masterTable: "audplatforms",         masterWhere: "isdeleted = 0"},
    {name: "audtones_user",           description: "Audition Tones",            masterTable: "audtones",             masterWhere: "isdeleted = 0"},
    {name: "eventtypes_user",         description: "Event Types",               masterTable: "eventtypes",           masterWhere: "1=1"},
    {name: "genderpronouns_users",    description: "Gender Pronouns",           masterTable: "genderpronouns",       masterWhere: "1=1"},
    {name: "itemtypes_user",          description: "Item Types",                masterTable: "itemtypes",            masterWhere: "isdeleted = 0"},
    {name: "tags_user",               description: "Tags",                      masterTable: "tags",                 masterWhere: "1=1"},
    {name: "sitetypes_user",          description: "Site Types",                masterTable: "sitetypes_master",     masterWhere: "isdeleted = 0"},
    {name: "audquestions_user",       description: "Audition Questions",        masterTable: "audquestions_default", masterWhere: "isdeleted = 0"},
    {name: "audsubmitsites_user",     description: "Audition Submit Sites",     masterTable: "audsubmitsites",       masterWhere: "1=1"},
    {name: "itemcatxref_user",        description: "Item Category Cross-Reference", masterTable: "itemcatxref",      masterWhere: "1=1"},
    {name: "pgpanels_user",           description: "Dashboard Panels",          masterTable: "pgpanels_master",      masterWhere: "1=1"},
    {name: "sitelinks_user_tbl",      description: "Site Links",                masterTable: "sitelinks_master",     masterWhere: "1=1"}
]>

<!--- Master counts (reference row) --->
<cfset masterTableCounts = {}>
<cfloop array="#userTables#" index="table">
    <cftry>
        <cfquery name="getMasterCount" datasource="#application.dsn#">
            SELECT COUNT(*) AS countValue
            FROM #table.masterTable#
            <cfif len(table.masterWhere)>WHERE #table.masterWhere#</cfif>
        </cfquery>
        <cfset masterTableCounts[table.name] = getMasterCount.countValue>
    <cfcatch type="any">
        <cfset masterTableCounts[table.name] = "ERROR">
    </cfcatch>
    </cftry>
</cfloop>

<!--- Per-user counts --->
<cfset userVerificationData = []>
<cfloop query="getAllUsers">
    <cfset currentUser = {
        userid: getAllUsers.userid,
        fullname: getAllUsers.fullname,
        email: getAllUsers.userEmail,
        issetup: getAllUsers.issetup,
        tableCounts: {},
        totalRecords: 0,
        hasIssues: false
    }>
    <cfloop array="#userTables#" index="table">
        <cftry>
            <cfquery name="getTableCount" datasource="#application.dsn#">
                SELECT COUNT(*) AS countValue
                FROM #table.name#
                WHERE userid = <cfqueryparam value="#getAllUsers.userid#" cfsqltype="CF_SQL_INTEGER">
            </cfquery>
            <cfset currentUser.tableCounts[table.name] = getTableCount.countValue>
            <cfset currentUser.totalRecords += getTableCount.countValue>
            <cfif getTableCount.countValue EQ 0>
                <cfset currentUser.hasIssues = true>
            </cfif>
        <cfcatch type="any">
            <cfset currentUser.tableCounts[table.name] = "ERROR">
            <cfset currentUser.hasIssues = true>
        </cfcatch>
        </cftry>
    </cfloop>
    <cfset arrayAppend(userVerificationData, currentUser)>
</cfloop>

<!--- Summary stats --->
<cfset totalUsers = arrayLen(userVerificationData)>
<cfset usersWithIssues = 0>
<cfset usersComplete = 0>
<cfloop array="#userVerificationData#" index="user">
    <cfif user.hasIssues><cfset usersWithIssues++><cfelse><cfset usersComplete++></cfif>
</cfloop>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>User Setup Verification Report | TAO</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.bootstrap5.min.css" rel="stylesheet">
    <style>
        .table-count-zero  { color: #dc3545; font-weight: bold; }
        .table-count-good  { color: #198754; }
        .table-count-error { color: #dc3545; background-color: #f8d7da; }
        .summary-card      { border-left: 4px solid #0d6efd; }
        .user-row.has-issues { background-color: #fff5f5; }
        .export-buttons    { margin-bottom: 1rem; }
    </style>
</head>
<body>
<cfoutput>
<div class="container-fluid py-4">
    <div class="row">
        <div class="col-12">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h1 class="h3 mb-0">User Setup Verification Report <small class="text-muted">(#application.dsn#)</small></h1>
                <div>
                    <a href="../" class="btn btn-outline-secondary"><i class="mdi mdi-arrow-left"></i> Back to Admin</a>
                </div>
            </div>

            <!--- Summary --->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="card summary-card"><div class="card-body text-center">
                        <h5 class="card-title text-primary">#totalUsers#</h5>
                        <p class="card-text">Total Active Users</p>
                    </div></div>
                </div>
                <div class="col-md-3">
                    <div class="card"><div class="card-body text-center">
                        <h5 class="card-title text-success">#usersComplete#</h5>
                        <p class="card-text">Setup Complete</p>
                    </div></div>
                </div>
                <div class="col-md-3">
                    <div class="card"><div class="card-body text-center">
                        <h5 class="card-title text-danger">#usersWithIssues#</h5>
                        <p class="card-text">Setup Issues</p>
                    </div></div>
                </div>
                <div class="col-md-3">
                    <div class="card"><div class="card-body text-center">
                        <h5 class="card-title text-info">#arrayLen(userTables)#</h5>
                        <p class="card-text">Tables Monitored</p>
                    </div></div>
                </div>
            </div>

            <div class="export-buttons">
                <button id="exportCSV" class="btn btn-success btn-sm"><i class="mdi mdi-download"></i> Export CSV</button>
                <button id="exportPrint" class="btn btn-info btn-sm"><i class="mdi mdi-printer"></i> Print Report</button>
            </div>

            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">User Table Record Counts</h5>
                    <small class="text-muted">Zero counts may indicate setup issues. The grey badge under each column is the master-expected count per user.</small>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table id="verificationTable" class="table table-striped table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th>User</th>
                                    <th>Email</th>
                                    <th>Setup Status</th>
                                    <th>Total Records</th>
                                    <th>Issues</th>
                                    <cfloop array="#userTables#" index="table">
                                        <th title="#table.description#" class="text-center">
                                            #replace(table.name, "_user", "", "all")#
                                            <br><span class="badge bg-secondary" title="Master expected per user"><cfif masterTableCounts[table.name] EQ "ERROR">ERR<cfelse>#masterTableCounts[table.name]#</cfif></span>
                                        </th>
                                    </cfloop>
                                </tr>
                            </thead>
                            <tbody>
                                <cfloop array="#userVerificationData#" index="user">
                                    <tr class="user-row<cfif user.hasIssues> has-issues</cfif>">
                                        <td>
                                            <strong>#user.fullname#</strong>
                                            <br><small class="text-muted">ID: #user.userid#</small>
                                        </td>
                                        <td><small>#user.email#</small></td>
                                        <td>
                                            <cfif user.issetup>
                                                <span class="badge bg-success">Setup Complete</span>
                                            <cfelse>
                                                <span class="badge bg-warning">Incomplete</span>
                                            </cfif>
                                        </td>
                                        <td><span class="badge bg-info">#user.totalRecords#</span></td>
                                        <td>
                                            <cfif user.hasIssues>
                                                <span class="badge bg-danger">Yes</span>
                                            <cfelse>
                                                <span class="badge bg-success">No</span>
                                            </cfif>
                                        </td>
                                        <cfloop array="#userTables#" index="table">
                                            <td class="text-center">
                                                <cfset count = user.tableCounts[table.name]>
                                                <cfif count EQ "ERROR">
                                                    <span class="table-count-error">ERROR</span>
                                                <cfelseif count EQ 0>
                                                    <span class="table-count-zero">0</span>
                                                <cfelse>
                                                    <span class="table-count-good">#count#</span>
                                                </cfif>
                                            </td>
                                        </cfloop>
                                    </tr>
                                </cfloop>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!--- Table descriptions --->
            <div class="row mt-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header"><h6 class="mb-0">Table Descriptions</h6></div>
                        <div class="card-body">
                            <div class="row">
                                <cfloop array="#userTables#" index="table">
                                    <div class="col-md-6 col-lg-4 mb-2"><strong>#table.name#:</strong> #table.description#</div>
                                </cfloop>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</cfoutput>

<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/dataTables.buttons.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.bootstrap5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.html5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.print.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
<script>
    $(document).ready(function() {
        var table = $('#verificationTable').DataTable({
            pageLength: 25,
            order: [[4, 'desc'], [0, 'asc']],
            columnDefs: [ { orderable: false, targets: [4] } ],
            dom: 'lBfrtip',
            buttons: [
                { extend: 'csv',   text: 'Export CSV', className: 'btn btn-success btn-sm' },
                { extend: 'print', text: 'Print',      className: 'btn btn-info btn-sm' }
            ]
        });
        $('#exportCSV').on('click', function() { table.button('.buttons-csv').trigger(); });
        $('#exportPrint').on('click', function() { table.button('.buttons-print').trigger(); });
    });
</script>
</body>
</html>
