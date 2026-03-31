<!---
    Admin User Management - User Detail
    Include template for core.cfm framework
    pgDir: admin-users-detail | pgFilename: admin-users-detail.cfm
--->
<cfinclude template="/app/admin-users/admin-guard.cfm">

<cfparam name="url.userid" default="0">
<cfset variables.targetUserId = val(url.userid)>

<cfif variables.targetUserId lte 0>
    <cflocation url="/app/admin-users/" addtoken="false">
</cfif>

<style>
    .detail-label { font-weight: 600; color: #6c757d; font-size: 0.8rem; text-transform: uppercase; }
    .detail-value { font-size: 0.95rem; }
    .status-active { color: #198754; font-weight: 600; }
    .status-cancelled { color: #dc3545; font-weight: 600; }
    .status-pending { color: #fd7e14; font-weight: 600; }
    .status-setup { color: #0dcaf0; font-weight: 600; }
    .status-other { color: #6c757d; font-weight: 600; }
    .flag-badge { font-size: 0.75rem; padding: 3px 8px; border-radius: 4px; margin-right: 4px; }
    .flag-on { background: #d4edda; color: #155724; }
    .flag-off { background: #f8d7da; color: #721c24; }
    .action-card { border-left: 3px solid #0d6efd; }
    .email-preview-frame { border: 1px solid #dee2e6; border-radius: 4px; padding: 1rem; background: white; max-height: 400px; overflow-y: auto; }
</style>

<div class="row">
    <div class="col-12">

        <!--- Header --->
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <a href="/app/admin-users/" class="text-decoration-none text-muted small">&larr; Back to User List</a>
                <h4 class="mb-0" id="pageTitle">User Detail</h4>
            </div>
            <div>
                <button id="btnEditUser" class="btn btn-primary btn-sm">Edit User</button>
                <a href="/app/admin-users/" class="btn btn-outline-secondary btn-sm ms-1">User List</a>
            </div>
        </div>

        <div id="loadingMsg" class="text-center py-5"><div class="spinner-border text-primary"></div></div>
        <div id="errorMsg" class="alert alert-danger d-none"></div>

        <div id="userContent" class="d-none">
            <div class="row">
                <!--- Left: Profile Info --->
                <div class="col-lg-8">
                    <div class="card mb-3">
                        <div class="card-header"><h5 class="mb-0">Profile</h5></div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <div class="detail-label">Full Name</div>
                                    <div class="detail-value" id="detailName"></div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <div class="detail-label">Email</div>
                                    <div class="detail-value" id="detailEmail"></div>
                                </div>
                                <div class="col-md-3 mb-3">
                                    <div class="detail-label">User ID</div>
                                    <div class="detail-value" id="detailUserid"></div>
                                </div>
                                <div class="col-md-3 mb-3">
                                    <div class="detail-label">Customer ID</div>
                                    <div class="detail-value" id="detailCustomerid"></div>
                                </div>
                                <div class="col-md-3 mb-3">
                                    <div class="detail-label">Role</div>
                                    <div class="detail-value" id="detailRole"></div>
                                </div>
                                <div class="col-md-3 mb-3">
                                    <div class="detail-label">Status</div>
                                    <div class="detail-value" id="detailStatus"></div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-4 mb-3">
                                    <div class="detail-label">Timezone</div>
                                    <div class="detail-value" id="detailTimezone"></div>
                                </div>
                                <div class="col-md-4 mb-3">
                                    <div class="detail-label">Region</div>
                                    <div class="detail-value" id="detailRegion"></div>
                                </div>
                                <div class="col-md-4 mb-3">
                                    <div class="detail-label">Plan</div>
                                    <div class="detail-value" id="detailPlan"></div>
                                </div>
                            </div>
                            <div>
                                <div class="detail-label">Flags</div>
                                <div id="detailFlags" class="mt-1"></div>
                            </div>
                        </div>
                    </div>

                    <!--- ThriveCart Info (if available) --->
                    <div class="card mb-3 d-none" id="thrivecartCard">
                        <div class="card-header"><h5 class="mb-0">ThriveCart / Billing</h5></div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-4 mb-2">
                                    <div class="detail-label">TC Name</div>
                                    <div class="detail-value" id="detailTcName"></div>
                                </div>
                                <div class="col-md-4 mb-2">
                                    <div class="detail-label">TC Email</div>
                                    <div class="detail-value" id="detailTcEmail"></div>
                                </div>
                                <div class="col-md-4 mb-2">
                                    <div class="detail-label">TC Status</div>
                                    <div class="detail-value" id="detailTcStatus"></div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6 mb-2">
                                    <div class="detail-label">Product</div>
                                    <div class="detail-value" id="detailProduct"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!--- Right: Actions --->
                <div class="col-lg-4">
                    <!--- Status Actions --->
                    <div class="card action-card mb-3">
                        <div class="card-header"><h6 class="mb-0">Status Actions</h6></div>
                        <div class="card-body">
                            <div id="statusActions"></div>
                            <div id="statusActionResult" class="mt-2 small"></div>
                        </div>
                    </div>

                    <!--- Email Actions --->
                    <div class="card action-card mb-3">
                        <div class="card-header"><h6 class="mb-0">Send Email</h6></div>
                        <div class="card-body">
                            <div class="d-grid gap-2">
                                <button class="btn btn-outline-primary btn-sm btn-email" data-template="welcome">
                                    Resend Welcome Email
                                </button>
                                <button class="btn btn-outline-warning btn-sm btn-email" data-template="password_reset">
                                    Send Password Reset
                                </button>
                            </div>
                            <div id="emailActionResult" class="mt-2 small"></div>
                        </div>
                    </div>
                </div>
            </div>

            <!--- Email Preview Modal --->
            <div class="modal fade" id="emailPreviewModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title">Email Preview</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <div class="mb-2">
                                <span class="detail-label">To:</span> <span id="previewTo"></span>
                            </div>
                            <div class="mb-2">
                                <span class="detail-label">From:</span> <span id="previewFrom"></span>
                            </div>
                            <div class="mb-3">
                                <span class="detail-label">Subject:</span> <span id="previewSubject"></span>
                            </div>
                            <div class="email-preview-frame" id="previewBody"></div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                            <button type="button" id="btnConfirmSendEmail" class="btn btn-primary btn-sm">Send Email</button>
                        </div>
                    </div>
                </div>
            </div>

            <!--- Edit User Modal --->
            <div class="modal fade" id="editModal" tabindex="-1">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title">Edit User</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <div id="editFormAlert" class="alert d-none"></div>
                            <form id="editForm">
                                <div class="row mb-3">
                                    <div class="col-6">
                                        <label class="form-label">First Name *</label>
                                        <input type="text" id="editFirstName" class="form-control form-control-sm" required>
                                    </div>
                                    <div class="col-6">
                                        <label class="form-label">Last Name *</label>
                                        <input type="text" id="editLastName" class="form-control form-control-sm" required>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Email *</label>
                                    <input type="email" id="editEmail" class="form-control form-control-sm" required>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-6">
                                        <label class="form-label">Role</label>
                                        <select id="editRole" class="form-select form-select-sm">
                                            <option value="User">User</option>
                                            <option value="Admin">Admin</option>
                                            <option value="Administrator">Administrator</option>
                                        </select>
                                    </div>
                                    <div class="col-6">
                                        <label class="form-label">Status</label>
                                        <select id="editStatus" class="form-select form-select-sm">
                                            <option value="Active">Active</option>
                                            <option value="Cancelled">Cancelled</option>
                                            <option value="Pending">Pending</option>
                                            <option value="Setup">Setup</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">New Password</label>
                                    <input type="password" id="editPassword" class="form-control form-control-sm">
                                    <div class="form-text">Leave blank to keep current. Min 6 characters if changing.</div>
                                </div>
                                <hr>
                                <div class="row">
                                    <div class="col-4">
                                        <div class="form-check">
                                            <input type="checkbox" id="editBetaTester" class="form-check-input">
                                            <label class="form-check-label small" for="editBetaTester">Beta Tester</label>
                                        </div>
                                    </div>
                                    <div class="col-4">
                                        <div class="form-check">
                                            <input type="checkbox" id="editAudition" class="form-check-input">
                                            <label class="form-check-label small" for="editAudition">Audition</label>
                                        </div>
                                    </div>
                                    <div class="col-4">
                                        <div class="form-check">
                                            <input type="checkbox" id="editAuditionModule" class="form-check-input">
                                            <label class="form-check-label small" for="editAuditionModule">Audition Module</label>
                                        </div>
                                    </div>
                                </div>
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                            <button type="button" id="btnSaveEdit" class="btn btn-primary btn-sm">Save Changes</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<script>
(function() {
    var $ = jQuery;
    var AJAX_BASE = '/app/admin-users/ajax/';
    var USER_ID = <cfoutput>#val(variables.targetUserId)#</cfoutput>;
    var userData = null;
    var pendingEmailTemplate = '';

    // CSRF token for AJAX POST requests
    var csrfMeta = document.querySelector('meta[name="csrf-token"]');
    var csrfToken = csrfMeta ? csrfMeta.getAttribute('content') : '';

    // ---- Helpers ----

    function adminPost(url, data) {
        return $.ajax({
            url: url,
            type: 'POST',
            data: data,
            headers: { 'X-CSRF-Token': csrfToken }
        });
    }

    function escapeHtml(text) {
        if (text === null || text === undefined) return '';
        return String(text).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    function getVal(obj, keys) {
        for (var i = 0; i < keys.length; i++) {
            if (obj[keys[i]] !== undefined && obj[keys[i]] !== null) return obj[keys[i]];
        }
        return '';
    }

    function statusClass(s) {
        var sl = String(s).toLowerCase();
        if (sl === 'active') return 'status-active';
        if (sl === 'cancelled') return 'status-cancelled';
        if (sl === 'pending') return 'status-pending';
        if (sl === 'setup') return 'status-setup';
        return 'status-other';
    }

    // ---- Load User ----

    function loadUser() {
        $.get(AJAX_BASE + 'get.cfm', { userid: USER_ID })
            .done(function(resp) {
                $('#loadingMsg').addClass('d-none');
                if (resp.success || resp.SUCCESS) {
                    var data = resp.data || resp.DATA;
                    userData = data.user || data.USER;
                    renderUser();
                    $('#userContent').removeClass('d-none');
                } else {
                    $('#errorMsg').removeClass('d-none').text(resp.message || resp.MESSAGE || 'User not found');
                }
            })
            .fail(function(xhr) {
                $('#loadingMsg').addClass('d-none');
                if (xhr.status === 403) {
                    $('#errorMsg').removeClass('d-none').text('Access denied. Admin role required.');
                } else if (xhr.status === 404) {
                    $('#errorMsg').removeClass('d-none').text('User not found.');
                } else {
                    $('#errorMsg').removeClass('d-none').text('Failed to load user details.');
                }
            });
    }

    function renderUser() {
        var u = userData;
        var firstName = getVal(u, ['userFirstName', 'USERFIRSTNAME']);
        var lastName = getVal(u, ['userLastName', 'USERLASTNAME']);
        var email = getVal(u, ['userEmail', 'USEREMAIL']);
        var role = getVal(u, ['userRole', 'USERROLE']);
        var status = getVal(u, ['userstatus', 'USERSTATUS']);
        var uid = getVal(u, ['userid', 'USERID']);
        var cid = getVal(u, ['customerid', 'CUSTOMERID']);

        $('#pageTitle').text(firstName + ' ' + lastName);

        $('#detailName').text(firstName + ' ' + lastName);
        $('#detailEmail').html('<a href="mailto:' + escapeHtml(email) + '">' + escapeHtml(email) + '</a>');
        $('#detailUserid').text(uid);
        $('#detailCustomerid').text(cid || '-');
        $('#detailRole').text(role);
        $('#detailStatus').html('<span class="' + statusClass(status) + '">' + escapeHtml(status) + '</span>');

        $('#detailTimezone').text(getVal(u, ['tzname', 'TZNAME']) || '-');
        $('#detailRegion').text(getVal(u, ['regionName', 'REGIONNAME']) || '-');
        $('#detailPlan').text(getVal(u, ['planName', 'PLANNAME']) || '-');

        // Flags
        var flags = '';
        if (Number(getVal(u, ['IsBetaTester', 'ISBETATESTER']))) flags += '<span class="flag-badge flag-on">Beta Tester</span>';
        if (Number(getVal(u, ['isAudition', 'ISAUDITION']))) flags += '<span class="flag-badge flag-on">Audition</span>';
        if (Number(getVal(u, ['isAuditionModule', 'ISAUDITIONMODULE']))) flags += '<span class="flag-badge flag-on">Audition Module</span>';
        if (Number(getVal(u, ['isSetup', 'ISSETUP']))) flags += '<span class="flag-badge flag-on">Setup Complete</span>';
        if (Number(getVal(u, ['IsDeleted', 'ISDELETED']))) flags += '<span class="flag-badge flag-off">Deleted</span>';
        $('#detailFlags').html(flags || '<span class="text-muted">None</span>');

        // ThriveCart
        var tc = u.thrivecart || u.THRIVECART;
        if (tc) {
            $('#thrivecartCard').removeClass('d-none');
            var tcFirst = getVal(tc, ['customerfirst', 'CUSTOMERFIRST']);
            var tcLast = getVal(tc, ['customerlast', 'CUSTOMERLAST']);
            $('#detailTcName').text(tcFirst + ' ' + tcLast);
            $('#detailTcEmail').text(getVal(tc, ['customeremail', 'CUSTOMEREMAIL']));
            $('#detailTcStatus').text(getVal(tc, ['status', 'STATUS']));
            $('#detailProduct').text(getVal(u, ['productLabel', 'PRODUCTLABEL']) || '-');
        }

        renderStatusActions(status);
    }

    function renderStatusActions(currentStatus) {
        var actions = $('#statusActions');
        actions.empty();

        var sl = String(currentStatus).toLowerCase();

        if (sl === 'active') {
            actions.append('<button class="btn btn-outline-danger btn-sm w-100 btn-toggle-status" data-status="Cancelled">Deactivate User</button>');
        } else if (sl === 'cancelled') {
            actions.append('<button class="btn btn-outline-success btn-sm w-100 btn-toggle-status" data-status="Active">Reactivate User</button>');
        } else if (sl === 'pending') {
            actions.append('<button class="btn btn-outline-success btn-sm w-100 mb-2 btn-toggle-status" data-status="Active">Activate User</button>');
            actions.append('<button class="btn btn-outline-danger btn-sm w-100 btn-toggle-status" data-status="Cancelled">Cancel User</button>');
        } else if (sl === 'setup') {
            actions.append('<button class="btn btn-outline-success btn-sm w-100 mb-2 btn-toggle-status" data-status="Active">Activate User</button>');
            actions.append('<button class="btn btn-outline-danger btn-sm w-100 btn-toggle-status" data-status="Cancelled">Cancel User</button>');
        } else {
            actions.append('<button class="btn btn-outline-success btn-sm w-100 mb-2 btn-toggle-status" data-status="Active">Set Active</button>');
            actions.append('<button class="btn btn-outline-danger btn-sm w-100 btn-toggle-status" data-status="Cancelled">Set Cancelled</button>');
        }
    }

    // ---- Status Toggle ----

    function toggleStatus(newStatus) {
        if (!confirm('Change user status to "' + newStatus + '"?')) return;

        adminPost(AJAX_BASE + 'toggle-status.cfm', { userid: USER_ID, newStatus: newStatus })
            .done(function(resp) {
                if (resp.success || resp.SUCCESS) {
                    $('#statusActionResult').html('<span class="text-success">Status changed to ' + escapeHtml(newStatus) + '</span>');
                    loadUser();
                } else {
                    $('#statusActionResult').html('<span class="text-danger">' + escapeHtml(resp.message || resp.MESSAGE) + '</span>');
                }
            })
            .fail(function() {
                $('#statusActionResult').html('<span class="text-danger">Request failed</span>');
            });
    }

    // ---- Email ----

    function previewEmail(template) {
        pendingEmailTemplate = template;
        console.log('[AdminEmail] Preview request: template=' + template + ' userid=' + USER_ID);

        $.get(AJAX_BASE + 'preview-email.cfm', { userid: USER_ID, template: template })
            .done(function(resp) {
                console.log('[AdminEmail] Preview response:', resp);
                if (resp.success || resp.SUCCESS) {
                    var data = resp.data || resp.DATA;
                    $('#previewTo').text(data.to || data.TO);
                    $('#previewFrom').text(data.from || data.FROM);
                    $('#previewSubject').text(data.subject || data.SUBJECT);
                    $('#previewBody').html(data.body || data.BODY);
                    new bootstrap.Modal('#emailPreviewModal').show();
                } else {
                    console.warn('[AdminEmail] Preview failed:', resp.message || resp.MESSAGE);
                    $('#emailActionResult').html('<span class="text-danger">' + escapeHtml(resp.message || resp.MESSAGE) + '</span>');
                }
            })
            .fail(function(xhr, status, error) {
                console.error('[AdminEmail] Preview AJAX error:', status, error, xhr.responseText);
                $('#emailActionResult').html('<span class="text-danger">Preview failed</span>');
            });
    }

    function sendEmail() {
        $('#btnConfirmSendEmail').prop('disabled', true).text('Sending...');
        console.log('[AdminEmail] Send request: template=' + pendingEmailTemplate + ' userid=' + USER_ID);

        adminPost(AJAX_BASE + 'send-email.cfm', { userid: USER_ID, template: pendingEmailTemplate })
            .done(function(resp) {
                console.log('[AdminEmail] Send response:', resp);
                var debugLog = resp.debug || resp.DEBUG;
                if (debugLog && debugLog.length) {
                    console.group('[AdminEmail] Server debug log');
                    debugLog.forEach(function(entry) { console.log(entry); });
                    console.groupEnd();
                }
                bootstrap.Modal.getInstance(document.getElementById('emailPreviewModal')).hide();
                if (resp.success || resp.SUCCESS) {
                    console.log('[AdminEmail] Send OK:', resp.message || resp.MESSAGE);
                    $('#emailActionResult').html('<span class="text-success">' + escapeHtml(resp.message || resp.MESSAGE) + '</span>');
                    loadUser(); // Reload to reflect status change
                } else {
                    console.warn('[AdminEmail] Send failed:', resp.message || resp.MESSAGE);
                    $('#emailActionResult').html('<span class="text-danger">' + escapeHtml(resp.message || resp.MESSAGE) + '</span>');
                }
            })
            .fail(function(xhr, status, error) {
                console.error('[AdminEmail] Send AJAX error:', status, error, xhr.responseText);
                bootstrap.Modal.getInstance(document.getElementById('emailPreviewModal')).hide();
                $('#emailActionResult').html('<span class="text-danger">Send failed: ' + escapeHtml(error || status) + '</span>');
            })
            .always(function() {
                $('#btnConfirmSendEmail').prop('disabled', false).text('Send Email');
            });
    }

    // ---- Edit ----

    function openEditModal() {
        if (!userData) return;
        var u = userData;
        $('#editFirstName').val(getVal(u, ['userFirstName', 'USERFIRSTNAME']));
        $('#editLastName').val(getVal(u, ['userLastName', 'USERLASTNAME']));
        $('#editEmail').val(getVal(u, ['userEmail', 'USEREMAIL']));
        $('#editRole').val(getVal(u, ['userRole', 'USERROLE']) || 'User');
        $('#editStatus').val(getVal(u, ['userstatus', 'USERSTATUS']) || 'Active');
        $('#editPassword').val('');
        $('#editBetaTester').prop('checked', Number(getVal(u, ['IsBetaTester', 'ISBETATESTER'])) === 1);
        $('#editAudition').prop('checked', Number(getVal(u, ['isAudition', 'ISAUDITION'])) === 1);
        $('#editAuditionModule').prop('checked', Number(getVal(u, ['isAuditionModule', 'ISAUDITIONMODULE'])) === 1);
        $('#editFormAlert').addClass('d-none');
        new bootstrap.Modal('#editModal').show();
    }

    function saveEdit() {
        var data = {
            userid: USER_ID,
            userFirstName: $('#editFirstName').val().trim(),
            userLastName: $('#editLastName').val().trim(),
            userEmail: $('#editEmail').val().trim(),
            userRole: $('#editRole').val(),
            userstatus: $('#editStatus').val(),
            password: $('#editPassword').val(),
            IsBetaTester: $('#editBetaTester').is(':checked') ? 1 : 0,
            isAudition: $('#editAudition').is(':checked') ? 1 : 0,
            isAuditionModule: $('#editAuditionModule').is(':checked') ? 1 : 0
        };

        if (!data.userFirstName) { showEditAlert('danger', 'First name is required'); return; }
        if (!data.userLastName) { showEditAlert('danger', 'Last name is required'); return; }
        if (!data.userEmail) { showEditAlert('danger', 'Email is required'); return; }
        if (data.password && data.password.length < 6) { showEditAlert('danger', 'Password must be at least 6 characters'); return; }

        $('#btnSaveEdit').prop('disabled', true).text('Saving...');

        adminPost(AJAX_BASE + 'save.cfm', data)
            .done(function(resp) {
                if (resp.success || resp.SUCCESS) {
                    bootstrap.Modal.getInstance(document.getElementById('editModal')).hide();
                    loadUser();
                } else {
                    showEditAlert('danger', resp.message || resp.MESSAGE || 'Save failed');
                }
            })
            .fail(function() {
                showEditAlert('danger', 'Request failed');
            })
            .always(function() {
                $('#btnSaveEdit').prop('disabled', false).text('Save Changes');
            });
    }

    function showEditAlert(type, msg) {
        $('#editFormAlert').removeClass('d-none alert-success alert-danger').addClass('alert-' + type).text(msg);
    }

    // ---- Events ----

    $(function() {
        loadUser();

        $(document).on('click', '.btn-toggle-status', function() {
            toggleStatus($(this).data('status'));
        });

        $(document).on('click', '.btn-email', function() {
            previewEmail($(this).data('template'));
        });

        $('#btnConfirmSendEmail').on('click', sendEmail);

        $('#btnEditUser').on('click', openEditModal);

        $('#btnSaveEdit').on('click', saveEdit);

        $('#editForm').on('keydown', function(e) {
            if (e.key === 'Enter') { e.preventDefault(); saveEdit(); }
        });
    });
})();
</script>
