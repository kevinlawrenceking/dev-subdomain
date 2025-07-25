<!---
    PURPOSE: User Setup Verification Report - Shows record counts for all user-specific tables
    AUTHOR: Kevin King
    DATE: 2025-01-27
    DEPENDENCIES: Application.cfc with DSN configured
--->
<cfparam name = "cx" default = "" />
<cfparam name = "xrows" default = "9999" />
<cfparam name = "USERROLE" default = "U" />
<cfset session.userid = 30 />
<Cfset session.userrole = userrole />
<!--- Check if user has admin access --->
<cfif not isDefined("session.userid") >
    <cflocation url="/app/" addtoken="false">
</cfif>

<!--- Get all active users --->
<cfquery name="getAllUsers" datasource="#application.dsn#" maxrows="#xrows#">
    SELECT userid, userfirstname, userlastname, 
           CONCAT(userfirstname, ' ', userlastname) as fullname,
           userstatus, issetup, userEmail
    FROM taousers 
    WHERE userstatus = 'Active'

    <cfif #cx# is not "">
        AND userid = <cfqueryparam value="#cx#" cfsqltype="CF_SQL_INTEGER">
    </cfif>
    ORDER BY userid desc
</cfquery>

<!--- Define all user-specific tables to check with their master tables --->
<cfset userTables = [
    {name: "auddialects_user", description: "Audition Dialects", masterTable: "auddialects", masterWhere: "isdeleted = 0"},
    {name: "audgenres_user", description: "Audition Genres", masterTable: "audgenres", masterWhere: "isdeleted = 0"},
    {name: "audnetworks_user", description: "Audition Networks", masterTable: "audnetworks", masterWhere: "isdeleted = 0"},
    {name: "audopencalloptions_user", description: "Audition Open Call Options", masterTable: "audopencalloptions", masterWhere: "1=1"},
    {name: "audplatforms_user", description: "Audition Platforms", masterTable: "audplatforms", masterWhere: "isdeleted = 0"},
    {name: "audtones_user", description: "Audition Tones", masterTable: "audtones", masterWhere: "isdeleted = 0"},
    {name: "eventtypes_user", description: "Event Types", masterTable: "eventtypes", masterWhere: "1=1"},
    {name: "genderpronouns_users", description: "Gender Pronouns", masterTable: "genderpronouns", masterWhere: "1=1"},
    {name: "itemtypes_user", description: "Item Types", masterTable: "itemtypes", masterWhere: "isdeleted = 0"},
    {name: "tags_user", description: "Tags", masterTable: "tags", masterWhere: "1=1"},
    {name: "sitetypes_user", description: "Site Types", masterTable: "sitetypes_master", masterWhere: "1=1"},
    {name: "audquestions_user", description: "Audition Questions", masterTable: "audquestions_default", masterWhere: "isdeleted = 0"},
    {name: "audsubmitsites_user", description: "Audition Submit Sites", masterTable: "audsubmitsites", masterWhere: "1=1"},
    {name: "itemcatxref_user", description: "Item Category Cross-Reference", masterTable: "itemcatxref", masterWhere: "1=1"},
    {name: "pgpanels_user", description: "Dashboard Panels", masterTable: "pgpanels_master", masterWhere: "1=1"},
    {name: "sitelinks_user_tbl", description: "Site Links", masterTable: "sitelinks_master", masterWhere: "1=1"}
]>

<!--- Prepare data structure to hold results --->
<cfset userVerificationData = []>

<!--- Get master table counts for comparison --->
<cfset masterTableCounts = {}>
<cfloop array="#userTables#" index="table">
    <cftry>
        <cfquery name="getMasterCount" datasource="#application.dsn#">
            SELECT COUNT(*) as countValue
            FROM #table.masterTable# 
            <cfif len(table.masterWhere)>
                WHERE #table.masterWhere#
            </cfif>
        </cfquery>
        <cfset masterTableCounts[table.name] = getMasterCount.countValue>
    <cfcatch type="any">
        <cfset masterTableCounts[table.name] = "ERROR">
    </cfcatch>
    </cftry>
</cfloop>

<!--- Process each user --->
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
    
    <!--- Check each table for this user --->
    <cfloop array="#userTables#" index="table">
        <cftry>
            <!--- Simple query to get the actual count --->
            <cfquery name="getTableCount" datasource="#application.dsn#">
                SELECT COUNT(*) as countValue
                FROM #table.name# 
                WHERE userid = <cfqueryparam value="#getAllUsers.userid#" cfsqltype="CF_SQL_INTEGER">
            </cfquery>
            
            <!--- Get the actual count value --->
            <cfset actualCount = getTableCount.countValue>
            
            <cfset currentUser.tableCounts[table.name] = actualCount>
            <cfset currentUser.totalRecords += actualCount>
            
            <!--- Flag users with zero records in any table --->
            <cfif actualCount EQ 0>
                <cfset currentUser.hasIssues = true>
            </cfif>
            
        <cfcatch type="any">
            <!--- Handle missing tables or errors --->
            <cfset currentUser.tableCounts[table.name] = "ERROR">
            <cfset currentUser.hasIssues = true>
        </cfcatch>
        </cftry>
    </cfloop>
    
    <cfset arrayAppend(userVerificationData, currentUser)>
