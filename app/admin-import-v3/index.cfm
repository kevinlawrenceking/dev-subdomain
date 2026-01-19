<!---
    Contact Import V3 Admin Dashboard
    Displays job health, feature flag status, and allowlist management.
    ADMIN ONLY
--->

<!--- Check if user has admin access --->
<cfif NOT isDefined("session.userid") OR (session.userrole NEQ "Admin" AND session.userrole NEQ "Administrator")>
    <cflocation url="/app/" addtoken="false">
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Import V3 Admin Dashboard | TAO</title>

    <!--- Bootstrap CSS --->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!--- DataTables CSS --->
    <link href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css" rel="stylesheet">

    <style>
        .stat-card {
            border-radius: 8px;
            padding: 1rem;
            text-align: center;
        }
        .stat-value {
            font-size: 2rem;
            font-weight: bold;
        }
        .stat-label {
            font-size: 0.875rem;
            color: #6c757d;
        }
        .status-badge {
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
        }
        .status-completed { background: #d4edda; color: #155724; }
        .status-failed { background: #f8d7da; color: #721c24; }
        .status-pending, .status-created { background: #fff3cd; color: #856404; }
        .status-parsing, .status-mapping, .status-reviewing, .status-finalizing {
            background: #cce5ff; color: #004085;
        }
        .flag-enabled { color: #28a745; }
        .flag-disabled { color: #dc3545; }
        .error-preview {
            max-width: 300px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            cursor: pointer;
        }
        .allowlist-table th, .allowlist-table td {
            vertical-align: middle;
        }
    </style>
</head>
<body class="bg-light">
    <div class="container-fluid py-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0">Contact Import V3</h1>
                <p class="text-muted mb-0">Admin Dashboard</p>
            </div>
            <div>
                <button id="btnRefresh" class="btn btn-outline-secondary btn-sm me-2">
                    Refresh Data
                </button>
                <a href="/app/" class="btn btn-outline-primary btn-sm">Back to App</a>
            </div>
        </div>

        <!--- Feature Flag Status --->
        <div class="card mb-4">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">Feature Flag Status</h5>
                <button id="btnRefreshFlags" class="btn btn-sm btn-outline-secondary">
                    Force Refresh Cache
                </button>
            </div>
            <div class="card-body">
                <div class="row align-items-center">
                    <div class="col-md-4">
                        <div class="d-flex align-items-center">
                            <span class="me-2">Global Status:</span>
                            <span id="globalFlagStatus" class="fw-bold">Loading...</span>
                        </div>
                        <small class="text-muted">
                            Cache age: <span id="cacheAge">-</span>s / TTL: <span id="cacheTTL">-</span>s
                        </small>
                    </div>
                    <div class="col-md-4">
                        <div class="d-flex align-items-center">
                            <span class="me-2">Allowlist Users:</span>
                            <span id="allowlistCount" class="fw-bold">-</span>
                        </div>
                    </div>
                    <div class="col-md-4 text-end">
                        <div class="btn-group" role="group">
                            <button id="btnEnableGlobal" class="btn btn-success btn-sm">
                                Enable Global
                            </button>
                            <button id="btnDisableGlobal" class="btn btn-danger btn-sm">
                                Disable Global
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!--- Stats Cards --->
        <div class="row mb-4">
            <div class="col-md-2">
                <div class="card stat-card">
                    <div class="stat-value text-success" id="statCompletedToday">-</div>
                    <div class="stat-label">Completed Today</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card stat-card">
                    <div class="stat-value text-danger" id="statFailedToday">-</div>
                    <div class="stat-label">Failed Today</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card stat-card">
                    <div class="stat-value text-primary" id="statActiveJobs">-</div>
                    <div class="stat-label">Active Jobs</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card stat-card">
                    <div class="stat-value" id="statAvgRows">-</div>
                    <div class="stat-label">Avg Rows/Job (7d)</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card stat-card">
                    <div class="stat-value" id="statJobs7d">-</div>
                    <div class="stat-label">Jobs (7d)</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card stat-card">
                    <div class="stat-value" id="statUsers7d">-</div>
                    <div class="stat-label">Users (7d)</div>
                </div>
            </div>
        </div>

        <div class="row">
            <!--- Recent Jobs --->
            <div class="col-lg-8">
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0">Recent Jobs (Last 50)</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table id="jobsTable" class="table table-sm table-striped">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>User</th>
                                        <th>File</th>
                                        <th>Status</th>
                                        <th>Rows</th>
                                        <th>Imported</th>
                                        <th>Created</th>
                                        <th>Error</th>
                                    </tr>
                                </thead>
                                <tbody id="jobsTableBody">
                                    <tr><td colspan="8" class="text-center">Loading...</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!--- Allowlist Management --->
            <div class="col-lg-4">
                <div class="card mb-4">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">Allowlist</h5>
                        <button id="btnAddUser" class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#addUserModal">
                            Add User
                        </button>
                    </div>
                    <div class="card-body">
                        <p class="small text-muted mb-3">
                            When global flag is OFF, only these users can access Import V3.
                        </p>
                        <table class="table table-sm allowlist-table">
                            <thead>
                                <tr>
                                    <th>User</th>
                                    <th>Added</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody id="allowlistTableBody">
                                <tr><td colspan="3" class="text-center">Loading...</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!--- Add User Modal --->
    <div class="modal fade" id="addUserModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Add User to Allowlist</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Search Users</label>
                        <input type="text" id="userSearch" class="form-control" placeholder="Type name or email...">
                    </div>
                    <div id="userSearchResults" class="list-group" style="max-height: 200px; overflow-y: auto;">
                    </div>
                    <div class="mt-3">
                        <label class="form-label">Notes (optional)</label>
                        <input type="text" id="addUserNotes" class="form-control" placeholder="Why adding this user?">
                    </div>
                    <input type="hidden" id="selectedUserId" value="">
                    <div id="selectedUserDisplay" class="alert alert-info mt-3 d-none">
                        Selected: <strong id="selectedUserName"></strong>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" id="btnConfirmAddUser" class="btn btn-primary" disabled>Add to Allowlist</button>
                </div>
            </div>
        </div>
    </div>

    <!--- Error Detail Modal --->
    <div class="modal fade" id="errorModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Error Details - Job <span id="errorJobId"></span></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <pre id="errorDetail" class="bg-light p-3" style="white-space: pre-wrap;"></pre>
                </div>
            </div>
        </div>
    </div>

    <!--- Scripts --->
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>

    <script>
    (function() {
        const API_BASE = '/ajax/importv3/admin_dashboard.cfm';
        let dataTable = null;
        let csrfToken = ''; // Will be populated from server response

        // Load dashboard data
        function loadDashboard() {
            $.get(API_BASE)
                .done(function(resp) {
                    if (resp.success) {
                        // Store CSRF token for subsequent POST requests
                        if (resp.data.csrf_token) {
                            csrfToken = resp.data.csrf_token;
                        }
                        updateFlagStatus(resp.data.flagStatus);
                        updateStats(resp.data.stats);
                        updateJobsTable(resp.data.recentJobs);
                        updateAllowlist(resp.data.allowedUsers);
                    } else {
                        alert('Error loading dashboard: ' + resp.message);
                    }
                })
                .fail(function() {
                    alert('Failed to load dashboard data.');
                });
        }

        function updateFlagStatus(flagStatus) {
            const statusEl = $('#globalFlagStatus');
            if (flagStatus.importV3Enabled) {
                statusEl.text('ENABLED').removeClass('flag-disabled').addClass('flag-enabled');
            } else {
                statusEl.text('DISABLED').removeClass('flag-enabled').addClass('flag-disabled');
            }
            $('#cacheAge').text(flagStatus.cacheAge || 0);
            $('#cacheTTL').text(flagStatus.cacheTTL || 60);
            $('#allowlistCount').text(flagStatus.allowedUserCount || 0);
        }

        function updateStats(stats) {
            $('#statCompletedToday').text(stats.completed_today || 0);
            $('#statFailedToday').text(stats.failed_today || 0);
            $('#statActiveJobs').text(stats.active_jobs || 0);
            $('#statAvgRows').text(stats.avg_rows_per_job || 0);
            $('#statJobs7d').text(stats.jobs_last_7_days || 0);
            $('#statUsers7d').text(stats.unique_users_7_days || 0);
        }

        function updateJobsTable(jobs) {
            const tbody = $('#jobsTableBody');
            tbody.empty();

            if (!jobs || jobs.length === 0) {
                tbody.append('<tr><td colspan="8" class="text-center text-muted">No jobs found</td></tr>');
                return;
            }

            jobs.forEach(function(job) {
                const statusClass = 'status-' + job.status;
                const createdAt = job.created_at ? new Date(job.created_at).toLocaleString() : '-';
                const errorPreview = job.error_message ?
                    '<span class="error-preview" data-job-id="' + job.job_id + '" data-error="' +
                    escapeHtml(job.error_message) + '">' + escapeHtml(job.error_message.substring(0, 50)) + '</span>' : '-';

                tbody.append(
                    '<tr>' +
                    '<td>' + job.job_id + '</td>' +
                    '<td><span title="' + escapeHtml(job.user_email || '') + '">' + escapeHtml(job.user_name || 'User ' + job.userid) + '</span></td>' +
                    '<td title="' + escapeHtml(job.source_filename) + '">' + escapeHtml(truncate(job.source_filename, 20)) + '</td>' +
                    '<td><span class="status-badge ' + statusClass + '">' + job.status + '</span></td>' +
                    '<td>' + (job.total_rows || 0) + '</td>' +
                    '<td>' + (job.imported_rows || 0) + '/' + (job.updated_rows || 0) + '</td>' +
                    '<td>' + createdAt + '</td>' +
                    '<td>' + errorPreview + '</td>' +
                    '</tr>'
                );
            });

            // Click handler for error preview
            $('.error-preview').on('click', function() {
                const jobId = $(this).data('job-id');
                const error = $(this).data('error');
                $('#errorJobId').text(jobId);
                $('#errorDetail').text(error);
                new bootstrap.Modal('#errorModal').show();
            });
        }

        function updateAllowlist(users) {
            const tbody = $('#allowlistTableBody');
            tbody.empty();

            if (!users || users.length === 0) {
                tbody.append('<tr><td colspan="3" class="text-center text-muted">No users in allowlist</td></tr>');
                return;
            }

            users.forEach(function(user) {
                const addedAt = user.created_at ? new Date(user.created_at).toLocaleDateString() : '-';
                tbody.append(
                    '<tr>' +
                    '<td>' +
                    '<div>' + escapeHtml(user.user_name || 'User ' + user.userid) + '</div>' +
                    '<small class="text-muted">' + escapeHtml(user.user_email || '') + '</small>' +
                    '</td>' +
                    '<td>' + addedAt + '</td>' +
                    '<td>' +
                    '<button class="btn btn-sm btn-outline-danger btn-remove-user" data-userid="' + user.userid + '">&times;</button>' +
                    '</td>' +
                    '</tr>'
                );
            });

            // Click handler for remove buttons
            $('.btn-remove-user').on('click', function() {
                const userid = $(this).data('userid');
                if (confirm('Remove this user from allowlist?')) {
                    removeUser(userid);
                }
            });
        }

        // Toggle global flag
        function toggleGlobalFlag(enabled) {
            $.post(API_BASE, { action: 'toggle_global', enabled: enabled ? '1' : '0', csrf_token: csrfToken })
                .done(function(resp) {
                    if (resp.success) {
                        updateFlagStatus(resp.data.flagStatus);
                    } else {
                        alert('Error: ' + resp.message);
                    }
                });
        }

        // Refresh feature flags cache
        function refreshFlags() {
            $.post(API_BASE, { action: 'refresh_flags', csrf_token: csrfToken })
                .done(function(resp) {
                    if (resp.success) {
                        updateFlagStatus(resp.data.flagStatus);
                        alert('Feature flags refreshed.');
                    } else {
                        alert('Error: ' + resp.message);
                    }
                });
        }

        // Search users
        let searchTimeout = null;
        function searchUsers(query) {
            if (query.length < 2) {
                $('#userSearchResults').empty();
                return;
            }
            $.get(API_BASE, { action: 'search_users', q: query })
                .done(function(resp) {
                    const results = $('#userSearchResults');
                    results.empty();
                    if (resp.success && resp.data.users) {
                        resp.data.users.forEach(function(user) {
                            results.append(
                                '<a href="#" class="list-group-item list-group-item-action user-search-result" ' +
                                'data-userid="' + user.userid + '" data-name="' + escapeHtml(user.user_name) + '">' +
                                escapeHtml(user.user_name) + ' <small class="text-muted">(' + escapeHtml(user.user_email) + ')</small>' +
                                '</a>'
                            );
                        });
                    }
                });
        }

        // Add user to allowlist
        function addUser(userid, notes) {
            $.post(API_BASE, { action: 'add_user', userid: userid, notes: notes, csrf_token: csrfToken })
                .done(function(resp) {
                    if (resp.success) {
                        updateAllowlist(resp.data.allowedUsers);
                        bootstrap.Modal.getInstance('#addUserModal').hide();
                        resetAddUserModal();
                    } else {
                        alert('Error: ' + resp.message);
                    }
                });
        }

        // Remove user from allowlist
        function removeUser(userid) {
            $.post(API_BASE, { action: 'remove_user', userid: userid, csrf_token: csrfToken })
                .done(function(resp) {
                    if (resp.success) {
                        updateAllowlist(resp.data.allowedUsers);
                    } else {
                        alert('Error: ' + resp.message);
                    }
                });
        }

        function resetAddUserModal() {
            $('#userSearch').val('');
            $('#userSearchResults').empty();
            $('#addUserNotes').val('');
            $('#selectedUserId').val('');
            $('#selectedUserDisplay').addClass('d-none');
            $('#btnConfirmAddUser').prop('disabled', true);
        }

        // Helpers
        function escapeHtml(text) {
            if (!text) return '';
            return text.replace(/&/g, '&amp;')
                       .replace(/</g, '&lt;')
                       .replace(/>/g, '&gt;')
                       .replace(/"/g, '&quot;');
        }

        function truncate(str, len) {
            if (!str) return '';
            return str.length > len ? str.substring(0, len) + '...' : str;
        }

        // Event bindings
        $(function() {
            loadDashboard();

            $('#btnRefresh').on('click', loadDashboard);
            $('#btnRefreshFlags').on('click', refreshFlags);
            $('#btnEnableGlobal').on('click', function() { toggleGlobalFlag(true); });
            $('#btnDisableGlobal').on('click', function() { toggleGlobalFlag(false); });

            $('#userSearch').on('input', function() {
                clearTimeout(searchTimeout);
                searchTimeout = setTimeout(function() {
                    searchUsers($('#userSearch').val());
                }, 300);
            });

            $(document).on('click', '.user-search-result', function(e) {
                e.preventDefault();
                const userid = $(this).data('userid');
                const name = $(this).data('name');
                $('#selectedUserId').val(userid);
                $('#selectedUserName').text(name);
                $('#selectedUserDisplay').removeClass('d-none');
                $('#btnConfirmAddUser').prop('disabled', false);
            });

            $('#btnConfirmAddUser').on('click', function() {
                const userid = $('#selectedUserId').val();
                const notes = $('#addUserNotes').val();
                if (userid) {
                    addUser(userid, notes);
                }
            });

            $('#addUserModal').on('hidden.bs.modal', resetAddUserModal);
        });
    })();
    </script>
</body>
</html>
