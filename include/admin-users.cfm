<!---
    Admin User Management - User List
    Include template for core.cfm framework
    pgDir: admin-users | pgFilename: admin-users.cfm
--->
<cfinclude template="/app/admin-users/admin-guard.cfm">

<style>
    .status-active { color: #198754; font-weight: 600; }
    .status-cancelled { color: #dc3545; font-weight: 600; }
    .status-pending { color: #fd7e14; font-weight: 600; }
    .status-setup { color: #0dcaf0; font-weight: 600; }
    .status-other { color: #6c757d; font-weight: 600; }
    .user-row { cursor: pointer; }
    .user-row:hover { background-color: #f8f9fa; }
    .flag-badge { font-size: 0.7rem; padding: 2px 6px; border-radius: 3px; }
    .flag-on { background: #d4edda; color: #155724; }
    .flag-off { background: #f8d7da; color: #721c24; }
    .sort-header { cursor: pointer; user-select: none; white-space: nowrap; }
    .sort-header:hover { color: #0d6efd; }
    .sort-header .sort-arrow { font-size: 0.7rem; margin-left: 2px; }
    .pagination-info { font-size: 0.875rem; color: #6c757d; }
</style>

<div class="row">
    <div class="col-12">

        <!--- Header --->
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <p class="text-muted mb-0">Manage TAO user accounts</p>
            </div>
            <div>
                <button id="btnCreateUser" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#userModal">
                    + New User
                </button>
                <!--- TAO-SETUP-TEST-HARNESS-01 D2: dev-only setup-test provisioner --->
                <cfif structKeyExists(application, "dsn") AND application.dsn EQ "abod">
                    <button id="btnOpenTestSetup" class="btn btn-outline-secondary btn-sm" data-bs-toggle="modal" data-bs-target="#testSetupModal" title="Provision a setup-test user (dev only)">
                        Create Test Setup User
                    </button>
                </cfif>
            </div>
        </div>

        <!--- Filters --->
        <div class="card mb-3">
            <div class="card-body py-2">
                <div class="row g-2 align-items-end">
                    <div class="col-md-4">
                        <label class="form-label small mb-0">Search</label>
                        <input type="text" id="filterSearch" class="form-control form-control-sm" placeholder="Name, email, or user ID...">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small mb-0">Status</label>
                        <select id="filterStatus" class="form-select form-select-sm">
                            <option value="">All Statuses</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small mb-0">Role</label>
                        <select id="filterRole" class="form-select form-select-sm">
                            <option value="">All Roles</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small mb-0">Per Page</label>
                        <select id="filterPageSize" class="form-select form-select-sm">
                            <option value="25">25</option>
                            <option value="50">50</option>
                            <option value="100">100</option>
                        </select>
                    </div>
                    <div class="col-md-2 text-end">
                        <button id="btnClearFilters" class="btn btn-outline-secondary btn-sm">Clear</button>
                        <button id="btnRefresh" class="btn btn-outline-primary btn-sm ms-1">Refresh</button>
                    </div>
                </div>
            </div>
        </div>

        <!--- Users Table --->
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-sm table-striped mb-0">
                        <thead class="table-light">
                            <tr>
                                <th class="sort-header" data-col="userid">ID <span class="sort-arrow"></span></th>
                                <th class="sort-header" data-col="userFirstName">Name <span class="sort-arrow"></span></th>
                                <th class="sort-header" data-col="userEmail">Email <span class="sort-arrow"></span></th>
                                <th class="sort-header" data-col="userRole">Role <span class="sort-arrow"></span></th>
                                <th class="sort-header" data-col="userstatus">Status <span class="sort-arrow"></span></th>
                                <th>Flags</th>
                                <th class="sort-header" data-col="customerid">CID <span class="sort-arrow"></span></th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody id="usersTableBody">
                            <tr><td colspan="8" class="text-center py-3">Loading...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="card-footer d-flex justify-content-between align-items-center py-2">
                <div class="pagination-info">
                    Showing <span id="showingFrom">0</span>-<span id="showingTo">0</span> of <span id="totalUsers">0</span> users
                </div>
                <nav>
                    <ul class="pagination pagination-sm mb-0" id="pagination"></ul>
                </nav>
            </div>
        </div>

    </div>
</div>

<!--- Create/Edit User Modal --->
<div class="modal fade" id="userModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="userModalTitle">New User</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div id="userFormAlert" class="alert d-none"></div>
                <form id="userForm">
                    <input type="hidden" id="formUserid" value="0">
                    <div class="row mb-3">
                        <div class="col-6">
                            <label class="form-label">First Name *</label>
                            <input type="text" id="formFirstName" class="form-control form-control-sm" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label">Last Name *</label>
                            <input type="text" id="formLastName" class="form-control form-control-sm" required>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email *</label>
                        <input type="email" id="formEmail" class="form-control form-control-sm" required>
                    </div>
                    <div class="row mb-3">
                        <div class="col-6">
                            <label class="form-label">Role</label>
                            <select id="formRole" class="form-select form-select-sm">
                                <option value="User">User</option>
                                <option value="Admin">Admin</option>
                                <option value="Administrator">Administrator</option>
                            </select>
                        </div>
                        <div class="col-6">
                            <label class="form-label">Status</label>
                            <select id="formStatus" class="form-select form-select-sm">
                                <option value="Active">Active</option>
                                <option value="Cancelled">Cancelled</option>
                                <option value="Pending">Pending</option>
                                <option value="Setup">Setup</option>
                            </select>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label" id="passwordLabel">Password *</label>
                        <input type="password" id="formPassword" class="form-control form-control-sm">
                        <div class="form-text" id="passwordHelp">Minimum 6 characters. Leave blank to keep current password (edit mode).</div>
                    </div>
                    <div id="flagsSection" class="d-none">
                        <hr>
                        <div class="row">
                            <div class="col-4">
                                <div class="form-check">
                                    <input type="checkbox" id="formBetaTester" class="form-check-input" value="1">
                                    <label class="form-check-label small" for="formBetaTester">Beta Tester</label>
                                </div>
                            </div>
                            <div class="col-4">
                                <div class="form-check">
                                    <input type="checkbox" id="formAudition" class="form-check-input" value="1">
                                    <label class="form-check-label small" for="formAudition">Audition</label>
                                </div>
                            </div>
                            <div class="col-4">
                                <div class="form-check">
                                    <input type="checkbox" id="formAuditionModule" class="form-check-input" value="1">
                                    <label class="form-check-label small" for="formAuditionModule">Audition Module</label>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" id="btnSaveUser" class="btn btn-primary btn-sm">Save User</button>
            </div>
        </div>
    </div>
</div>

<!--- TAO-SETUP-TEST-HARNESS-01 D2: dev-only setup-test provisioner modal --->
<cfif structKeyExists(application, "dsn") AND application.dsn EQ "abod">
<div class="modal fade" id="testSetupModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Create Test Setup User <span class="badge bg-secondary">dev only</span></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div id="testSetupAlert" class="alert d-none"></div>
                <p class="text-muted small mb-3">
                    Provisions a user in pre-setup state (userstatus=Setup, is_setup_test=1) and runs full
                    provisioning. This user's setup email redirects to the test admin's inbox.
                </p>
                <div class="mb-3">
                    <label class="form-label">Contact Name *</label>
                    <input type="text" id="tsContactName" class="form-control form-control-sm" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Email</label>
                    <input type="email" id="tsEmail" class="form-control form-control-sm" placeholder="blank = auto-generate setup-test+{epoch}@theactorsoffice.com">
                </div>
                <div class="row">
                    <div class="col-6 mb-3">
                        <label class="form-label">Test Admin User ID</label>
                        <input type="number" id="tsAdminUserid" class="form-control form-control-sm" value="<cfoutput>#val(session.userid)#</cfoutput>">
                        <div class="form-text">Inbox that receives this user's setup email.</div>
                    </div>
                    <div class="col-6 mb-3">
                        <label class="form-label">Password</label>
                        <input type="text" id="tsPassword" class="form-control form-control-sm" placeholder="blank = default dev password">
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" id="btnRunTestSetup" class="btn btn-primary btn-sm">Create Test User</button>
            </div>
        </div>
    </div>
</div>
</cfif>

<script>
(function() {
    var $ = jQuery;
    var AJAX_BASE = '/app/admin-users/ajax/';

    // CSRF token for AJAX POST requests (required by Application.cfc middleware)
    var csrfMeta = document.querySelector('meta[name="csrf-token"]');
    var csrfToken = csrfMeta ? csrfMeta.getAttribute('content') : '';

    function adminPost(url, data) {
        return $.ajax({
            url: url,
            type: 'POST',
            data: data,
            headers: { 'X-CSRF-Token': csrfToken }
        });
    }

    // TAO-SETUP-TEST-HARNESS-01 D2: dev-only setup-test provisioner. Routes through
    // adminPost() so it uses the same central-CSRF path as every other admin action.
    function tsSetupAlert(msg, ok) {
        $('#testSetupAlert').removeClass('d-none alert-success alert-danger')
            .addClass(ok ? 'alert-success' : 'alert-danger').text(msg);
    }

    function provisionTestSetup() {
        var name = $.trim($('#tsContactName').val());
        if (!name) { tsSetupAlert('Contact name is required.', false); return; }
        $('#btnRunTestSetup').prop('disabled', true).text('Creating...');
        adminPost(AJAX_BASE + 'create-test-setup.cfm', {
            contactName: name,
            email: $.trim($('#tsEmail').val()),
            testAdminUserid: $.trim($('#tsAdminUserid').val()),
            password: $('#tsPassword').val()
        }).done(function(r) {
            if (r && r.success) {
                tsSetupAlert('Created userid ' + r.data.userid + ' (' + r.data.email + '). Reloading...', true);
                setTimeout(function() { location.reload(); }, 1300);
            } else {
                tsSetupAlert((r && r.message) ? r.message : 'Provision failed.', false);
            }
        }).fail(function(xhr) {
            tsSetupAlert('Request failed (' + xhr.status + '). ' + (xhr.responseText || ''), false);
        }).always(function() {
            $('#btnRunTestSetup').prop('disabled', false).text('Create Test User');
        });
    }

    var state = {
        page: 1,
        pageSize: 25,
        sortCol: 'userid',
        sortDir: 'DESC',
        search: '',
        status: '',
        role: '',
        filtersLoaded: false
    };
    var searchTimeout = null;

    // ---- Data Loading ----

    function loadUsers() {
        var params = {
            page: state.page,
            pageSize: state.pageSize,
            sortCol: state.sortCol,
            sortDir: state.sortDir,
            search: state.search,
            status: state.status,
            role: state.role
        };

        $.get(AJAX_BASE + 'list.cfm', params)
            .done(function(resp) {
                if (resp.success || resp.SUCCESS) {
                    var data = resp.data || resp.DATA;
                    renderUsers(data.users || data.USERS);
                    renderPagination(data.page || data.PAGE, data.totalPages || data.TOTALPAGES, data.total || data.TOTAL, data.pageSize || data.PAGESIZE);

                    if (!state.filtersLoaded) {
                        var filters = resp.filters || resp.FILTERS;
                        populateFilters(filters);
                        state.filtersLoaded = true;
                    }
                } else {
                    showTableError(resp.message || resp.MESSAGE || 'Failed to load users');
                }
            })
            .fail(function(xhr) {
                if (xhr.status === 403) {
                    showTableError('Access denied. Admin role required.');
                } else {
                    showTableError('Failed to load users. Please try again.');
                }
            });
    }

    function renderUsers(users) {
        var tbody = $('#usersTableBody');
        tbody.empty();

        if (!users || users.length === 0) {
            tbody.append('<tr><td colspan="8" class="text-center py-3 text-muted">No users found</td></tr>');
            return;
        }

        users.forEach(function(u) {
            var uid = u.userid || u.USERID;
            var firstName = u.userFirstName || u.USERFIRSTNAME || '';
            var lastName = u.userLastName || u.USERLASTNAME || '';
            var email = u.userEmail || u.USEREMAIL || '';
            var role = u.userRole || u.USERROLE || '';
            var status = u.userstatus || u.USERSTATUS || '';
            var isDeleted = u.IsDeleted || u.ISDELETED || 0;
            var isBeta = u.IsBetaTester || u.ISBETATESTER || 0;
            var isAud = u.isAudition || u.ISAUDITION || 0;
            var isAudMod = u.isAuditionModule || u.ISAUDITIONMODULE || 0;
            var cid = u.customerid || u.CUSTOMERID || '';

            var statusClass = 'status-other';
            var sl = status.toLowerCase();
            if (sl === 'active') statusClass = 'status-active';
            else if (sl === 'cancelled') statusClass = 'status-cancelled';
            else if (sl === 'pending') statusClass = 'status-pending';
            else if (sl === 'setup') statusClass = 'status-setup';

            var flags = '';
            if (Number(isBeta)) flags += '<span class="flag-badge flag-on me-1">Beta</span>';
            if (Number(isAud)) flags += '<span class="flag-badge flag-on me-1">Audition</span>';
            if (Number(isAudMod)) flags += '<span class="flag-badge flag-on me-1">Aud Module</span>';
            if (Number(isDeleted)) flags += '<span class="flag-badge flag-off me-1">Deleted</span>';
            if (!flags) flags = '<span class="text-muted">-</span>';

            var name = escapeHtml(firstName + ' ' + lastName);

            tbody.append(
                '<tr class="user-row" data-userid="' + uid + '">' +
                '<td>' + uid + '</td>' +
                '<td>' + name + '</td>' +
                '<td>' + escapeHtml(email) + '</td>' +
                '<td>' + escapeHtml(role) + '</td>' +
                '<td><span class="' + statusClass + '">' + escapeHtml(status) + '</span></td>' +
                '<td>' + flags + '</td>' +
                '<td>' + (cid || '-') + '</td>' +
                '<td><button class="btn btn-outline-primary btn-sm btn-edit" data-userid="' + uid + '">Edit</button></td>' +
                '</tr>'
            );
        });
    }

    function renderPagination(page, totalPages, total, pageSize) {
        page = Number(page) || 1;
        totalPages = Number(totalPages) || 1;
        total = Number(total) || 0;
        pageSize = Number(pageSize) || 25;

        var from = total === 0 ? 0 : (page - 1) * pageSize + 1;
        var to = Math.min(page * pageSize, total);
        $('#showingFrom').text(from);
        $('#showingTo').text(to);
        $('#totalUsers').text(total);

        var pag = $('#pagination');
        pag.empty();

        if (totalPages <= 1) return;

        pag.append('<li class="page-item ' + (page <= 1 ? 'disabled' : '') + '"><a class="page-link" href="#" data-page="' + (page - 1) + '">Prev</a></li>');

        var startP = Math.max(1, page - 3);
        var endP = Math.min(totalPages, startP + 6);
        if (endP - startP < 6) startP = Math.max(1, endP - 6);

        for (var i = startP; i <= endP; i++) {
            pag.append('<li class="page-item ' + (i === page ? 'active' : '') + '"><a class="page-link" href="#" data-page="' + i + '">' + i + '</a></li>');
        }

        pag.append('<li class="page-item ' + (page >= totalPages ? 'disabled' : '') + '"><a class="page-link" href="#" data-page="' + (page + 1) + '">Next</a></li>');
    }

    function populateFilters(filters) {
        if (!filters) return;
        var statuses = filters.statuses || filters.STATUSES || [];
        var roles = filters.roles || filters.ROLES || [];

        var statusSel = $('#filterStatus');
        statuses.forEach(function(s) {
            statusSel.append('<option value="' + escapeHtml(s) + '">' + escapeHtml(s) + '</option>');
        });

        var roleSel = $('#filterRole');
        roles.forEach(function(r) {
            roleSel.append('<option value="' + escapeHtml(r) + '">' + escapeHtml(r) + '</option>');
        });
    }

    function showTableError(msg) {
        $('#usersTableBody').html('<tr><td colspan="8" class="text-center py-3 text-danger">' + escapeHtml(msg) + '</td></tr>');
    }

    // ---- Create/Edit Modal ----

    function openCreateModal() {
        $('#userModalTitle').text('New User');
        $('#formUserid').val(0);
        $('#formFirstName').val('');
        $('#formLastName').val('');
        $('#formEmail').val('');
        $('#formRole').val('User');
        $('#formStatus').val('Active');
        $('#formPassword').val('');
        $('#formBetaTester').prop('checked', false);
        $('#formAudition').prop('checked', false);
        $('#formAuditionModule').prop('checked', false);
        $('#passwordLabel').text('Password *');
        $('#passwordHelp').text('Minimum 6 characters.');
        $('#flagsSection').addClass('d-none');
        hideFormAlert();
    }

    function openEditModal(userid) {
        hideFormAlert();
        $('#userModalTitle').text('Edit User #' + userid);
        $('#formUserid').val(userid);
        $('#passwordLabel').text('New Password');
        $('#passwordHelp').text('Leave blank to keep current password. Min 6 characters if changing.');
        $('#flagsSection').removeClass('d-none');

        $.get(AJAX_BASE + 'get.cfm', { userid: userid })
            .done(function(resp) {
                if (resp.success || resp.SUCCESS) {
                    var u = resp.data ? (resp.data.user || resp.data.USER) : (resp.DATA ? (resp.DATA.user || resp.DATA.USER) : null);
                    if (!u) { showFormAlert('danger', 'User data not found'); return; }

                    $('#formFirstName').val(u.userFirstName || u.USERFIRSTNAME || '');
                    $('#formLastName').val(u.userLastName || u.USERLASTNAME || '');
                    $('#formEmail').val(u.userEmail || u.USEREMAIL || '');
                    $('#formRole').val(u.userRole || u.USERROLE || 'User');
                    $('#formStatus').val(u.userstatus || u.USERSTATUS || 'Active');
                    $('#formPassword').val('');
                    $('#formBetaTester').prop('checked', Number(u.IsBetaTester || u.ISBETATESTER || 0) === 1);
                    $('#formAudition').prop('checked', Number(u.isAudition || u.ISAUDITION || 0) === 1);
                    $('#formAuditionModule').prop('checked', Number(u.isAuditionModule || u.ISAUDITIONMODULE || 0) === 1);

                    new bootstrap.Modal('#userModal').show();
                } else {
                    alert('Failed to load user: ' + (resp.message || resp.MESSAGE));
                }
            })
            .fail(function() {
                alert('Failed to load user details.');
            });
    }

    function saveUser() {
        var uid = Number($('#formUserid').val());
        var data = {
            userid: uid,
            userFirstName: $('#formFirstName').val().trim(),
            userLastName: $('#formLastName').val().trim(),
            userEmail: $('#formEmail').val().trim(),
            userRole: $('#formRole').val(),
            userstatus: $('#formStatus').val(),
            password: $('#formPassword').val(),
            IsBetaTester: $('#formBetaTester').is(':checked') ? 1 : 0,
            isAudition: $('#formAudition').is(':checked') ? 1 : 0,
            isAuditionModule: $('#formAuditionModule').is(':checked') ? 1 : 0
        };

        if (!data.userFirstName) { showFormAlert('danger', 'First name is required'); return; }
        if (!data.userLastName) { showFormAlert('danger', 'Last name is required'); return; }
        if (!data.userEmail) { showFormAlert('danger', 'Email is required'); return; }
        if (uid === 0 && !data.password) { showFormAlert('danger', 'Password is required for new users'); return; }
        if (data.password && data.password.length < 6) { showFormAlert('danger', 'Password must be at least 6 characters'); return; }

        $('#btnSaveUser').prop('disabled', true).text('Saving...');

        adminPost(AJAX_BASE + 'save.cfm', data)
            .done(function(resp) {
                if (resp.success || resp.SUCCESS) {
                    bootstrap.Modal.getInstance(document.getElementById('userModal')).hide();
                    loadUsers();
                } else {
                    showFormAlert('danger', resp.message || resp.MESSAGE || 'Save failed');
                }
            })
            .fail(function() {
                showFormAlert('danger', 'Request failed. Please try again.');
            })
            .always(function() {
                $('#btnSaveUser').prop('disabled', false).text('Save User');
            });
    }

    function showFormAlert(type, msg) {
        $('#userFormAlert').removeClass('d-none alert-success alert-danger alert-warning')
            .addClass('alert-' + type).text(msg);
    }

    function hideFormAlert() {
        $('#userFormAlert').addClass('d-none');
    }

    // ---- Sorting ----

    function updateSortArrows() {
        $('.sort-header .sort-arrow').text('');
        var header = $('.sort-header[data-col="' + state.sortCol + '"]');
        header.find('.sort-arrow').text(state.sortDir === 'ASC' ? ' \u25B2' : ' \u25BC');
    }

    // ---- Helpers ----

    function escapeHtml(text) {
        if (text === null || text === undefined) return '';
        return String(text).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    // ---- Event Bindings ----

    $(function() {
        loadUsers();
        updateSortArrows();

        $('#filterSearch').on('input', function() {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(function() {
                state.search = $('#filterSearch').val();
                state.page = 1;
                loadUsers();
            }, 400);
        });

        $('#filterStatus, #filterRole').on('change', function() {
            state.status = $('#filterStatus').val();
            state.role = $('#filterRole').val();
            state.page = 1;
            loadUsers();
        });

        $('#filterPageSize').on('change', function() {
            state.pageSize = Number($(this).val());
            state.page = 1;
            loadUsers();
        });

        $('#btnClearFilters').on('click', function() {
            $('#filterSearch').val('');
            $('#filterStatus').val('');
            $('#filterRole').val('');
            $('#filterPageSize').val('25');
            state.search = '';
            state.status = '';
            state.role = '';
            state.pageSize = 25;
            state.page = 1;
            loadUsers();
        });

        $('#btnRefresh').on('click', function() {
            loadUsers();
        });

        $(document).on('click', '.sort-header', function() {
            var col = $(this).data('col');
            if (state.sortCol === col) {
                state.sortDir = state.sortDir === 'ASC' ? 'DESC' : 'ASC';
            } else {
                state.sortCol = col;
                state.sortDir = 'ASC';
            }
            updateSortArrows();
            state.page = 1;
            loadUsers();
        });

        $(document).on('click', '#pagination .page-link', function(e) {
            e.preventDefault();
            var p = Number($(this).data('page'));
            if (p >= 1) {
                state.page = p;
                loadUsers();
            }
        });

        $(document).on('click', '.user-row td:not(:last-child)', function() {
            var uid = $(this).closest('tr').data('userid');
            window.location.href = '/app/admin-users-detail/?userid=' + uid;
        });

        $(document).on('click', '.btn-edit', function(e) {
            e.stopPropagation();
            openEditModal($(this).data('userid'));
        });

        $('#btnCreateUser').on('click', function() {
            openCreateModal();
        });

        $('#btnSaveUser').on('click', function() {
            saveUser();
        });

        // TAO-SETUP-TEST-HARNESS-01 D2: dev-only. Explicit presence guard so the handler
        // never binds on prod, where the button/modal are not rendered (application.dsn gate).
        if (document.getElementById('btnRunTestSetup')) {
            $('#btnRunTestSetup').on('click', function() {
                provisionTestSetup();
            });
        }

        $('#userForm').on('keydown', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                saveUser();
            }
        });
    });
})();
</script>
