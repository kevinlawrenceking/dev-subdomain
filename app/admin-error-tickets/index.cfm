<!---
TAO Error Ticket Management Dashboard
Admin-only page for viewing, searching, and resolving error tickets.

Access: /app/admin-error-tickets/
Security: Requires Administrator session role
Phase 2 of TAO-SPEC-2026-005 Centralized Error Management
--->

<!--- Security check --->
<cfif NOT isDefined("userRole") OR (userRole NEQ "Admin" AND userRole NEQ "Administrator")>
    <cflocation url="/app/dashboard_new/" addtoken="false" />
</cfif>

<!--- Generate CSRF token for resolve actions --->
<cfset csrfToken = CSRFGenerateToken() />

<!--- Summary counts for header cards --->
<cfquery name="qSummary" datasource="#application.dsn#">
    SELECT
        COUNT(*) AS total_tickets,
        SUM(CASE WHEN resolved = 0 THEN 1 ELSE 0 END) AS unresolved,
        SUM(CASE WHEN resolved = 1 AND DATE(resolved_at) = CURDATE() THEN 1 ELSE 0 END) AS resolved_today,
        SUM(CASE WHEN email_sent = 0 THEN 1 ELSE 0 END) AS email_failures
    FROM error_tickets
</cfquery>

<!DOCTYPE html>
<html>
<head>
    <title>Error Tickets | TAO Admin</title>
    <link href="/app/assets/css/bootstrap.css" rel="stylesheet" />
    <link href="/app/assets/css/app.min.css" rel="stylesheet" />
    <style>
        body { background: #f5f6fa; }
        .metric-card {
            background: white;
            border-radius: 8px;
            padding: 15px;
            text-align: center;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-bottom: 15px;
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
        .filter-bar {
            background: white;
            border-radius: 8px;
            padding: 15px 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .ticket-table {
            font-size: 0.85rem;
        }
        .ticket-table th {
            background: #f5f5f5;
            white-space: nowrap;
            cursor: pointer;
        }
        .ticket-table th:hover {
            background: #e9ecef;
        }
        .ticket-table td {
            vertical-align: middle;
        }
        .badge-unresolved { background-color: #dc3545; color: white; }
        .badge-resolved { background-color: #28a745; color: white; }
        .ticket-id-cell {
            font-family: monospace;
            font-size: 0.8rem;
        }
        .script-cell {
            max-width: 200px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .error-msg-cell {
            max-width: 250px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .detail-section {
            margin-bottom: 15px;
        }
        .detail-section h6 {
            font-weight: 600;
            color: #495057;
            border-bottom: 1px solid #dee2e6;
            padding-bottom: 5px;
            margin-bottom: 10px;
        }
        .detail-pre {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            padding: 10px;
            max-height: 300px;
            overflow: auto;
            font-size: 0.8rem;
            white-space: pre-wrap;
            word-break: break-all;
        }
        .detail-kv { margin-bottom: 4px; }
        .detail-kv strong { display: inline-block; min-width: 120px; color: #555; }
        .pagination-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 15px;
        }
        .bulk-bar {
            background: #e3f2fd;
            border-radius: 6px;
            padding: 10px 15px;
            margin-bottom: 10px;
            display: none;
            align-items: center;
            gap: 10px;
        }
        .bulk-bar.active { display: flex; }
        #loadingOverlay {
            display: none;
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(255,255,255,0.7);
            z-index: 10;
            text-align: center;
            padding-top: 100px;
        }
    </style>
</head>
<body>
    <div class="container-fluid" style="padding: 20px;">

        <!--- Header --->
        <div class="row mb-3">
            <div class="col-12">
                <h1>
                    Error Tickets
                    <cfoutput>
                    <span class="badge badge-unresolved" style="font-size: 0.5em; vertical-align: middle;">
                        #NumberFormat(qSummary.unresolved, ",")# unresolved
                    </span>
                    </cfoutput>
                </h1>
                <p class="text-muted">
                    Centralized error management dashboard |
                    Last refreshed: <cfoutput>#DateTimeFormat(Now(), "yyyy-mm-dd HH:nn:ss")#</cfoutput>
                </p>
            </div>
        </div>

        <!--- Summary Cards --->
        <div class="row mb-3">
            <div class="col-md-3">
                <div class="metric-card">
                    <div class="metric-value" style="color: #007bff;">
                        <cfoutput>#NumberFormat(qSummary.total_tickets, ",")#</cfoutput>
                    </div>
                    <div class="metric-label">Total Tickets</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="metric-card">
                    <div class="metric-value" style="color: #dc3545;">
                        <cfoutput>#NumberFormat(qSummary.unresolved, ",")#</cfoutput>
                    </div>
                    <div class="metric-label">Unresolved</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="metric-card">
                    <div class="metric-value" style="color: #28a745;">
                        <cfoutput>#NumberFormat(qSummary.resolved_today, ",")#</cfoutput>
                    </div>
                    <div class="metric-label">Resolved Today</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="metric-card">
                    <div class="metric-value" style="color: #ffc107;">
                        <cfoutput>#NumberFormat(qSummary.email_failures, ",")#</cfoutput>
                    </div>
                    <div class="metric-label">Email Failures</div>
                </div>
            </div>
        </div>

        <!--- Filter Bar --->
        <div class="filter-bar">
            <form id="filterForm" class="form-inline" onsubmit="return false;">
                <div class="row w-100 align-items-end">
                    <div class="col-md-2">
                        <label class="small font-weight-bold">Status</label>
                        <select id="filterStatus" class="form-control form-control-sm">
                            <option value="unresolved" selected>Unresolved</option>
                            <option value="all">All</option>
                            <option value="resolved">Resolved</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="small font-weight-bold">From</label>
                        <input type="date" id="filterDateFrom" class="form-control form-control-sm" />
                    </div>
                    <div class="col-md-2">
                        <label class="small font-weight-bold">To</label>
                        <input type="date" id="filterDateTo" class="form-control form-control-sm" />
                    </div>
                    <div class="col-md-2">
                        <label class="small font-weight-bold">Environment</label>
                        <select id="filterEnv" class="form-control form-control-sm">
                            <option value="">All</option>
                            <option value="TAO_PROD">Production</option>
                            <option value="TAO_DEV">Development</option>
                            <option value="TAO_UAT">UAT</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="small font-weight-bold">Search</label>
                        <input type="text" id="filterSearch" class="form-control form-control-sm"
                               placeholder="ticket ID, message, script, email..." />
                    </div>
                    <div class="col-md-1">
                        <button type="button" class="btn btn-primary btn-sm btn-block" onclick="loadTickets(1)">
                            Apply
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <!--- Bulk Action Bar --->
        <div class="bulk-bar" id="bulkBar">
            <span id="bulkCount">0</span> ticket(s) selected
            <input type="text" id="bulkNotes" class="form-control form-control-sm" style="width:300px;"
                   placeholder="Resolution notes (optional)..." />
            <button class="btn btn-success btn-sm" onclick="bulkResolve()">Bulk Resolve</button>
            <button class="btn btn-secondary btn-sm" onclick="clearSelection()">Clear</button>
        </div>

        <!--- Tickets Table --->
        <div class="card" style="position: relative;">
            <div id="loadingOverlay">
                <div class="spinner-border text-primary" role="status"></div>
                <p class="mt-2 text-muted">Loading tickets...</p>
            </div>
            <div class="card-body p-0">
                <table class="table table-sm table-hover ticket-table mb-0">
                    <thead>
                        <tr>
                            <th style="width:30px;">
                                <input type="checkbox" id="selectAll" onclick="toggleSelectAll(this)" />
                            </th>
                            <th>Ticket ID</th>
                            <th>Date</th>
                            <th>Error Type</th>
                            <th>Message</th>
                            <th>Script</th>
                            <th>User</th>
                            <th>Env</th>
                            <th>Status</th>
                            <th style="width:120px;">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="ticketBody">
                        <tr><td colspan="10" class="text-center text-muted p-4">Loading...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!--- Pagination --->
        <div class="pagination-bar" id="paginationBar">
            <span class="text-muted small" id="paginationInfo"></span>
            <div>
                <button class="btn btn-sm btn-outline-secondary" id="btnPrev" onclick="prevPage()" disabled>Prev</button>
                <button class="btn btn-sm btn-outline-secondary" id="btnNext" onclick="nextPage()" disabled>Next</button>
            </div>
        </div>

    </div>

    <!--- Detail Modal --->
    <div class="modal fade" id="detailModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="detailModalTitle">Error Ticket Detail</h5>
                    <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
                </div>
                <div class="modal-body" id="detailModalBody">
                    <p class="text-muted">Loading...</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-success btn-sm" id="detailResolveBtn"
                            onclick="openResolveFromDetail()">Mark Resolved</button>
                </div>
            </div>
        </div>
    </div>

    <!--- Resolve Modal --->
    <div class="modal fade" id="resolveModal" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Resolve Ticket</h5>
                    <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <p>Ticket: <strong id="resolveTicketId"></strong></p>
                    <div class="form-group">
                        <label for="resolveNotes">Resolution Notes</label>
                        <textarea id="resolveNotes" class="form-control" rows="4"
                                  placeholder="Describe the resolution or root cause..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-success btn-sm" onclick="submitResolve()">Mark Resolved</button>
                </div>
            </div>
        </div>
    </div>

    <script src="/app/assets/js/bootstrap.bundle.js"></script>
    <cfoutput>
    <script>
        var csrfToken = '#csrfToken#';
        var currentPage = 1;
        var pageSize = 50;
        var totalTickets = 0;
        var currentDetailTicketId = '';

        // Set default date range: last 7 days
        (function() {
            var today = new Date();
            var weekAgo = new Date();
            weekAgo.setDate(today.getDate() - 7);
            document.getElementById('filterDateTo').value = formatDate(today);
            document.getElementById('filterDateFrom').value = formatDate(weekAgo);
        })();

        function formatDate(d) {
            var mm = String(d.getMonth() + 1).padStart(2, '0');
            var dd = String(d.getDate()).padStart(2, '0');
            return d.getFullYear() + '-' + mm + '-' + dd;
        }

        function loadTickets(page) {
            currentPage = page || 1;
            var params = {
                status: document.getElementById('filterStatus').value,
                date_from: document.getElementById('filterDateFrom').value,
                date_to: document.getElementById('filterDateTo').value,
                search: document.getElementById('filterSearch').value,
                environment: document.getElementById('filterEnv').value,
                page: currentPage,
                pageSize: pageSize
            };

            var qs = Object.keys(params).map(function(k) {
                return encodeURIComponent(k) + '=' + encodeURIComponent(params[k]);
            }).join('&');

            document.getElementById('loadingOverlay').style.display = 'block';

            var xhr = new XMLHttpRequest();
            xhr.open('GET', '/ajax/admin-error-tickets/list.cfm?' + qs);
            xhr.setRequestHeader('Accept', 'application/json');
            xhr.onload = function() {
                document.getElementById('loadingOverlay').style.display = 'none';
                if (xhr.status === 200) {
                    try {
                        var resp = JSON.parse(xhr.responseText);
                        if (resp.success) {
                            renderTickets(resp.data);
                        } else {
                            showTableError(resp.message || 'Failed to load tickets.');
                        }
                    } catch(e) {
                        showTableError('Invalid response from server.');
                    }
                } else {
                    showTableError('Server error: ' + xhr.status);
                }
            };
            xhr.onerror = function() {
                document.getElementById('loadingOverlay').style.display = 'none';
                showTableError('Network error.');
            };
            xhr.send();
        }

        function renderTickets(data) {
            var tickets = data.tickets || [];
            totalTickets = data.total || 0;
            var tbody = document.getElementById('ticketBody');

            if (tickets.length === 0) {
                tbody.innerHTML = '<tr><td colspan="10" class="text-center text-muted p-4">No tickets found matching your filters.</td></tr>';
                updatePagination();
                return;
            }

            var html = '';
            for (var i = 0; i < tickets.length; i++) {
                var t = tickets[i];
                var statusBadge = t.resolved
                    ? '<span class="badge badge-resolved">Resolved</span>'
                    : '<span class="badge badge-unresolved">Open</span>';
                var resolveBtn = t.resolved
                    ? ''
                    : '<button class="btn btn-outline-success btn-sm" onclick="openResolve(\'' + escHtml(t.ticket_id) + '\')">Resolve</button>';
                var createdDate = t.created_at ? t.created_at.substring(0, 16) : '';
                var envLabel = t.environment || '';
                html += '<tr data-ticket="' + escAttr(t.ticket_id) + '">'
                    + '<td><input type="checkbox" class="ticket-cb" value="' + escAttr(t.ticket_id) + '" onclick="updateBulkBar()" /></td>'
                    + '<td class="ticket-id-cell"><a href="javascript:void(0)" onclick="viewDetail(\'' + escAttr(t.ticket_id) + '\')">' + escHtml(t.ticket_id) + '</a></td>'
                    + '<td>' + escHtml(createdDate) + '</td>'
                    + '<td>' + escHtml(t.error_type || '') + '</td>'
                    + '<td class="error-msg-cell" title="' + escAttr(t.error_message || '') + '">' + escHtml(truncate(t.error_message || '', 80)) + '</td>'
                    + '<td class="script-cell" title="' + escAttr(t.script_name || '') + '">' + escHtml(t.script_name || '') + '</td>'
                    + '<td>' + escHtml(t.user_email || (t.user_id ? 'User #' + t.user_id : '')) + '</td>'
                    + '<td>' + escHtml(envLabel) + '</td>'
                    + '<td>' + statusBadge + '</td>'
                    + '<td>'
                    + '<button class="btn btn-outline-primary btn-sm mr-1" onclick="viewDetail(\'' + escAttr(t.ticket_id) + '\')">View</button>'
                    + resolveBtn
                    + '</td>'
                    + '</tr>';
            }
            tbody.innerHTML = html;
            updatePagination();
            document.getElementById('selectAll').checked = false;
            updateBulkBar();
        }

        function updatePagination() {
            var totalPages = Math.ceil(totalTickets / pageSize) || 1;
            var start = ((currentPage - 1) * pageSize) + 1;
            var end = Math.min(currentPage * pageSize, totalTickets);
            if (totalTickets === 0) { start = 0; end = 0; }

            document.getElementById('paginationInfo').textContent =
                'Showing ' + start + '-' + end + ' of ' + totalTickets + ' tickets (page ' + currentPage + ' of ' + totalPages + ')';
            document.getElementById('btnPrev').disabled = (currentPage <= 1);
            document.getElementById('btnNext').disabled = (currentPage >= totalPages);
        }

        function prevPage() { if (currentPage > 1) loadTickets(currentPage - 1); }
        function nextPage() { loadTickets(currentPage + 1); }

        function showTableError(msg) {
            document.getElementById('ticketBody').innerHTML =
                '<tr><td colspan="10" class="text-center text-danger p-4">' + escHtml(msg) + '</td></tr>';
        }

        // --- Detail Modal ---
        function viewDetail(ticketId) {
            currentDetailTicketId = ticketId;
            document.getElementById('detailModalTitle').textContent = 'Ticket: ' + ticketId;
            document.getElementById('detailModalBody').innerHTML = '<p class="text-muted">Loading...</p>';
            $('#detailModal').modal('show');

            var xhr = new XMLHttpRequest();
            xhr.open('GET', '/ajax/admin-error-tickets/detail.cfm?ticket_id=' + encodeURIComponent(ticketId));
            xhr.setRequestHeader('Accept', 'application/json');
            xhr.onload = function() {
                if (xhr.status === 200) {
                    try {
                        var resp = JSON.parse(xhr.responseText);
                        if (resp.success) {
                            renderDetail(resp.data);
                        } else {
                            document.getElementById('detailModalBody').innerHTML =
                                '<p class="text-danger">' + escHtml(resp.message || 'Not found.') + '</p>';
                        }
                    } catch(e) {
                        document.getElementById('detailModalBody').innerHTML =
                            '<p class="text-danger">Invalid server response.</p>';
                    }
                }
            };
            xhr.send();
        }

        function renderDetail(t) {
            var resolved = t.resolved ? 'Yes' : 'No';
            var resolvedInfo = '';
            if (t.resolved) {
                resolvedInfo = '<div class="detail-kv"><strong>Resolved at:</strong> ' + escHtml(t.resolved_at || '') + '</div>'
                    + '<div class="detail-kv"><strong>Resolved by:</strong> User #' + escHtml(String(t.resolved_by || '')) + '</div>'
                    + '<div class="detail-kv"><strong>Notes:</strong> ' + escHtml(t.resolved_notes || '') + '</div>';
                document.getElementById('detailResolveBtn').style.display = 'none';
            } else {
                document.getElementById('detailResolveBtn').style.display = '';
            }

            var html = ''
                + '<div class="detail-section">'
                + '<h6>Ticket Info</h6>'
                + '<div class="detail-kv"><strong>Ticket ID:</strong> ' + escHtml(t.ticket_id) + '</div>'
                + '<div class="detail-kv"><strong>Created:</strong> ' + escHtml(t.created_at || '') + '</div>'
                + '<div class="detail-kv"><strong>Status:</strong> ' + resolved + '</div>'
                + resolvedInfo
                + '<div class="detail-kv"><strong>Email sent:</strong> ' + (t.email_sent ? 'Yes' : 'No') + '</div>'
                + '</div>'

                + '<div class="detail-section">'
                + '<h6>Error Details</h6>'
                + '<div class="detail-kv"><strong>Type:</strong> ' + escHtml(t.error_type || '') + '</div>'
                + '<div class="detail-kv"><strong>Message:</strong> ' + escHtml(t.error_message || '') + '</div>'
                + '<div class="detail-kv"><strong>Detail:</strong> ' + escHtml(t.error_detail || '') + '</div>'
                + '</div>'

                + '<div class="detail-section">'
                + '<h6>Request Context</h6>'
                + '<div class="detail-kv"><strong>Script:</strong> ' + escHtml(t.script_name || '') + '</div>'
                + '<div class="detail-kv"><strong>Query string:</strong> ' + escHtml(t.query_string || '') + '</div>'
                + '<div class="detail-kv"><strong>HTTP method:</strong> ' + escHtml(t.http_method || '') + '</div>'
                + '<div class="detail-kv"><strong>Referer:</strong> ' + escHtml(t.http_referer || '') + '</div>'
                + '<div class="detail-kv"><strong>Remote IP:</strong> ' + escHtml(t.remote_ip || '') + '</div>'
                + '<div class="detail-kv"><strong>User agent:</strong> ' + escHtml(t.user_agent || '') + '</div>'
                + '<div class="detail-kv"><strong>User:</strong> ' + escHtml(t.user_email || '') + (t.user_id ? ' (ID: ' + t.user_id + ')' : '') + '</div>'
                + '<div class="detail-kv"><strong>Environment:</strong> ' + escHtml(t.environment || '') + '</div>'
                + '<div class="detail-kv"><strong>CF engine:</strong> ' + escHtml(t.cf_engine || '') + '</div>'
                + '<div class="detail-kv"><strong>Server:</strong> ' + escHtml(t.server_name || '') + '</div>'
                + '</div>';

            if (t.stack_trace) {
                html += '<div class="detail-section">'
                    + '<h6>Stack Trace</h6>'
                    + '<pre class="detail-pre">' + escHtml(t.stack_trace) + '</pre>'
                    + '</div>';
            }

            if (t.tag_context) {
                html += '<div class="detail-section">'
                    + '<h6>Tag Context</h6>'
                    + '<pre class="detail-pre">' + escHtml(formatJson(t.tag_context)) + '</pre>'
                    + '</div>';
            }

            if (t.sql_statement) {
                html += '<div class="detail-section">'
                    + '<h6>SQL Statement</h6>'
                    + '<pre class="detail-pre">' + escHtml(t.sql_statement) + '</pre>'
                    + '</div>';
            }

            if (t.form_data) {
                html += '<div class="detail-section">'
                    + '<h6>Form Data</h6>'
                    + '<pre class="detail-pre">' + escHtml(formatJson(t.form_data)) + '</pre>'
                    + '</div>';
            }

            document.getElementById('detailModalBody').innerHTML = html;
        }

        function formatJson(str) {
            try {
                return JSON.stringify(JSON.parse(str), null, 2);
            } catch(e) {
                return str;
            }
        }

        // --- Resolve ---
        function openResolve(ticketId) {
            document.getElementById('resolveTicketId').textContent = ticketId;
            document.getElementById('resolveNotes').value = '';
            document.getElementById('resolveTicketId').dataset.ticketId = ticketId;
            $('#resolveModal').modal('show');
        }

        function openResolveFromDetail() {
            $('#detailModal').modal('hide');
            openResolve(currentDetailTicketId);
        }

        function submitResolve() {
            var ticketId = document.getElementById('resolveTicketId').dataset.ticketId;
            var notes = document.getElementById('resolveNotes').value;

            var formData = new FormData();
            formData.append('ticket_id', ticketId);
            formData.append('resolved_notes', notes);
            formData.append('csrf_token', csrfToken);

            var xhr = new XMLHttpRequest();
            xhr.open('POST', '/ajax/admin-error-tickets/resolve.cfm');
            xhr.setRequestHeader('Accept', 'application/json');
            xhr.onload = function() {
                if (xhr.status === 200) {
                    try {
                        var resp = JSON.parse(xhr.responseText);
                        if (resp.success) {
                            $('#resolveModal').modal('hide');
                            loadTickets(currentPage);
                        } else {
                            alert(resp.message || 'Resolve failed.');
                        }
                    } catch(e) {
                        alert('Invalid server response.');
                    }
                } else {
                    alert('Server error: ' + xhr.status);
                }
            };
            xhr.send(formData);
        }

        // --- Bulk selection ---
        function toggleSelectAll(cb) {
            var boxes = document.querySelectorAll('.ticket-cb');
            for (var i = 0; i < boxes.length; i++) { boxes[i].checked = cb.checked; }
            updateBulkBar();
        }

        function updateBulkBar() {
            var checked = document.querySelectorAll('.ticket-cb:checked');
            var bar = document.getElementById('bulkBar');
            document.getElementById('bulkCount').textContent = checked.length;
            if (checked.length > 0) { bar.classList.add('active'); }
            else { bar.classList.remove('active'); }
        }

        function clearSelection() {
            document.getElementById('selectAll').checked = false;
            toggleSelectAll({ checked: false });
        }

        function bulkResolve() {
            var checked = document.querySelectorAll('.ticket-cb:checked');
            if (checked.length === 0) return;

            var ids = [];
            for (var i = 0; i < checked.length; i++) { ids.push(checked[i].value); }

            var notes = document.getElementById('bulkNotes').value;

            if (!confirm('Resolve ' + ids.length + ' ticket(s)?')) return;

            var formData = new FormData();
            formData.append('ticket_ids', ids.join(','));
            formData.append('resolved_notes', notes);
            formData.append('csrf_token', csrfToken);

            var xhr = new XMLHttpRequest();
            xhr.open('POST', '/ajax/admin-error-tickets/bulk-resolve.cfm');
            xhr.setRequestHeader('Accept', 'application/json');
            xhr.onload = function() {
                if (xhr.status === 200) {
                    try {
                        var resp = JSON.parse(xhr.responseText);
                        if (resp.success) {
                            document.getElementById('bulkNotes').value = '';
                            clearSelection();
                            loadTickets(currentPage);
                        } else {
                            alert(resp.message || 'Bulk resolve failed.');
                        }
                    } catch(e) {
                        alert('Invalid server response.');
                    }
                } else {
                    alert('Server error: ' + xhr.status);
                }
            };
            xhr.send(formData);
        }

        // --- Helpers ---
        function escHtml(str) {
            var div = document.createElement('div');
            div.appendChild(document.createTextNode(str));
            return div.innerHTML;
        }

        function escAttr(str) {
            return String(str).replace(/&/g,'&amp;').replace(/"/g,'&quot;').replace(/'/g,'&#39;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
        }

        function truncate(str, len) {
            if (!str) return '';
            return str.length > len ? str.substring(0, len) + '...' : str;
        }

        // Load tickets on page load
        loadTickets(1);
    </script>
    </cfoutput>
</body>
</html>
