/**
 * Contact Import V3 - JavaScript Controller
 * Handles file upload, parsing, review grid, and import finalization
 *
 * V3 ENDPOINTS - All calls go to /ajax/importv3/ namespace
 */

(function() {
    'use strict';

    console.log('[V3] Contact Import V3 JavaScript loaded');

    // Field definitions with types for appropriate widgets
    var fieldDefinitions = {
        firstName: { type: 'text', label: 'First Name', group: 'name' },
        lastName: { type: 'text', label: 'Last Name', group: 'name' },
        contactFullName: { type: 'text', label: 'Full Name', group: 'name' },
        email_business: { type: 'email', label: 'Business Email', group: 'email' },
        email_personal: { type: 'email', label: 'Personal Email', group: 'email' },
        phone_work: { type: 'phone', label: 'Work Phone', group: 'phone' },
        phone_mobile: { type: 'phone', label: 'Mobile Phone', group: 'phone' },
        phone_home: { type: 'phone', label: 'Home Phone', group: 'phone' },
        company: { type: 'text', label: 'Company', group: 'company' },
        title: { type: 'text', label: 'Title', group: 'company' },
        address1: { type: 'text', label: 'Address Line 1', group: 'address' },
        address2: { type: 'text', label: 'Address Line 2', group: 'address' },
        city: { type: 'text', label: 'City', group: 'address' },
        state: { type: 'state', label: 'State', group: 'address' },
        zip: { type: 'text', label: 'Zip Code', group: 'address' },
        country: { type: 'country', label: 'Country', group: 'address' },
        birthday: { type: 'date', label: 'Birthday', group: 'dates' },
        relationship_start: { type: 'date', label: 'Relationship Start', group: 'dates' },
        website: { type: 'url', label: 'Website', group: 'web' },
        linkedin: { type: 'url', label: 'LinkedIn', group: 'web' },
        twitter: { type: 'text', label: 'Twitter', group: 'web' },
        instagram: { type: 'text', label: 'Instagram', group: 'web' },
        notes: { type: 'textarea', label: 'Notes', group: 'other' },
        tags: { type: 'tags', label: 'Tags', group: 'other' },
        category: { type: 'select', label: 'Category', group: 'classification', options: [
            { value: '', label: '(None)' },
            { value: 'casting', label: 'Casting' },
            { value: 'agent', label: 'Agent' },
            { value: 'manager', label: 'Manager' },
            { value: 'producer', label: 'Producer' },
            { value: 'director', label: 'Director' },
            { value: 'other', label: 'Other' }
        ]},
        contactType: { type: 'select', label: 'Contact Type', group: 'classification', options: [
            { value: '', label: '(None)' },
            { value: 'industry', label: 'Industry' },
            { value: 'personal', label: 'Personal' },
            { value: 'vendor', label: 'Vendor' }
        ]},
        relationship_system: { type: 'select', label: 'Relationship System', group: 'classification', options: [
            { value: '', label: '(None)' },
            { value: 'Target', label: 'Target (Targeted List)' },
            { value: 'Maintenance', label: 'Maintenance (Maintenance List)' }
        ]}
    };

    // US State list for dropdowns
    var usStates = [
        { value: '', label: '(Select State)' },
        { value: 'AL', label: 'Alabama' }, { value: 'AK', label: 'Alaska' }, { value: 'AZ', label: 'Arizona' },
        { value: 'AR', label: 'Arkansas' }, { value: 'CA', label: 'California' }, { value: 'CO', label: 'Colorado' },
        { value: 'CT', label: 'Connecticut' }, { value: 'DE', label: 'Delaware' }, { value: 'FL', label: 'Florida' },
        { value: 'GA', label: 'Georgia' }, { value: 'HI', label: 'Hawaii' }, { value: 'ID', label: 'Idaho' },
        { value: 'IL', label: 'Illinois' }, { value: 'IN', label: 'Indiana' }, { value: 'IA', label: 'Iowa' },
        { value: 'KS', label: 'Kansas' }, { value: 'KY', label: 'Kentucky' }, { value: 'LA', label: 'Louisiana' },
        { value: 'ME', label: 'Maine' }, { value: 'MD', label: 'Maryland' }, { value: 'MA', label: 'Massachusetts' },
        { value: 'MI', label: 'Michigan' }, { value: 'MN', label: 'Minnesota' }, { value: 'MS', label: 'Mississippi' },
        { value: 'MO', label: 'Missouri' }, { value: 'MT', label: 'Montana' }, { value: 'NE', label: 'Nebraska' },
        { value: 'NV', label: 'Nevada' }, { value: 'NH', label: 'New Hampshire' }, { value: 'NJ', label: 'New Jersey' },
        { value: 'NM', label: 'New Mexico' }, { value: 'NY', label: 'New York' }, { value: 'NC', label: 'North Carolina' },
        { value: 'ND', label: 'North Dakota' }, { value: 'OH', label: 'Ohio' }, { value: 'OK', label: 'Oklahoma' },
        { value: 'OR', label: 'Oregon' }, { value: 'PA', label: 'Pennsylvania' }, { value: 'RI', label: 'Rhode Island' },
        { value: 'SC', label: 'South Carolina' }, { value: 'SD', label: 'South Dakota' }, { value: 'TN', label: 'Tennessee' },
        { value: 'TX', label: 'Texas' }, { value: 'UT', label: 'Utah' }, { value: 'VT', label: 'Vermont' },
        { value: 'VA', label: 'Virginia' }, { value: 'WA', label: 'Washington' }, { value: 'WV', label: 'West Virginia' },
        { value: 'WI', label: 'Wisconsin' }, { value: 'WY', label: 'Wyoming' },
        { value: 'DC', label: 'Washington DC' }, { value: 'PR', label: 'Puerto Rico' }
    ];

    // State
    var state = {
        jobId: 0,
        currentFilter: '',
        currentPage: 1,
        pageSize: 50,
        selectedRows: new Set(),
        stats: {}
    };

    // Initialize on DOM ready
    $(document).ready(function() {
        console.log('[V3] ========== DOCUMENT READY ==========');
        console.log('[V3] Initializing Contact Import V3...');
        initUpload();
        initJobActions();
        initReviewGrid();
        initModals();

        // Check for active job
        var jobIdInput = document.getElementById('job-id');
        var jobStatusInput = document.getElementById('job-status');
        console.log('[V3] job-id element:', jobIdInput);
        console.log('[V3] job-status element:', jobStatusInput);

        if (jobIdInput) {
            state.jobId = parseInt(jobIdInput.value);
            var status = jobStatusInput ? jobStatusInput.value : 'unknown';
            console.log('[V3] Active job:', state.jobId, 'Status:', status);
            console.log('[V3] state object:', JSON.stringify(state));

            if (status === 'parsed' || status === 'mapping') {
                loadColumnMappings();
            } else if (status === 'reviewing' || status === 'finalizing' || status === 'completed') {
                loadRows();
            }
        }
    });

    // ========================================
    // FILE UPLOAD - V3 ENDPOINTS
    // ========================================

    function initUpload() {
        var uploadArea = document.getElementById('upload-area');
        var fileInput = document.getElementById('file-input');

        if (!uploadArea) return;

        // Click to upload
        uploadArea.addEventListener('click', function() {
            fileInput.click();
        });

        // File selected
        fileInput.addEventListener('change', function() {
            if (this.files.length > 0) {
                uploadFile(this.files[0]);
            }
        });

        // Drag and drop
        uploadArea.addEventListener('dragover', function(e) {
            e.preventDefault();
            this.classList.add('dragover');
        });

        uploadArea.addEventListener('dragleave', function() {
            this.classList.remove('dragover');
        });

        uploadArea.addEventListener('drop', function(e) {
            e.preventDefault();
            this.classList.remove('dragover');
            if (e.dataTransfer.files.length > 0) {
                uploadFile(e.dataTransfer.files[0]);
            }
        });
    }

    function uploadFile(file) {
        console.log('[V3] Uploading file:', file.name);

        // Validate file type (CSV, XLS, XLSX, VCF)
        var validTypes = ['text/csv', 'application/vnd.ms-excel',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'text/vcard', 'text/x-vcard'];
        var validExts = ['csv', 'xls', 'xlsx', 'vcf'];
        var ext = file.name.split('.').pop().toLowerCase();

        if (!validTypes.includes(file.type) && !validExts.includes(ext)) {
            showAlert('error', 'Invalid file type. Please upload CSV, XLS, XLSX, or VCF files.');
            return;
        }

        // Validate file size (50MB)
        if (file.size > 52428800) {
            showAlert('error', 'File too large. Maximum size is 50MB.');
            return;
        }

        // Show progress
        $('#upload-area').hide();
        $('#upload-progress').show();

        // Upload - V3 ENDPOINT
        var formData = new FormData();
        formData.append('file', file);

        $.ajax({
            url: '/ajax/importv3/upload.cfm',  // V3 ENDPOINT
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            xhr: function() {
                var xhr = new XMLHttpRequest();
                xhr.upload.addEventListener('progress', function(e) {
                    if (e.lengthComputable) {
                        var pct = (e.loaded / e.total) * 100;
                        $('#upload-progress .progress-bar').css('width', pct + '%');
                    }
                });
                return xhr;
            },
            success: function(response) {
                console.log('[V3] Upload response:', response);
                if (response.success) {
                    // Check if this is a duplicate file
                    if (response.is_duplicate_file && response.existing_job) {
                        var msg = 'Warning: This file was previously imported on ' +
                            response.existing_job.created_at +
                            ' (' + response.existing_job.imported_rows + ' contacts imported). ' +
                            'You can still proceed with this import.';
                        showAlert('warning', msg);
                    }
                    // Redirect to V3 job page
                    var jobId = response.data.job_id || (response.data.job && response.data.job.job_id);
                    window.location.href = '/app/contacts-import-v3/?job_id=' + jobId;
                } else {
                    var errMsg = response.message || 'Upload failed';
                    showAlert('error', errMsg);
                    $('#upload-area').show();
                    $('#upload-progress').hide();
                }
            },
            error: function(xhr, status, error) {
                console.error('[V3] Upload error:', error, xhr.responseText);
                var errMsg = 'Upload failed. Please try again.';
                if (xhr.responseText) {
                    try {
                        var resp = JSON.parse(xhr.responseText);
                        if (resp.message) errMsg = resp.message;
                    } catch(e) {
                        errMsg += ' (Response: ' + xhr.responseText.substring(0, 200) + ')';
                    }
                }
                showAlert('error', errMsg);
                $('#upload-area').show();
                $('#upload-progress').hide();
            }
        });
    }

    // ========================================
    // JOB ACTIONS - V3 ENDPOINTS
    // ========================================

    function initJobActions() {
        console.log('[V3] initJobActions called');
        // Parse button
        var parseBtn = $('#btn-parse');
        console.log('[V3] Parse button found:', parseBtn.length > 0);
        parseBtn.click(function() {
            console.log('[V3] Parse button CLICKED!');
            parseFile();
        });

        // Confirm mapping button
        $('#btn-confirm-mapping').click(function() {
            confirmMappings();
        });

        // Finalize button
        $('#btn-finalize').click(function() {
            finalizeImport();
        });

        // Dry-run button (preview)
        $('#btn-dry-run').click(function() {
            previewImport();
        });
    }

    function parseFile() {
        console.log('[V3] ========== PARSE STARTED ==========');
        console.log('[V3] state.jobId =', state.jobId);
        console.log('[V3] typeof state.jobId =', typeof state.jobId);

        if (!state.jobId || state.jobId <= 0) {
            console.error('[V3] ERROR: Invalid job ID!');
            alert('DEBUG: Invalid job ID: ' + state.jobId);
            return;
        }

        console.log('[V3] Sending request to /ajax/importv3/parse.cfm');
        alert('DEBUG: Starting parse for job_id=' + state.jobId);

        $('#btn-parse').prop('disabled', true);
        $('#parse-progress').show();

        $.ajax({
            url: '/ajax/importv3/parse.cfm',  // V3 ENDPOINT
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ job_id: state.jobId }),
            success: function(response) {
                console.log('[V3] ========== PARSE RESPONSE ==========');
                console.log('[V3] Full response:', JSON.stringify(response, null, 2));
                alert('DEBUG: Parse response received. success=' + response.success + ', check console for details');

                // Log debug array if present
                if (response.debug && response.debug.length > 0) {
                    console.log('[V3] Parse debug log (' + response.debug.length + ' entries):');
                    response.debug.forEach(function(line, idx) {
                        console.log('  [' + idx + '] ' + line);
                    });
                } else {
                    console.log('[V3] No debug array in response');
                }

                if (response.success) {
                    console.log('[V3] Parse successful, reloading page...');
                    // Reload page to show mapping step
                    window.location.reload();
                } else {
                    console.log('[V3] Parse failed:', response.message);
                    showAlert('error', response.message || 'Parsing failed');
                    $('#btn-parse').prop('disabled', false);
                    $('#parse-progress').hide();
                }
            },
            error: function(xhr, status, error) {
                console.error('[V3] ========== PARSE ERROR ==========');
                console.error('[V3] Status:', status);
                console.error('[V3] Error:', error);
                console.error('[V3] Response text:', xhr.responseText);
                alert('DEBUG: Parse AJAX error! status=' + status + ', error=' + error);

                // Try to parse debug from error response
                try {
                    var errResp = JSON.parse(xhr.responseText);
                    console.log('[V3] Parsed error response:', errResp);
                    if (errResp.debug && errResp.debug.length > 0) {
                        console.log('[V3] Parse error debug log:');
                        errResp.debug.forEach(function(line) {
                            console.log('  ' + line);
                        });
                    }
                } catch(e) {
                    console.error('[V3] Could not parse error response as JSON:', e);
                }
                showAlert('error', 'Parsing failed. Please try again.');
                $('#btn-parse').prop('disabled', false);
                $('#parse-progress').hide();
            }
        });
    }

    function loadColumnMappings() {
        console.log('[V3] Loading column mappings for job:', state.jobId);
        $.get('/ajax/importv3/columns.cfm?job_id=' + state.jobId, function(response) {
            console.log('[V3] Columns response:', response);
            if (response.success) {
                renderColumnMappings(response.data.columns, response.data.available_fields);
            } else {
                $('#mapping-container').html('<p class="text-danger">' + response.message + '</p>');
            }
        });
    }

    function renderColumnMappings(columns, availableFields) {
        var html = '<table class="table table-sm"><thead><tr><th>Source Column</th><th>Maps To</th><th>Confidence</th></tr></thead><tbody>';

        columns.forEach(function(col) {
            html += '<tr>';
            html += '<td><strong>' + escapeHtml(col.source_name || 'Column ' + (col.source_index + 1)) + '</strong></td>';
            html += '<td>';
            html += '<select class="form-control form-control-sm mapping-select" data-column-id="' + col.column_id + '">';
            html += '<option value="">(Do not import)</option>';

            availableFields.forEach(function(field) {
                var selected = field.field === col.mapped_field ? 'selected' : '';
                html += '<option value="' + field.field + '" ' + selected + '>' + escapeHtml(field.display_name) + '</option>';
            });

            html += '</select>';
            html += '</td>';
            html += '<td>';
            if (col.mapped_field && col.confidence) {
                var pct = Math.round(col.confidence * 100);
                var badgeClass = pct >= 90 ? 'badge-success' : (pct >= 70 ? 'badge-warning' : 'badge-secondary');
                html += '<span class="badge ' + badgeClass + '">' + pct + '%</span>';
            }
            html += '</td>';
            html += '</tr>';
        });

        html += '</tbody></table>';
        $('#mapping-container').html(html);
    }

    function confirmMappings() {
        console.log('[V3] Confirming mappings for job:', state.jobId);

        // Collect mappings
        var mappings = [];
        $('.mapping-select').each(function() {
            mappings.push({
                column_id: parseInt($(this).data('column-id')),
                field: $(this).val()
            });
        });

        $('#btn-confirm-mapping').prop('disabled', true);

        // V3 uses recompute endpoint to apply mappings and validate
        $.ajax({
            url: '/ajax/importv3/recompute.cfm',  // V3 ENDPOINT
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ job_id: state.jobId, mappings: mappings }),
            success: function(response) {
                console.log('[V3] Recompute response:', response);
                if (response.success) {
                    window.location.reload();
                } else {
                    showAlert('error', response.message || 'Failed to process');
                    $('#btn-confirm-mapping').prop('disabled', false);
                }
            },
            error: function(xhr) {
                console.error('[V3] Recompute error:', xhr.responseText);
                showAlert('error', 'Failed to process. Please try again.');
                $('#btn-confirm-mapping').prop('disabled', false);
            }
        });
    }

    // ========================================
    // REVIEW GRID - V3 ENDPOINTS
    // ========================================

    function initReviewGrid() {
        // Tab clicks
        $('#review-tabs .nav-link').click(function(e) {
            e.preventDefault();
            $('#review-tabs .nav-link').removeClass('active');
            $(this).addClass('active');
            state.currentFilter = $(this).data('filter');
            state.currentPage = 1;
            loadRows();
        });

        // Check all
        $('#check-all').change(function() {
            var checked = this.checked;
            $('.row-checkbox').each(function() {
                this.checked = checked;
                var rowId = parseInt($(this).data('row-id'));
                if (checked) {
                    state.selectedRows.add(rowId);
                } else {
                    state.selectedRows.delete(rowId);
                }
            });
            updateSelectedCount();
        });

        // Bulk actions
        $('#bulk-ignore').click(function() {
            bulkAction('ignore');
        });

        $('#bulk-import').click(function() {
            bulkAction('create');
        });
    }

    function loadRows() {
        console.log('[V3] Loading rows for job:', state.jobId, 'Filter:', state.currentFilter);

        var url = '/ajax/importv3/rows.cfm?job_id=' + state.jobId +
            '&status=' + encodeURIComponent(state.currentFilter) +
            '&page=' + state.currentPage +
            '&limit=' + state.pageSize;

        $.get(url, function(response) {
            console.log('[V3] Rows response:', response);
            if (response.success) {
                renderRows(response.data.rows);
                renderPagination(response.data.total, response.data.page, response.data.total_pages);
                updateStats();
            } else {
                $('#review-tbody').html('<tr><td colspan="8" class="text-center text-danger">' + response.message + '</td></tr>');
            }
        });
    }

    function renderRows(rows) {
        if (!rows || rows.length === 0) {
            $('#review-tbody').html('<tr><td colspan="8" class="text-center text-muted p-4">No rows found</td></tr>');
            return;
        }

        var html = '';
        rows.forEach(function(row) {
            var data = row.data || {};
            var validation = row.validation || {};

            var name = data.contactFullName || ((data.firstName || '') + ' ' + (data.lastName || '')).trim() || '-';
            var email = data.email_business || data.email_personal || '-';
            var phone = data.phone_work || data.phone_mobile || data.phone_home || '-';
            var company = data.company || '-';

            // Check for field errors
            var emailClass = hasFieldError(validation, 'email_business') || hasFieldError(validation, 'email_personal') ? 'text-danger' : '';
            var phoneClass = hasFieldError(validation, 'phone_work') || hasFieldError(validation, 'phone_mobile') ? 'text-danger' : '';

            html += '<tr data-row-id="' + row.row_id + '" class="' + (row.status === 'imported' ? 'table-light' : '') + '">';
            html += '<td><input type="checkbox" class="row-checkbox" data-row-id="' + row.row_id + '" ' + (row.status === 'imported' ? 'disabled' : '') + '></td>';
            html += '<td>' + row.row_num + '</td>';
            html += '<td>' + escapeHtml(name) + '</td>';
            html += '<td class="' + emailClass + '">' + escapeHtml(email) + '</td>';
            html += '<td class="' + phoneClass + '">' + escapeHtml(phone) + '</td>';
            html += '<td>' + escapeHtml(company) + '</td>';
            html += '<td><span class="status-badge status-' + row.status + '">' + row.status + '</span></td>';
            html += '<td>';

            if (row.status === 'problem') {
                html += '<button class="btn btn-xs btn-outline-primary btn-edit" data-row-id="' + row.row_id + '"><i class="fe-edit"></i></button> ';
            } else if (row.status === 'dupe') {
                html += '<button class="btn btn-xs btn-outline-warning btn-resolve-dupe" data-row-id="' + row.row_id + '"><i class="fe-users"></i></button> ';
            } else if (row.status === 'imported' && row.created_contactid) {
                html += '<a href="/app/contact/?contactid=' + row.created_contactid + '" class="btn btn-xs btn-outline-info"><i class="fe-eye"></i></a>';
            }

            html += '</td>';
            html += '</tr>';

            // Show validation errors
            if (row.status === 'problem' && row.errors && row.errors.length > 0) {
                html += '<tr class="bg-light"><td></td><td colspan="7">';
                html += '<small class="text-danger">';
                row.errors.forEach(function(err) {
                    html += '<i class="fe-alert-circle"></i> <strong>' + escapeHtml(err.field) + ':</strong> ' + escapeHtml(err.message) + '<br>';
                });
                html += '</small></td></tr>';
            }

            // Show duplicate info
            if (row.status === 'dupe' && row.duplicates && row.duplicates.length > 0) {
                html += '<tr class="bg-warning-light"><td></td><td colspan="7">';
                html += '<small class="text-warning"><i class="fe-alert-triangle"></i> ';
                html += 'Possible duplicate of: <strong>' + escapeHtml(row.duplicates[0].contactFullName || row.duplicates[0].recordname) + '</strong>';
                if (row.best_match_score) {
                    html += ' (Score: ' + row.best_match_score + ')';
                }
                html += '</small></td></tr>';
            }
        });

        $('#review-tbody').html(html);

        // Bind row actions
        $('.btn-edit').click(function() {
            editRow($(this).data('row-id'));
        });

        $('.btn-resolve-dupe').click(function() {
            resolveDupe($(this).data('row-id'));
        });

        $('.row-checkbox').change(function() {
            var rowId = parseInt($(this).data('row-id'));
            if (this.checked) {
                state.selectedRows.add(rowId);
            } else {
                state.selectedRows.delete(rowId);
            }
            updateSelectedCount();
        });
    }

    function hasFieldError(validation, field) {
        return validation[field] && !validation[field].valid;
    }

    function renderPagination(total, page, pages) {
        var start = ((page - 1) * state.pageSize) + 1;
        var end = Math.min(page * state.pageSize, total);
        $('#pagination-info').text('Showing ' + start + '-' + end + ' of ' + total);

        var html = '';
        if (pages > 1) {
            html += '<li class="page-item ' + (page === 1 ? 'disabled' : '') + '">';
            html += '<a class="page-link" href="#" data-page="' + (page - 1) + '">Prev</a></li>';

            for (var i = 1; i <= pages; i++) {
                if (i === 1 || i === pages || (i >= page - 2 && i <= page + 2)) {
                    html += '<li class="page-item ' + (i === page ? 'active' : '') + '">';
                    html += '<a class="page-link" href="#" data-page="' + i + '">' + i + '</a></li>';
                } else if (i === page - 3 || i === page + 3) {
                    html += '<li class="page-item disabled"><span class="page-link">...</span></li>';
                }
            }

            html += '<li class="page-item ' + (page === pages ? 'disabled' : '') + '">';
            html += '<a class="page-link" href="#" data-page="' + (page + 1) + '">Next</a></li>';
        }

        $('#pagination-nav ul').html(html);
        $('#pagination-nav .page-link').click(function(e) {
            e.preventDefault();
            var p = parseInt($(this).data('page'));
            if (p && p !== state.currentPage) {
                state.currentPage = p;
                loadRows();
            }
        });
    }

    function updateSelectedCount() {
        $('#selected-count').text(state.selectedRows.size + ' selected');
        if (state.selectedRows.size > 0) {
            $('#bulk-actions').show();
        } else {
            $('#bulk-actions').hide();
        }
    }

    function updateStats() {
        // V3 uses the rows endpoint with aggregation or a separate endpoint
        // For now, we get stats from the job status
        $.get('/ajax/importv3/rows.cfm?job_id=' + state.jobId + '&stats_only=1', function(response) {
            console.log('[V3] Stats response:', response);
            if (response.success && response.data.stats) {
                var stats = response.data.stats;
                state.stats = stats;
                $('#stat-total').text(stats.total || 0);
                $('#stat-ready').text(stats.ready || 0);
                $('#stat-problem').text(stats.problem || 0);
                $('#stat-dupe').text(stats.dupe || 0);
                $('#stat-imported').text(stats.imported || 0);

                $('#tab-all').text(stats.total || 0);
                $('#tab-ready').text(stats.ready || 0);
                $('#tab-problem').text(stats.problem || 0);
                $('#tab-dupe').text(stats.dupe || 0);
                $('#tab-ignored').text(stats.ignored || 0);
                $('#tab-imported').text(stats.imported || 0);

                $('#import-count').text(stats.ready || 0);

                // Show warning if no ready rows
                if ((stats.ready || 0) === 0) {
                    $('#finalize-warning').show();
                    $('#finalize-warning-text').text('No rows are ready for import. Please fix validation errors or resolve duplicates.');
                    $('#btn-finalize').prop('disabled', true);
                } else {
                    $('#finalize-warning').hide();
                    $('#btn-finalize').prop('disabled', false);
                }
            }
        });
    }

    function bulkAction(action) {
        if (state.selectedRows.size === 0) return;
        console.log('[V3] Bulk action:', action, 'Rows:', Array.from(state.selectedRows));

        $.ajax({
            url: '/ajax/importv3/row_action.cfm',  // V3 ENDPOINT
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({
                job_id: state.jobId,
                row_ids: Array.from(state.selectedRows),
                action: action
            }),
            success: function(response) {
                console.log('[V3] Bulk action response:', response);
                if (response.success) {
                    state.selectedRows.clear();
                    updateSelectedCount();
                    loadRows();
                } else {
                    showAlert('error', response.message);
                }
            }
        });
    }

    // ========================================
    // MODALS - V3 ENDPOINTS
    // ========================================

    function initModals() {
        // Edit save
        $('#edit-save').click(function() {
            saveEdit();
        });

        // Dupe actions
        $('#dupe-skip').click(function() {
            setDupeAction('ignore');
        });
        $('#dupe-update').click(function() {
            setDupeAction('update');
        });
        $('#dupe-import-new').click(function() {
            setDupeAction('create');
        });
    }

    var currentEditRowId = 0;
    var currentEditData = {};

    function editRow(rowId) {
        console.log('[V3] Editing row:', rowId);
        currentEditRowId = rowId;

        // Fetch single row detail - V3 ENDPOINT
        $.get('/ajax/importv3/row.cfm?job_id=' + state.jobId + '&row_id=' + rowId, function(response) {
            console.log('[V3] Row detail response:', response);
            if (response.success && response.data.row) {
                renderEditModal(response.data.row);
            } else {
                showAlert('error', 'Could not find row data');
            }
        });
    }

    function renderEditModal(row) {
        currentEditData = row.data || {};
        var validation = row.validation || {};

        // Group fields by category for better organization
        var fieldGroups = {
            'Name': ['firstName', 'lastName', 'contactFullName'],
            'Email': ['email_business', 'email_personal'],
            'Phone': ['phone_work', 'phone_mobile', 'phone_home'],
            'Company': ['company', 'title'],
            'Address': ['address1', 'address2', 'city', 'state', 'zip', 'country'],
            'Dates': ['birthday', 'relationship_start'],
            'Classification': ['category', 'contactType'],
            'Web': ['website', 'linkedin', 'twitter', 'instagram'],
            'Other': ['notes', 'tags']
        };

        var html = '<form id="edit-form">';

        // Only show fields that have data or errors
        var fieldsWithData = Object.keys(currentEditData).filter(function(k) {
            return currentEditData[k] !== '' && currentEditData[k] !== null;
        });
        var fieldsWithErrors = Object.keys(validation).filter(function(k) {
            return validation[k] && !validation[k].valid;
        });
        var relevantFields = new Set(fieldsWithData.concat(fieldsWithErrors));

        // Always show core fields
        ['firstName', 'lastName', 'email_business', 'phone_work', 'company'].forEach(function(f) {
            relevantFields.add(f);
        });

        for (var groupName in fieldGroups) {
            var groupFields = fieldGroups[groupName].filter(function(f) {
                return relevantFields.has(f);
            });

            if (groupFields.length === 0) continue;

            html += '<div class="edit-field-group mb-3">';
            html += '<h6 class="text-muted border-bottom pb-1 mb-2">' + groupName + '</h6>';
            html += '<div class="row">';

            groupFields.forEach(function(field) {
                var fieldDef = fieldDefinitions[field] || { type: 'text', label: formatFieldName(field) };
                var val = currentEditData[field] || '';
                var error = validation[field] && !validation[field].valid ? validation[field].error : '';
                var warning = validation[field] && validation[field].warning ? validation[field].warning : '';
                var inputClass = error ? 'is-invalid' : (warning ? 'is-warning' : '');

                var colClass = fieldDef.type === 'textarea' || fieldDef.type === 'notes' ? 'col-12' : 'col-md-6';

                html += '<div class="' + colClass + ' mb-2">';
                html += '<label class="form-label small">' + fieldDef.label + '</label>';
                html += renderFieldWidget(field, fieldDef, val, inputClass);

                if (error) {
                    html += '<div class="invalid-feedback d-block">' + escapeHtml(error) + '</div>';
                }
                if (warning) {
                    html += '<div class="text-warning small">' + escapeHtml(warning) + '</div>';
                }
                html += '</div>';
            });

            html += '</div></div>';
        }

        html += '</form>';

        $('#edit-modal-body').html(html);

        // Initialize phone formatters
        initializePhoneFormatters();

        $('#edit-modal').modal('show');
    }

    function renderFieldWidget(field, fieldDef, value, inputClass) {
        var html = '';

        switch (fieldDef.type) {
            case 'email':
                html = '<input type="email" class="form-control form-control-sm ' + inputClass + '" ' +
                    'name="' + field + '" value="' + escapeHtml(value) + '" placeholder="email@example.com">';
                break;

            case 'phone':
                html = '<input type="tel" class="form-control form-control-sm phone-input ' + inputClass + '" ' +
                    'name="' + field + '" value="' + escapeHtml(value) + '" placeholder="(555) 123-4567">';
                break;

            case 'date':
                var dateVal = value ? formatDateForInput(value) : '';
                html = '<input type="date" class="form-control form-control-sm date-input ' + inputClass + '" ' +
                    'name="' + field + '" value="' + escapeHtml(dateVal) + '">';
                break;

            case 'select':
                html = '<select class="form-control form-control-sm ' + inputClass + '" name="' + field + '">';
                if (fieldDef.options) {
                    fieldDef.options.forEach(function(opt) {
                        var selected = opt.value === value ? 'selected' : '';
                        html += '<option value="' + opt.value + '" ' + selected + '>' + escapeHtml(opt.label) + '</option>';
                    });
                }
                html += '</select>';
                break;

            case 'state':
                html = '<select class="form-control form-control-sm ' + inputClass + '" name="' + field + '">';
                usStates.forEach(function(st) {
                    var selected = st.value.toLowerCase() === (value || '').toLowerCase() ? 'selected' : '';
                    html += '<option value="' + st.value + '" ' + selected + '>' + escapeHtml(st.label) + '</option>';
                });
                html += '</select>';
                break;

            case 'country':
                html = '<input type="text" class="form-control form-control-sm ' + inputClass + '" ' +
                    'name="' + field + '" value="' + escapeHtml(value) + '" list="country-list" placeholder="Country">';
                html += '<datalist id="country-list">';
                html += '<option value="United States">';
                html += '<option value="Canada">';
                html += '<option value="United Kingdom">';
                html += '<option value="Australia">';
                html += '</datalist>';
                break;

            case 'url':
                html = '<input type="url" class="form-control form-control-sm ' + inputClass + '" ' +
                    'name="' + field + '" value="' + escapeHtml(value) + '" placeholder="https://">';
                break;

            case 'textarea':
            case 'notes':
                html = '<textarea class="form-control form-control-sm ' + inputClass + '" ' +
                    'name="' + field + '" rows="3">' + escapeHtml(value) + '</textarea>';
                break;

            case 'tags':
                html = '<input type="text" class="form-control form-control-sm ' + inputClass + '" ' +
                    'name="' + field + '" value="' + escapeHtml(value) + '" placeholder="tag1, tag2, tag3">';
                html += '<small class="form-text text-muted">Separate tags with commas</small>';
                break;

            default:
                html = '<input type="text" class="form-control form-control-sm ' + inputClass + '" ' +
                    'name="' + field + '" value="' + escapeHtml(value) + '">';
        }

        return html;
    }

    function formatDateForInput(dateStr) {
        if (!dateStr) return '';
        var date = new Date(dateStr);
        if (isNaN(date.getTime())) {
            var parts = dateStr.split('/');
            if (parts.length === 3) {
                date = new Date(parts[2], parseInt(parts[0]) - 1, parts[1]);
            }
        }
        if (isNaN(date.getTime())) return dateStr;

        var month = ('0' + (date.getMonth() + 1)).slice(-2);
        var day = ('0' + date.getDate()).slice(-2);
        return date.getFullYear() + '-' + month + '-' + day;
    }

    function initializePhoneFormatters() {
        $('.phone-input').on('input', function() {
            var val = $(this).val().replace(/\D/g, '');
            if (val.length >= 10) {
                val = '(' + val.substring(0, 3) + ') ' + val.substring(3, 6) + '-' + val.substring(6, 10);
            }
            $(this).val(val);
        });
    }

    function saveEdit() {
        var data = {};

        $('#edit-form input, #edit-form select, #edit-form textarea').each(function() {
            var name = $(this).attr('name');
            if (name) {
                data[name] = $(this).val();
            }
        });

        console.log('[V3] Saving edit for row:', currentEditRowId, 'Data:', data);

        var $btn = $('#edit-save');
        $btn.prop('disabled', true).html('<i class="fe-loader fe-spin"></i> Saving...');

        // V3 ENDPOINT - fact_update for individual field updates
        $.ajax({
            url: '/ajax/importv3/fact_update.cfm',  // V3 ENDPOINT
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({
                job_id: state.jobId,
                row_id: currentEditRowId,
                fields: data
            }),
            success: function(response) {
                console.log('[V3] Save response:', response);
                $btn.prop('disabled', false).html('<i class="fe-check"></i> Save Changes');
                if (response.success) {
                    $('#edit-modal').modal('hide');
                    showAlert('success', 'Row updated and revalidated');
                    loadRows();
                } else {
                    showAlert('error', response.message || 'Validation failed');
                }
            },
            error: function(xhr) {
                console.error('[V3] Save error:', xhr.responseText);
                $btn.prop('disabled', false).html('<i class="fe-check"></i> Save Changes');
                showAlert('error', 'Failed to save. Please try again.');
            }
        });
    }

    var currentDupeRowId = 0;

    function resolveDupe(rowId) {
        console.log('[V3] Resolving duplicate for row:', rowId);
        currentDupeRowId = rowId;

        // V3 ENDPOINT
        $.get('/ajax/importv3/row.cfm?job_id=' + state.jobId + '&row_id=' + rowId, function(response) {
            console.log('[V3] Dupe row response:', response);
            if (!response.success || !response.data.row) return;

            var row = response.data.row;
            var data = row.data || {};
            var dupes = row.duplicates || [];

            var html = '<div class="row">';

            // Import row
            html += '<div class="col-md-6">';
            html += '<h6>Importing:</h6>';
            html += '<table class="table table-sm">';
            html += '<tr><td><strong>Name</strong></td><td>' + escapeHtml(data.contactFullName || (data.firstName + ' ' + data.lastName)) + '</td></tr>';
            html += '<tr><td><strong>Email</strong></td><td>' + escapeHtml(data.email_business || data.email_personal || '-') + '</td></tr>';
            html += '<tr><td><strong>Phone</strong></td><td>' + escapeHtml(data.phone_work || data.phone_mobile || '-') + '</td></tr>';
            html += '<tr><td><strong>Company</strong></td><td>' + escapeHtml(data.company || '-') + '</td></tr>';
            html += '</table>';
            html += '</div>';

            // Existing contact
            if (dupes.length > 0) {
                var match = dupes[0];
                html += '<div class="col-md-6">';
                html += '<h6>Existing Contact' + (row.best_match_score ? ' (Score: ' + row.best_match_score + ')' : '') + ':</h6>';
                html += '<table class="table table-sm">';
                html += '<tr><td><strong>Name</strong></td><td>' + escapeHtml(match.contactFullName || match.recordname) + '</td></tr>';
                if (match.email) {
                    html += '<tr><td><strong>Email</strong></td><td class="text-success">' + escapeHtml(match.email) + '</td></tr>';
                }
                if (match.phone) {
                    html += '<tr><td><strong>Phone</strong></td><td class="text-success">' + escapeHtml(match.phone) + '</td></tr>';
                }
                html += '</table>';
                if (match.reasons && match.reasons.length > 0) {
                    html += '<p class="text-muted small">Match reasons: ' + match.reasons.join(', ') + '</p>';
                }
                html += '<a href="/app/contact/?contactid=' + match.contactid + '" target="_blank" class="btn btn-xs btn-outline-info">View Contact</a>';
                html += '</div>';
            }

            html += '</div>';

            $('#dupe-modal-body').html(html);
            $('#dupe-modal').modal('show');
        });
    }

    function setDupeAction(action) {
        console.log('[V3] Setting dupe action:', action, 'for row:', currentDupeRowId);

        // V3 ENDPOINT
        $.ajax({
            url: '/ajax/importv3/row_action.cfm',  // V3 ENDPOINT
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({
                job_id: state.jobId,
                row_id: currentDupeRowId,
                action: action
            }),
            success: function(response) {
                console.log('[V3] Row action response:', response);
                $('#dupe-modal').modal('hide');
                if (response.success) {
                    loadRows();
                } else {
                    showAlert('error', response.message);
                }
            }
        });
    }

    // ========================================
    // FINALIZE - V3 ENDPOINTS
    // ========================================

    function finalizeImport() {
        if (!confirm('Are you sure you want to import ' + (state.stats.ready || 0) + ' contacts?')) {
            return;
        }

        console.log('[V3] Finalizing import for job:', state.jobId);

        $('#btn-finalize').prop('disabled', true);
        $('#finalize-progress').show();

        // V3 ENDPOINT
        $.ajax({
            url: '/ajax/importv3/finalize.cfm',  // V3 ENDPOINT
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ job_id: state.jobId }),
            success: function(response) {
                console.log('[V3] Finalize response:', response);
                $('#finalize-progress').hide();

                if (response.success) {
                    showAlert('success', response.message || 'Import completed successfully!');
                    setTimeout(function() {
                        window.location.reload();
                    }, 1500);
                } else {
                    showAlert('error', response.message);
                    $('#btn-finalize').prop('disabled', false);
                }
            },
            error: function(xhr) {
                console.error('[V3] Finalize error:', xhr.responseText);
                showAlert('error', 'Import failed. Please try again.');
                $('#finalize-progress').hide();
                $('#btn-finalize').prop('disabled', false);
            }
        });
    }

    function previewImport() {
        console.log('[V3] Previewing import for job:', state.jobId);

        $('#btn-dry-run').prop('disabled', true);
        $('#dry-run-progress').show();

        // V3 ENDPOINT - preview_update
        $.ajax({
            url: '/ajax/importv3/preview_update.cfm',  // V3 ENDPOINT
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ job_id: state.jobId }),
            success: function(response) {
                console.log('[V3] Preview response:', response);
                $('#dry-run-progress').hide();
                $('#btn-dry-run').prop('disabled', false);

                if (response.success) {
                    showPreviewResults(response.data);
                } else {
                    showAlert('error', response.message || 'Preview failed');
                }
            },
            error: function(xhr) {
                console.error('[V3] Preview error:', xhr.responseText);
                showAlert('error', 'Preview failed. Please try again.');
                $('#dry-run-progress').hide();
                $('#btn-dry-run').prop('disabled', false);
            }
        });
    }

    function showPreviewResults(data) {
        var summary = data.summary || {};
        var warnings = data.warnings || [];
        var preview = data.preview || [];

        var html = '<div class="dry-run-results">';

        // Summary stats
        html += '<div class="dry-run-summary">';
        html += '<h5>Import Summary <span class="v3-badge" style="font-size:10px;">V3</span></h5>';
        html += '<ul class="list-unstyled">';
        html += '<li><strong>Will Import:</strong> ' + (summary.will_create || 0) + ' new contacts</li>';
        if (summary.will_update > 0) {
            html += '<li><strong>Will Update:</strong> ' + summary.will_update + ' existing contacts</li>';
        }
        if (summary.will_skip > 0) {
            html += '<li><strong>Will Skip:</strong> ' + summary.will_skip + ' rows</li>';
        }
        if (summary.problems > 0) {
            html += '<li class="text-danger"><strong>Problems:</strong> ' + summary.problems + ' rows have errors</li>';
        }
        if (summary.dupes_unresolved > 0) {
            html += '<li class="text-warning"><strong>Unresolved Duplicates:</strong> ' + summary.dupes_unresolved + ' rows</li>';
        }
        html += '</ul></div>';

        // Warnings
        if (warnings.length > 0) {
            html += '<div class="dry-run-warnings alert alert-warning">';
            html += '<strong>Warnings:</strong><ul>';
            for (var i = 0; i < warnings.length; i++) {
                html += '<li>' + escapeHtml(warnings[i]) + '</li>';
            }
            html += '</ul></div>';
        }

        // Preview (first 20)
        if (preview.length > 0) {
            html += '<div class="dry-run-preview">';
            html += '<h6>Preview (first ' + preview.length + ' contacts):</h6>';
            html += '<table class="table table-sm table-bordered"><thead><tr>';
            html += '<th>#</th><th>Name</th><th>Email</th><th>Company</th><th>Action</th>';
            html += '</tr></thead><tbody>';
            for (var j = 0; j < preview.length; j++) {
                var row = preview[j];
                html += '<tr>';
                html += '<td>' + row.row_num + '</td>';
                html += '<td>' + escapeHtml(row.name) + '</td>';
                html += '<td>' + escapeHtml(row.email) + '</td>';
                html += '<td>' + escapeHtml(row.company) + '</td>';
                html += '<td>' + escapeHtml(row.action) + '</td>';
                html += '</tr>';
            }
            html += '</tbody></table></div>';
        }

        html += '</div>';

        // Show in modal
        var modalHtml = '<div class="modal fade" id="dryRunModal" tabindex="-1">' +
            '<div class="modal-dialog modal-lg"><div class="modal-content">' +
            '<div class="modal-header" style="background: linear-gradient(135deg, #667eea22 0%, #764ba222 100%);">' +
            '<h5 class="modal-title">Import Preview <span class="v3-badge" style="font-size:10px;">V3</span></h5>' +
            '<button type="button" class="close" data-dismiss="modal">&times;</button></div>' +
            '<div class="modal-body">' + html + '</div>' +
            '<div class="modal-footer">' +
            '<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>';

        if ((summary.will_create || 0) + (summary.will_update || 0) > 0 && (summary.problems || 0) === 0 && (summary.dupes_unresolved || 0) === 0) {
            modalHtml += '<button type="button" class="btn btn-primary" id="btn-proceed-import" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border:none;">Proceed with Import</button>';
        }

        modalHtml += '</div></div></div></div>';

        // Remove existing modal if any
        $('#dryRunModal').remove();
        $('body').append(modalHtml);

        // Wire up proceed button
        $('#btn-proceed-import').click(function() {
            $('#dryRunModal').modal('hide');
            finalizeImport();
        });

        $('#dryRunModal').modal('show');
    }

    // ========================================
    // UTILITIES
    // ========================================

    function escapeHtml(text) {
        if (!text) return '';
        var div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    function formatFieldName(field) {
        return field
            .replace(/_/g, ' ')
            .replace(/([A-Z])/g, ' $1')
            .replace(/^./, function(str) { return str.toUpperCase(); });
    }

    function showAlert(type, message) {
        var alertClass = 'alert-danger';
        var icon = 'fe-alert-circle';

        if (type === 'success') {
            alertClass = 'alert-success';
            icon = 'fe-check-circle';
        } else if (type === 'warning') {
            alertClass = 'alert-warning';
            icon = 'fe-alert-triangle';
        }

        var html = '<div class="alert ' + alertClass + ' alert-dismissible fade show" role="alert">' +
            '<i class="' + icon + '"></i> ' + escapeHtml(message) +
            '<button type="button" class="close" data-dismiss="alert">&times;</button></div>';

        // Insert at top of page
        var container = $('.page-title-box').parent();
        container.prepend(html);

        // Auto-dismiss after 5 seconds
        setTimeout(function() {
            container.find('.alert').first().remove();
        }, 5000);
    }

})();