</cfloop>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>User Setup Verification Report | TAO</title>
    
    <!--- Bootstrap CSS --->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!--- DataTables CSS --->
    <link href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.bootstrap5.min.css" rel="stylesheet">
    
    <!--- Custom styles --->
    <style>
        .status-setup { background-color: #d4edda; }
        .status-incomplete { background-color: #f8d7da; }
        .status-warning { background-color: #fff3cd; }
        .table-count-zero { color: #dc3545; font-weight: bold; }
        .table-count-good { color: #198754; }
        .table-count-error { color: #dc3545; background-color: #f8d7da; }
        .summary-card { border-left: 4px solid #0d6efd; }
        .user-row.has-issues { background-color: #fff5f5; }
        .export-buttons { margin-bottom: 1rem; }
    </style>
</head>

<body>
    <div class="container-fluid py-4">
        <div class="row">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h1 class="h3 mb-0">User Setup Verification Report <cfoutput>(#application.dsn#)</cfoutput></h1>
                    <div>
                        <a href="../" class="btn btn-outline-secondary">
                            <i class="mdi mdi-arrow-left"></i> Back to Admin
                        </a>
                    </div>
                </div>

                <!--- Summary Statistics --->
                <cfset totalUsers = arrayLen(userVerificationData)>
                <cfset usersWithIssues = 0>
                <cfset usersComplete = 0>
                
                <cfloop array="#userVerificationData#" index="user">
                    <cfif user.hasIssues>
                        <cfset usersWithIssues++>
                    <cfelse>
                        <cfset usersComplete++>
                    </cfif>
                </cfloop>

                <cfoutput>
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="card summary-card">
                            <div class="card-body text-center">
                                <h5 class="card-title text-primary">#totalUsers#</h5>
                                <p class="card-text">Total Active Users</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card">
                            <div class="card-body text-center">
                                <h5 class="card-title text-success">#usersComplete#</h5>
                                <p class="card-text">Setup Complete</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card">
                            <div class="card-body text-center">
                                <h5 class="card-title text-danger">#usersWithIssues#</h5>
                                <p class="card-text">Setup Issues</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card">
                            <div class="card-body text-center">
                                <h5 class="card-title text-info">#arrayLen(userTables)#</h5>
                                <p class="card-text">Tables Monitored</p>
                            </div>
                        </div>
                    </div>
                </div>
                </cfoutput>

                <!--- Export buttons --->
                <div class="export-buttons">
                    <button id="exportCSV" class="btn btn-success btn-sm">
                        <i class="mdi mdi-download"></i> Export CSV
                    </button>
                    <button id="exportPrint" class="btn btn-info btn-sm">
                        <i class="mdi mdi-printer"></i> Print Report
                    </button>
                </div>

                <!--- Main verification table --->
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">User Table Record Counts</h5>
                        <small class="text-muted">Shows the number of records in each user-specific table. Zero counts may indicate setup issues.</small>
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
                                        <cfoutput>
                                        <cfloop array="#userTables#" index="table">
                                            <th title="#table.description#" class="text-center">
                                                #replace(table.name, "_user", "", "all")#
                                            </th>
                                        </cfloop>
                                        </cfoutput>
                                    </tr>
                                </thead>
                                <tbody>
                                    <!--- Master table counts row --->
                                    <cfoutput>
                                    <tr class="table-warning">
                                        <td colspan="5">
                                            <strong>MASTER TABLE TOTALS</strong>
                                            <br><small class="text-muted">Expected records per user after sync</small>
                                        </td>
                                        <cfloop array="#userTables#" index="table">
                                            <td class="text-center">
                                                <cfset masterCount = masterTableCounts[table.name]>
                                                <cfif masterCount EQ "ERROR">
                                                    <span class="table-count-error">ERROR</span>
                                                <cfelse>
                                                    <strong class="text-primary">#masterCount#</strong>
                                                </cfif>
                                            </td>
                                        </cfloop>
                                    </tr>
                                    </cfoutput>
                                    
                                    <!--- User data rows --->
                                    <cfoutput>
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
                                            <td>
                                                <span class="badge bg-info">#user.totalRecords#</span>
                                            </td>
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
                                    </cfoutput>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!--- Table descriptions --->
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h6 class="mb-0">Table Descriptions</h6>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <cfoutput>
                                    <cfloop array="#userTables#" index="table">
                                        <div class="col-md-6 col-lg-4 mb-2">
                                            <strong>#table.name#:</strong> #table.description#
                                        </div>
                                    </cfloop>
                                    </cfoutput>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!--- JavaScript --->
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
    <script src="https://cdn.datatables.net/responsive/2.5.0/js/dataTables.responsive.min.js"></script>
    <script src="https://cdn.datatables.net/responsive/2.5.0/js/responsive.bootstrap5.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.4.1/js/dataTables.buttons.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.bootstrap5.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.html5.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.print.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>

    <script>
        $(document).ready(function() {
            // Initialize DataTable
            const table = $('#verificationTable').DataTable({
                responsive: true,
                pageLength: 25,
                order: [[4, 'desc'], [0, 'asc']], // Sort by issues first, then by name
                columnDefs: [
                    { orderable: false, targets: [4] } // Issues column not orderable
                ],
                dom: 'lBfrtip',
                buttons: [
                    {
                        extend: 'csv',
                        text: 'Export CSV',
                        className: 'btn btn-success btn-sm'
                    },
                    {
                        extend: 'print',
                        text: 'Print',
                        className: 'btn btn-info btn-sm'
                    }
                ]
            });

            // Custom export button handlers
            $('#exportCSV').on('click', function() {
                table.button('.buttons-csv').trigger();
            });

            $('#exportPrint').on('click', function() {
                table.button('.buttons-print').trigger();
            });
        });
    </script>
</body>
</html>
