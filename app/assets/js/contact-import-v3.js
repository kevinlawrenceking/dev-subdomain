/**
 * Contact Import V3 - JavaScript Controller
 * Handles file upload, parsing, review grid, and import finalization
 *
 * V3 ENDPOINTS - All calls go to /ajax/importv3/ namespace
 *
 * Phase 4.2: noConflict-safe - uses local $j alias, never relies on global $
 * Phase 4.3: Bounded wait for jQuery + init guard to prevent double initialization
 */

(function() {
    'use strict';

    // Phase 4.3: Guard flag to ensure initV3 runs exactly once
    var initialized = false;

    // Phase 4.3: Local jQuery alias - set after jQuery becomes available
    var $j = null;

    // Phase 4.3: Bounded wait for jQuery availability
    var maxWaitMs = 2000;
    var pollEveryMs = 50;
    var waited = 0;

    function showJQueryError() {
        var alertDiv = document.createElement('div');
        alertDiv.style.cssText = 'position:fixed;top:0;left:0;right:0;background:#dc3545;color:#fff;padding:15px;text-align:center;z-index:99999;font-family:sans-serif;';
        alertDiv.innerHTML = '<strong>Error:</strong> Contact Import V3 requires jQuery. Please ensure jQuery is loaded before this script.';
        if (document.body) {
            document.body.insertBefore(alertDiv, document.body.firstChild);
        } else {
            document.addEventListener('DOMContentLoaded', function() {
                document.body.insertBefore(alertDiv, document.body.firstChild);
            });
        }
        console.error('[V3] FATAL: jQuery not available after ' + maxWaitMs + 'ms. Contact Import V3 cannot initialize.');
    }

    function waitForJQuery() {
        if (typeof window.jQuery !== 'undefined') {
            // jQuery is available - set alias and initialize
            $j = window.jQuery;
            console.log('[V3] jQuery detected after ' + waited + 'ms');
            $j(document).ready(initV3);
            return;
        }

        waited += pollEveryMs;
        if (waited >= maxWaitMs) {
            // Timeout - show error once and stop
            showJQueryError();
            return;
        }

        // Poll again
        setTimeout(waitForJQuery, pollEveryMs);
    }

    // Start waiting for jQuery
    waitForJQuery();

    // Phase 4.3: Main initialization function - runs exactly once
    function initV3() {
        if (initialized) {
            console.log('[V3] initV3 called but already initialized - skipping');
            return;
        }
        initialized = true;

        console.log('[V3] Contact Import V3 JavaScript loaded');
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
    }

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
        birthday: { type: 'date', label: 'Next Birthday', group: 'dates' },
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

    // Note: Initialization moved to initV3() function (Phase 4.3)
    // initV3 is called via $j(document).ready after jQuery is detected

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
        $j('#upload-area').hide();
        $j('#upload-progress').show();

        // Upload - V3 ENDPOINT
        var formData = new FormData();
        formData.append('file', file);

        $j.ajax({
            url: '/ajax/importv3/upload.cfm?bypass=1',  // V3 ENDPOINT
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            xhr: function() {
                var xhr = new XMLHttpRequest();
                xhr.upload.addEventListener('progress', function(e) {
                    if (e.lengthComputable) {
                        var pct = (e.loaded / e.total) * 100;
                        $j('#upload-progress .progress-bar').css('width', pct + '%');
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
                    $j('#upload-area').show();
                    $j('#upload-progress').hide();
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
                $j('#upload-area').show();
                $j('#upload-progress').hide();
            }
        });
    }

    // ========================================
    // JOB ACTIONS - V3 ENDPOINTS
    // ========================================

    function initJobActions() {
        console.log('[V3] initJobActions called');
        // Parse button
        var parseBtn = $j('#btn-parse');
        console.log('[V3] Parse button found:', parseBtn.length > 0);
        parseBtn.click(function() {
            console.log('[V3] Parse button CLICKED!');
            parseFile();
        });

        // Confirm mapping button
        $j('#btn-confirm-mapping').click(function() {
            confirmMappings();
        });

        // Finalize button
        $j('#btn-finalize').click(function() {
            finalizeImport();
        });

        // Dry-run button (preview)
        $j('#btn-dry-run').click(function() {
            previewImport();
        });
    }

    function parseFile() {
        console.log('[V3] ========== PARSE STARTED ==========');
        console.log('[V3] state.jobId =', state.jobId);
        console.log('[V3] typeof state.jobId =', typeof state.jobId);

        if (!state.jobId || state.jobId <= 0) {
            console.error('[V3] ERROR: Invalid job ID!');
            showAlert('error', 'Invalid job ID. Please refresh the page.');
            return;
        }

        console.log('[V3] Sending request to /ajax/importv3/parse.cfm?bypass=1');

        $j('#btn-parse').prop('disabled', true);
        $j('#parse-progress').show();

        $j.ajax({
            url: '/ajax/importv3/parse.cfm?bypass=1',  // V3 ENDPOINT
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ job_id: state.jobId }),
            success: function(response) {
                console.log('[V3] ========== PARSE RESPONSE ==========');
                console.log('[V3] Full response:', JSON.stringify(response, null, 2));

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
                    $j('#btn-parse').prop('disabled', false);
                    $j('#parse-progress').hide();
                }
            },
            error: function(xhr, status, error) {
                console.error('[V3] ========== PARSE ERROR ==========');
                console.error('[V3] Status:', status);
                console.error('[V3] Error:', error);
                console.error('[V3] Response text:', xhr.responseText);

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
                $j('#btn-parse').prop('disabled', false);
                $j('#parse-progress').hide();
            }
        });
    }

    function loadColumnMappings() {
        console.log('[V3] Loading column mappings for job:', state.jobId);
        $j.get('/ajax/importv3/columns.cfm?bypass=1&job_id=' + state.jobId, function(response) {
            console.log('[V3] Columns response:', response);
            if (response.success) {
                renderColumnMappings(response.data.columns, response.data.available_fields);
            } else {
                $j('#mapping-container').html('<p class="text-danger">' + response.message + '</p>');
            }
        });
    }

    function renderColumnMappings(columns, availableFields) {
        // Helper: normalize a string for comparison (lowercase, strip non-alpha)
        function normalize(s) {
            return (s || '').toLowerCase().replace(/[^a-z0-9]/g, '');
        }

        // Smart defaults: map common shorthand source names to preferred fields
        var smartDefaults = {
            'email':    'email_business',
            'phone':    'phone_mobile',
            'address':  'address1'
        };

        var html = '<table class="table table-sm"><thead><tr><th>Source Column</th><th>Maps To</th></tr></thead><tbody>';

        columns.forEach(function(col) {
            // If backend didn't map, try exact match on source column name
            var effectiveMapping = col.mapped_field || '';
            if (!effectiveMapping && col.source_name) {
                var srcNorm = normalize(col.source_name);
                // 1) Check smart defaults first (e.g. "email" -> business email)
                if (smartDefaults[srcNorm]) {
                    effectiveMapping = smartDefaults[srcNorm];
                } else {
                    // 2) Fall back to normalized match against field key or display name
                    for (var i = 0; i < availableFields.length; i++) {
                        if (srcNorm === normalize(availableFields[i].field) || srcNorm === normalize(availableFields[i].display_name)) {
                            effectiveMapping = availableFields[i].field;
                            break;
                        }
                    }
                }
            }

            html += '<tr>';
            html += '<td><strong>' + escapeHtml(col.source_name || 'Column ' + (col.source_index + 1)) + '</strong></td>';
            html += '<td>';
            html += '<select class="form-control form-control-sm mapping-select" data-column-id="' + col.column_id + '">';
            html += '<option value="">(Do not import)</option>';

            availableFields.forEach(function(field) {
                var selected = field.field === effectiveMapping ? 'selected' : '';
                html += '<option value="' + field.field + '" ' + selected + '>' + escapeHtml(field.display_name) + '</option>';
            });

            html += '</select>';
            html += '</td>';
            html += '</tr>';
        });

        html += '</tbody></table>';
        $j('#mapping-container').html(html);
    }

    function confirmMappings() {
        console.log('[V3] ========== CONFIRM MAPPINGS ==========');
        console.log('[V3] Confirming mappings for job:', state.jobId);

        // Collect mappings
        var mappings = [];
        $j('.mapping-select').each(function() {
            mappings.push({
                column_id: parseInt($j(this).data('column-id')),
                field: $j(this).val()
            });
        });

        console.log('[V3] Mappings to send:', JSON.stringify(mappings));

        // Phase 7: Show spinner and disable button during recompute
        var $btn = $j('#btn-confirm-mapping');
        var originalHtml = $btn.html();
        $btn.prop('disabled', true).html('<i class="fe-loader fe-spin"></i> Processing...');

        var requestData = { job_id: state.jobId, mappings: mappings };
        console.log('[V3] Full request data:', JSON.stringify(requestData));

        // V3 uses recompute endpoint to apply mappings and validate
        $j.ajax({
            url: '/ajax/importv3/recompute.cfm?bypass=1',  // V3 ENDPOINT
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(requestData),
            timeout: 60000, // 60 second timeout
            success: function(response) {
                console.log('[V3] ========== RECOMPUTE RESPONSE ==========');
                console.log('[V3] Recompute response:', response);
                console.log('[V3] Response type:', typeof response);
                console.log('[V3] Response success:', response.success);
                if (response.success) {
                    console.log('[V3] Success! Reloading page...');
                    window.location.reload();
                } else {
                    console.log('[V3] Failed:', response.message);
                    showAlert('error', response.message || 'Failed to process');
                    $btn.prop('disabled', false).html(originalHtml);
                }
            },
            error: function(xhr, status, error) {
                console.error('[V3] ========== RECOMPUTE ERROR ==========');
                console.error('[V3] Status:', status);
                console.error('[V3] Error:', error);
                console.error('[V3] Response text:', xhr.responseText);
                console.error('[V3] Response status:', xhr.status);
                showAlert('error', 'Failed to process. Please try again. (' + status + ')');
                $btn.prop('disabled', false).html(originalHtml);
            },
            complete: function(xhr, status) {
                console.log('[V3] AJAX complete. Status:', status);
            }
        });
    }

    // ========================================
    // REVIEW GRID - V3 ENDPOINTS
    // ========================================

    function initReviewGrid() {
        // Tab clicks
        $j('#review-tabs .nav-link').click(function(e) {
            e.preventDefault();
            $j('#review-tabs .nav-link').removeClass('active');
            $j(this).addClass('active');
            state.currentFilter = $j(this).data('filter');
            state.currentPage = 1;
            loadRows();
        });

        // Check all
        $j('#check-all').change(function() {
            var checked = this.checked;
            $j('.row-checkbox').each(function() {
                this.checked = checked;
                var rowId = parseInt($j(this).data('row-id'));
                if (checked) {
                    state.selectedRows.add(rowId);
                } else {
                    state.selectedRows.delete(rowId);
                }
            });
            updateSelectedCount();
        });

        // Bulk actions
        $j('#bulk-ignore').click(function() {
            bulkAction('ignore');
        });

        $j('#bulk-import').click(function() {
            bulkAction('create');
        });
    }

    function loadRows() {
        console.log('[V3] Loading rows for job:', state.jobId, 'Filter:', state.currentFilter);

        // Phase 7: Show loading indicator
        $j('#review-tbody').html('<tr><td colspan="8" class="text-center p-4"><i class="fe-loader fe-spin"></i> Loading rows...</td></tr>');

        var url = '/ajax/importv3/rows.cfm?bypass=1&job_id=' + state.jobId +
            '&status=' + encodeURIComponent(state.currentFilter) +
            '&page=' + state.currentPage +
            '&limit=' + state.pageSize;

        $j.get(url, function(response) {
            console.log('[V3] Rows response:', response);
            // Log debug breadcrumbs if present (handle both cases - CF returns uppercase)
            var data = response.data || response.DATA || {};
            var debugTrail = data.debug || data.DEBUG;
            if (debugTrail) {
                console.log('[V3] Debug trail:', debugTrail.join(' -> '));
            }
            if (response.success) {
                // Handle both lowercase and uppercase keys (CF returns uppercase)
                var rows = data.rows || data.ROWS || [];
                var total = data.total || data.TOTAL || 0;
                var page = data.page || data.PAGE || 1;
                var totalPages = data.total_pages || data.TOTAL_PAGES || 1;
                renderRows(rows);
                renderPagination(total, page, totalPages);
                updateStats();
            } else {
                console.error('[V3] Load rows failed with code:', response.code);
                $j('#review-tbody').html('<tr><td colspan="8" class="text-center text-danger">' + escapeHtml(response.message) + '</td></tr>');
            }
        }).fail(function(xhr, status, error) {
            console.error('[V3] Load rows HTTP error:', xhr.status, status, error);
            $j('#review-tbody').html('<tr><td colspan="8" class="text-center text-danger">Failed to load rows. Please refresh the page.</td></tr>');
        });
    }

    // Helper to get value from object with case-insensitive key lookup
    function getVal(obj, key) {
        if (!obj) return '';
        return obj[key] || obj[key.toUpperCase()] || obj[key.toLowerCase()] || '';
    }

    function renderRows(rows) {
        if (!rows || rows.length === 0) {
            $j('#review-tbody').html('<tr><td colspan="8" class="text-center text-muted p-4">No rows found</td></tr>');
            return;
        }

        var html = '';
        rows.forEach(function(row) {
            var data = row.data || row.DATA || {};
            var validation = row.validation || row.VALIDATION || {};
            var rowId = row.row_id || row.ROW_ID;
            var rowNum = row.row_num || row.ROW_NUM;
            var status = row.status || row.STATUS;
            var bestMatchScore = row.best_match_score || row.BEST_MATCH_SCORE;
            var createdContactId = row.created_contactid || row.CREATED_CONTACTID;
            var errors = row.errors || row.ERRORS || [];
            var duplicates = row.duplicates || row.DUPLICATES || [];

            var firstName = getVal(data, 'first_name') || getVal(data, 'firstName');
            var lastName = getVal(data, 'last_name') || getVal(data, 'lastName');
            var fullName = getVal(data, 'contactFullName') || getVal(data, 'full_name');
            var name = fullName || ((firstName || '') + ' ' + (lastName || '')).trim() || '-';
            var email = getVal(data, 'email_business') || getVal(data, 'email_personal') || '-';
            var phone = getVal(data, 'phone_work') || getVal(data, 'phone_mobile') || getVal(data, 'phone_home') || '-';
            var company = getVal(data, 'company') || '-';

            // Check for field errors
            var emailClass = hasFieldError(validation, 'email_business') || hasFieldError(validation, 'email_personal') ? 'text-danger' : '';
            var phoneClass = hasFieldError(validation, 'phone_work') || hasFieldError(validation, 'phone_mobile') ? 'text-danger' : '';

            var rowClass = status === 'imported' ? 'table-light' : (status === 'ignored' ? 'table-light text-muted' : '');
            html += '<tr data-row-id="' + rowId + '" class="' + rowClass + '">';
            html += '<td><input type="checkbox" class="row-checkbox" data-row-id="' + rowId + '" ' + (status === 'imported' ? 'disabled' : '') + '></td>';
            html += '<td>' + rowNum + '</td>';
            html += '<td>' + escapeHtml(name) + '</td>';
            html += '<td class="' + emailClass + '">' + escapeHtml(email) + '</td>';
            html += '<td class="' + phoneClass + '">' + escapeHtml(phone) + '</td>';
            html += '<td>' + escapeHtml(company) + '</td>';
            html += '<td><span class="status-badge status-' + status + '">' + status + '</span></td>';
            html += '<td>';

            if (status === 'ready') {
                html += '<button class="btn btn-xs btn-outline-primary btn-edit" data-row-id="' + rowId + '" title="Edit"><i class="fe-edit"></i></button> ';
                html += '<button class="btn btn-xs btn-outline-secondary btn-exclude" data-row-id="' + rowId + '" title="Exclude from import"><i class="fe-x-circle"></i></button> ';
            } else if (status === 'problem') {
                html += '<button class="btn btn-xs btn-outline-primary btn-edit" data-row-id="' + rowId + '" title="Edit & fix"><i class="fe-edit"></i></button> ';
                html += '<button class="btn btn-xs btn-outline-secondary btn-exclude" data-row-id="' + rowId + '" title="Exclude from import"><i class="fe-x-circle"></i></button> ';
            } else if (status === 'dupe') {
                html += '<button class="btn btn-xs btn-outline-warning btn-resolve-dupe" data-row-id="' + rowId + '" title="Resolve duplicate"><i class="fe-users"></i></button> ';
            } else if (status === 'ignored') {
                html += '<button class="btn btn-xs btn-outline-success btn-restore" data-row-id="' + rowId + '" title="Include in import"><i class="fe-check-circle"></i></button> ';
            } else if (status === 'imported' && createdContactId) {
                html += '<a href="/app/contact/?contactid=' + createdContactId + '" class="btn btn-xs btn-outline-info" title="View contact"><i class="fe-eye"></i></a>';
            }

            html += '</td>';
            html += '</tr>';

            // Show validation errors
            if (status === 'problem' && errors && errors.length > 0) {
                html += '<tr class="bg-light"><td></td><td colspan="7">';
                html += '<small class="text-danger">';
                errors.forEach(function(err) {
                    var errField = err.field || err.FIELD || '';
                    var errMsg = err.message || err.MESSAGE || '';
                    html += '<i class="fe-alert-circle"></i> <strong>' + escapeHtml(errField) + ':</strong> ' + escapeHtml(errMsg) + '<br>';
                });
                html += '</small></td></tr>';
            }

            // Show duplicate info
            if (status === 'dupe' && duplicates && duplicates.length > 0) {
                html += '<tr class="bg-warning-light"><td></td><td colspan="7">';
                html += '<small class="text-warning"><i class="fe-alert-triangle"></i> ';
                var dupeName = duplicates[0].contactFullName || duplicates[0].CONTACTFULLNAME || duplicates[0].recordname || duplicates[0].RECORDNAME || 'Unknown';
                html += 'Possible duplicate of: <strong>' + escapeHtml(dupeName) + '</strong>';
                if (bestMatchScore) {
                    html += ' (Score: ' + bestMatchScore + ')';
                }
                html += '</small></td></tr>';
            }
        });

        $j('#review-tbody').html(html);

        // Bind row actions
        $j('.btn-edit').click(function() {
            editRow($j(this).data('row-id'));
        });

        $j('.btn-resolve-dupe').click(function() {
            resolveDupe($j(this).data('row-id'));
        });

        $j('.btn-exclude').click(function() {
            singleRowAction($j(this).data('row-id'), 'ignore');
        });

        $j('.btn-restore').click(function() {
            singleRowAction($j(this).data('row-id'), 'create');
        });

        $j('.row-checkbox').change(function() {
            var rowId = parseInt($j(this).data('row-id'));
            if (this.checked) {
                state.selectedRows.add(rowId);
            } else {
                state.selectedRows.delete(rowId);
            }
            updateSelectedCount();
        });
    }

    function hasFieldError(validation, field) {
        // Phase 7: Handle both object format {valid: bool, error: string} and simple boolean format
        if (!validation || !validation[field]) return false;
        var val = validation[field];
        // If it's an object with .valid property, check that
        if (typeof val === 'object' && val !== null && 'valid' in val) {
            return !val.valid;
        }
        // If it's a boolean, false means error
        if (typeof val === 'boolean') {
            return !val;
        }
        return false;
    }

    function renderPagination(total, page, pages) {
        var start = ((page - 1) * state.pageSize) + 1;
        var end = Math.min(page * state.pageSize, total);
        $j('#pagination-info').text('Showing ' + start + '-' + end + ' of ' + total);

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

        $j('#pagination-nav ul').html(html);
        $j('#pagination-nav .page-link').click(function(e) {
            e.preventDefault();
            var p = parseInt($j(this).data('page'));
            if (p && p !== state.currentPage) {
                state.currentPage = p;
                loadRows();
            }
        });
    }

    function updateSelectedCount() {
        $j('#selected-count').text(state.selectedRows.size + ' selected');
        if (state.selectedRows.size > 0) {
            $j('#bulk-actions').show();
        } else {
            $j('#bulk-actions').hide();
        }
    }

    function updateStats() {
        // V3 uses the rows endpoint with stats_only mode
        $j.get('/ajax/importv3/rows.cfm?bypass=1&job_id=' + state.jobId + '&stats_only=1', function(response) {
            console.log('[V3] Stats response:', response);
            // CF serializes keys uppercase: handle both cases
            var data = response.data || response.DATA || {};
            var stats = data.stats || data.STATS;
            if (response.success && stats) {
                state.stats = stats;
                $j('#stat-total').text(stats.total || 0);
                $j('#stat-ready').text(stats.ready || 0);
                $j('#stat-problem').text(stats.problem || 0);
                $j('#stat-dupe').text(stats.dupe || 0);
                $j('#stat-imported').text(stats.imported || 0);

                $j('#tab-all').text(stats.total || 0);
                $j('#tab-ready').text(stats.ready || 0);
                $j('#tab-problem').text(stats.problem || 0);
                $j('#tab-dupe').text(stats.dupe || 0);
                $j('#tab-ignored').text(stats.ignored || 0);
                $j('#tab-imported').text(stats.imported || 0);

                $j('#import-count').text(stats.ready || 0);

                // Show warning if no ready rows
                if ((stats.ready || 0) === 0) {
                    $j('#finalize-warning').show();
                    $j('#finalize-warning-text').text('No rows are ready for import. Please fix validation errors or resolve duplicates.');
                    $j('#btn-finalize').prop('disabled', true);
                } else {
                    $j('#finalize-warning').hide();
                    $j('#btn-finalize').prop('disabled', false);
                }
            }
        });
    }

    function bulkAction(action) {
        if (state.selectedRows.size === 0) return;
        console.log('[V3] Bulk action:', action, 'Rows:', Array.from(state.selectedRows));

        // Phase 7: Get CSRF token for row_action
        var csrfToken = $j('#csrf-token').val() || '';
        if (!csrfToken) {
            console.error('[V3] CSRF token not found for bulk action');
            showAlert('error', 'Security token missing. Please refresh the page.');
            return;
        }

        // Phase 7: Disable bulk action buttons during processing
        var $ignoreBtn = $j('#bulk-ignore');
        var $importBtn = $j('#bulk-import');
        $ignoreBtn.prop('disabled', true);
        $importBtn.prop('disabled', true);
        var actionText = action === 'ignore' ? 'Excluding...' : 'Including...';
        $j('#selected-count').text(actionText);

        $j.ajax({
            url: '/ajax/importv3/row_action.cfm?bypass=1',  // V3 ENDPOINT
            type: 'POST',
            contentType: 'application/json',
            headers: {
                'X-CSRF-Token': csrfToken  // Phase 7: Header CSRF (preferred)
            },
            data: JSON.stringify({
                job_id: state.jobId,
                row_ids: Array.from(state.selectedRows),
                action: action,
                csrf_token: csrfToken  // Body CSRF (fallback)
            }),
            success: function(response) {
                console.log('[V3] Bulk action response:', response);
                // Log debug breadcrumbs if present
                if (response.data && response.data.debug) {
                    console.log('[V3] Debug trail:', response.data.debug.join(' -> '));
                }
                if (response.success) {
                    state.selectedRows.clear();
                    updateSelectedCount();
                    loadRows();
                } else {
                    console.error('[V3] Bulk action failed with code:', response.code);
                    showAlert('error', response.message);
                    $ignoreBtn.prop('disabled', false);
                    $importBtn.prop('disabled', false);
                    updateSelectedCount();
                }
            },
            error: function(xhr, status, error) {
                console.error('[V3] Bulk action HTTP error:', xhr.status, status, error);
                var errorMsg = 'Action failed. Please try again.';
                try {
                    var errResponse = JSON.parse(xhr.responseText);
                    if (errResponse.message) errorMsg = errResponse.message;
                    if (errResponse.data && errResponse.data.debug) {
                        console.error('[V3] Debug trail:', errResponse.data.debug.join(' -> '));
                    }
                } catch (e) {}
                showAlert('error', errorMsg);
                $ignoreBtn.prop('disabled', false);
                $importBtn.prop('disabled', false);
                updateSelectedCount();
            }
        });
    }

    function singleRowAction(rowId, action) {
        console.log('[V3] Single row action:', action, 'Row:', rowId);

        var csrfToken = $j('#csrf-token').val() || '';
        if (!csrfToken) {
            showAlert('error', 'Security token missing. Please refresh the page.');
            return;
        }

        $j.ajax({
            url: '/ajax/importv3/row_action.cfm?bypass=1',
            type: 'POST',
            contentType: 'application/json',
            headers: { 'X-CSRF-Token': csrfToken },
            data: JSON.stringify({
                job_id: state.jobId,
                row_id: rowId,
                action: action,
                csrf_token: csrfToken
            }),
            success: function(response) {
                console.log('[V3] Row action response:', response);
                if (response.success) {
                    loadRows();
                } else {
                    showAlert('error', response.message);
                }
            },
            error: function(xhr) {
                var errorMsg = 'Action failed. Please try again.';
                try {
                    var errResponse = JSON.parse(xhr.responseText);
                    if (errResponse.message) errorMsg = errResponse.message;
                } catch (e) {}
                showAlert('error', errorMsg);
            }
        });
    }

    // ========================================
    // MODALS - V3 ENDPOINTS
    // ========================================

    function initModals() {
        // Edit save
        $j('#edit-save').click(function() {
            saveEdit();
        });

        // Dupe actions
        $j('#dupe-skip').click(function() {
            setDupeAction('ignore');
        });
        $j('#dupe-update').click(function() {
            setDupeAction('update');
        });
        $j('#dupe-import-new').click(function() {
            setDupeAction('create');
        });
    }

    var currentEditRowId = 0;
    var currentEditData = {};

    function editRow(rowId) {
        console.log('[V3] Editing row:', rowId);
        currentEditRowId = rowId;

        // Fetch single row detail - V3 ENDPOINT
        $j.get('/ajax/importv3/row.cfm?bypass=1&job_id=' + state.jobId + '&row_id=' + rowId, function(response) {
            console.log('[V3] Row detail response:', response);
            // ColdFusion serializes struct keys uppercase — handle both
            var rowData = response.data.row || response.data.ROW;
            if (response.success && rowData) {
                renderEditModal(rowData);
            } else {
                showAlert('error', 'Could not find row data');
            }
        });
    }

    function renderEditModal(row) {
        // Normalize server keys (first_name -> firstName, contact_type -> contactType)
        // to match fieldDefinitions/fieldGroups camelCase keys
        var keyMap = { first_name: 'firstName', last_name: 'lastName', contact_type: 'contactType', contact_full_name: 'contactFullName' };
        function normalizeKeys(obj) {
            var out = {};
            for (var k in obj) {
                if (obj.hasOwnProperty(k)) {
                    out[keyMap[k] || k] = obj[k];
                }
            }
            return out;
        }
        currentEditData = normalizeKeys(row.data || {});
        var validation = normalizeKeys(row.validation || {});

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

        // Build error lookup from row.errors array (field -> message)
        var errorLookup = {};
        (row.errors || []).forEach(function(e) {
            var f = keyMap[e.field] || e.field;
            errorLookup[f] = e.message;
        });

        var html = '<form id="edit-form">';

        // Only show fields that have data or errors
        var fieldsWithData = Object.keys(currentEditData).filter(function(k) {
            return currentEditData[k] !== '' && currentEditData[k] !== null;
        });
        var fieldsWithErrors = Object.keys(validation).filter(function(k) {
            // validation[k] is boolean (true=valid, false=invalid) or object with .valid
            var v = validation[k];
            if (typeof v === 'boolean') return !v;
            return v && !v.valid;
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
                // validation[field] can be boolean (true=valid) or object with .valid/.error
                var v = validation[field];
                var error = '';
                var warning = '';
                if (typeof v === 'boolean') {
                    if (!v) error = errorLookup[field] || 'Invalid value';
                } else if (v && !v.valid) {
                    error = v.error || '';
                    warning = v.warning || '';
                }
                // For date fields, suppress stale error if current value is a valid date
                if (error && fieldDef.type === 'date' && val && !isNaN(new Date(val).getTime())) {
                    error = '';
                }
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

        $j('#edit-modal-body').html(html);

        // Initialize phone formatters
        initializePhoneFormatters();

        bsModal('#edit-modal', 'show');
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
        $j('.phone-input').on('input', function() {
            var val = $j(this).val().replace(/\D/g, '');
            if (val.length >= 10) {
                val = '(' + val.substring(0, 3) + ') ' + val.substring(3, 6) + '-' + val.substring(6, 10);
            }
            $j(this).val(val);
        });
    }

    function saveEdit() {
        // Reverse map camelCase form names back to underscore for the server
        var reverseKeyMap = { firstName: 'first_name', lastName: 'last_name', contactType: 'contact_type', contactFullName: 'contact_full_name' };
        var data = {};

        $j('#edit-form input, #edit-form select, #edit-form textarea').each(function() {
            var name = $j(this).attr('name');
            if (name) {
                data[reverseKeyMap[name] || name] = $j(this).val();
            }
        });

        console.log('[V3] Saving edit for row:', currentEditRowId, 'Data:', data);

        // Phase 7: Get CSRF token for fact_update
        var csrfToken = $j('#csrf-token').val() || '';
        if (!csrfToken) {
            console.error('[V3] CSRF token not found for fact_update');
            showAlert('error', 'Security token missing. Please refresh the page.');
            return;
        }

        var $btn = $j('#edit-save');
        $btn.prop('disabled', true).html('<i class="fe-loader fe-spin"></i> Saving...');

        // V3 ENDPOINT - fact_update for individual field updates
        $j.ajax({
            url: '/ajax/importv3/fact_update.cfm?bypass=1',  // V3 ENDPOINT
            type: 'POST',
            contentType: 'application/json',
            headers: {
                'X-CSRF-Token': csrfToken  // Phase 7: Header CSRF (preferred)
            },
            data: JSON.stringify({
                job_id: state.jobId,
                row_id: currentEditRowId,
                fields: data,
                csrf_token: csrfToken  // Body CSRF (fallback)
            }),
            success: function(response) {
                console.log('[V3] Save response:', response);
                // Log debug breadcrumbs if present
                if (response.data && response.data.debug) {
                    console.log('[V3] Debug trail:', response.data.debug.join(' -> '));
                }
                $btn.prop('disabled', false).html('<i class="fe-check"></i> Save Changes');
                if (response.success) {
                    bsModal('#edit-modal', 'hide');
                    showAlert('success', 'Row updated and revalidated');
                    loadRows();
                } else {
                    console.error('[V3] Fact update failed with code:', response.code);
                    showAlert('error', response.message || 'Validation failed');
                }
            },
            error: function(xhr, status, error) {
                console.error('[V3] Save error:', xhr.status, status, error);
                console.error('[V3] Response text:', xhr.responseText);
                var errorMsg = 'Failed to save. Please try again.';
                try {
                    var errResponse = JSON.parse(xhr.responseText);
                    if (errResponse.message) errorMsg = errResponse.message;
                    if (errResponse.data && errResponse.data.debug) {
                        console.error('[V3] Debug trail:', errResponse.data.debug.join(' -> '));
                    }
                } catch (e) {}
                $btn.prop('disabled', false).html('<i class="fe-check"></i> Save Changes');
                showAlert('error', errorMsg);
            }
        });
    }

    var currentDupeRowId = 0;

    function resolveDupe(rowId) {
        console.log('[V3] Resolving duplicate for row:', rowId);
        currentDupeRowId = rowId;

        // V3 ENDPOINT
        $j.get('/ajax/importv3/row.cfm?bypass=1&job_id=' + state.jobId + '&row_id=' + rowId, function(response) {
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

            $j('#dupe-modal-body').html(html);
            bsModal('#dupe-modal', 'show');
        });
    }

    function setDupeAction(action) {
        console.log('[V3] Setting dupe action:', action, 'for row:', currentDupeRowId);

        // Phase 7: Get CSRF token for row_action
        var csrfToken = $j('#csrf-token').val() || '';
        if (!csrfToken) {
            console.error('[V3] CSRF token not found for dupe action');
            showAlert('error', 'Security token missing. Please refresh the page.');
            return;
        }

        // V3 ENDPOINT
        $j.ajax({
            url: '/ajax/importv3/row_action.cfm?bypass=1',  // V3 ENDPOINT
            type: 'POST',
            contentType: 'application/json',
            headers: {
                'X-CSRF-Token': csrfToken  // Phase 7: Header CSRF (preferred)
            },
            data: JSON.stringify({
                job_id: state.jobId,
                row_id: currentDupeRowId,
                action: action,
                csrf_token: csrfToken  // Body CSRF (fallback)
            }),
            success: function(response) {
                console.log('[V3] Row action response:', response);
                // Log debug breadcrumbs if present
                if (response.data && response.data.debug) {
                    console.log('[V3] Debug trail:', response.data.debug.join(' -> '));
                }
                bsModal('#dupe-modal', 'hide');
                if (response.success) {
                    loadRows();
                } else {
                    console.error('[V3] Dupe action failed with code:', response.code);
                    showAlert('error', response.message);
                }
            },
            error: function(xhr, status, error) {
                console.error('[V3] Dupe action HTTP error:', xhr.status, status, error);
                var errorMsg = 'Action failed. Please try again.';
                try {
                    var errResponse = JSON.parse(xhr.responseText);
                    if (errResponse.message) errorMsg = errResponse.message;
                    if (errResponse.data && errResponse.data.debug) {
                        console.error('[V3] Debug trail:', errResponse.data.debug.join(' -> '));
                    }
                } catch (e) {}
                bsModal('#dupe-modal', 'hide');
                showAlert('error', errorMsg);
            }
        });
    }

    // ========================================
    // FINALIZE - V3 ENDPOINTS
    // ========================================

    function finalizeImport() {
        var readyCount = state.stats.ready || 0;
        if (!confirm('Are you sure you want to import ' + readyCount + ' contacts?')) {
            return;
        }

        console.log('[V3] Finalizing import for job:', state.jobId);

        // Get CSRF token from hidden input
        var csrfToken = $j('#csrf-token').val() || '';
        if (!csrfToken) {
            console.error('[V3] CSRF token not found in #csrf-token input');
            showAlert('error', 'Security token missing. Please refresh the page and try again.');
            return;
        }

        // Phase 7: Enhanced progress UI with timing message for large imports
        var $btn = $j('#btn-finalize');
        var $progress = $j('#finalize-progress');
        $btn.prop('disabled', true).html('<i class="fe-loader fe-spin"></i> Importing...');
        $progress.show();

        // Show timing message for large imports (over 100 rows)
        if (readyCount > 100) {
            showAlert('info', 'Importing ' + readyCount + ' contacts. This may take a moment...');
        }

        // Phase 5.2: V3 ENDPOINT - send csrf_token in BOTH header AND body (belt+suspenders)
        $j.ajax({
            url: '/ajax/importv3/finalize.cfm?bypass=1',  // V3 ENDPOINT - bypass=1 required
            type: 'POST',
            contentType: 'application/json',
            headers: {
                'X-CSRF-Token': csrfToken  // Phase 5.2: Header CSRF (preferred)
            },
            data: JSON.stringify({
                job_id: state.jobId,
                csrf_token: csrfToken  // Body CSRF (fallback)
            }),
            success: function(response) {
                console.log('[V3] Finalize response:', response);
                // Log debug breadcrumbs if present
                if (response.data && response.data.debug) {
                    console.log('[V3] Debug trail:', response.data.debug.join(' -> '));
                }
                $j('#finalize-progress').hide();

                if (response.success) {
                    showAlert('success', response.message || 'Import completed successfully!');
                    setTimeout(function() {
                        window.location.reload();
                    }, 1500);
                } else {
                    // Log error code to console for debugging
                    console.error('[V3] Finalize failed with code:', response.code);
                    showAlert('error', response.message || 'Import failed');
                    $j('#btn-finalize').prop('disabled', false);
                }
            },
            error: function(xhr, status, error) {
                console.error('[V3] Finalize HTTP error:', xhr.status, status, error);
                console.error('[V3] Response text:', xhr.responseText);

                // Phase 5.2: Improved error handling - parse JSON response if available
                var errorMsg = 'Import failed. Please try again.';
                var errorCode = '';
                var debugTrail = [];

                try {
                    var errResponse = JSON.parse(xhr.responseText);
                    if (errResponse.message) {
                        errorMsg = errResponse.message;
                    }
                    if (errResponse.code) {
                        errorCode = errResponse.code;
                        console.error('[V3] Error code:', errorCode);
                    }
                    if (errResponse.data && errResponse.data.debug) {
                        debugTrail = errResponse.data.debug;
                        console.error('[V3] Debug trail:', debugTrail.join(' -> '));
                    }
                    if (errResponse.data && errResponse.data.last_step) {
                        console.error('[V3] Last successful step:', errResponse.data.last_step);
                    }
                } catch (e) {
                    console.error('[V3] Could not parse error response as JSON');
                }

                showAlert('error', errorMsg);
                $j('#finalize-progress').hide();
                $j('#btn-finalize').prop('disabled', false);
            }
        });
    }

    function previewImport() {
        console.log('[V3] Previewing import for job:', state.jobId);

        $j('#btn-dry-run').prop('disabled', true);
        $j('#dry-run-progress').show();

        // V3 ENDPOINT - preview_update
        $j.ajax({
            url: '/ajax/importv3/preview_update.cfm?bypass=1',  // V3 ENDPOINT
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ job_id: state.jobId }),
            success: function(response) {
                console.log('[V3] Preview response:', response);
                $j('#dry-run-progress').hide();
                $j('#btn-dry-run').prop('disabled', false);

                if (response.success) {
                    showPreviewResults(response.data);
                } else {
                    showAlert('error', response.message || 'Preview failed');
                }
            },
            error: function(xhr) {
                console.error('[V3] Preview error:', xhr.responseText);
                showAlert('error', 'Preview failed. Please try again.');
                $j('#dry-run-progress').hide();
                $j('#btn-dry-run').prop('disabled', false);
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
        html += '<h5>Import Summary</h5>';
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
            '<div class="modal-header" style="background: rgba(64,110,142,0.1);">' +
            '<h5 class="modal-title">Import Preview</h5>' +
            '<button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>' +
            '<div class="modal-body">' + html + '</div>' +
            '<div class="modal-footer">' +
            '<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>';

        if ((summary.will_create || 0) + (summary.will_update || 0) > 0 && (summary.problems || 0) === 0 && (summary.dupes_unresolved || 0) === 0) {
            modalHtml += '<button type="button" class="btn btn-primary" id="btn-proceed-import" style="background: linear-gradient(135deg, var(--ct-link-color), var(--ct-link-hover-color)); border:none;">Proceed with Import</button>';
        }

        modalHtml += '</div></div></div></div>';

        // Remove existing modal if any
        $j('#dryRunModal').remove();
        $j('body').append(modalHtml);

        // Wire up proceed button
        $j('#btn-proceed-import').click(function() {
            bsModal('#dryRunModal', 'hide');
            finalizeImport();
        });

        bsModal('#dryRunModal', 'show');
    }

    // ========================================
    // UTILITIES
    // ========================================

    // Bootstrap 5 modal helper (BS5 dropped jQuery .modal() plugin)
    function bsModal(selector, action) {
        var el = document.querySelector(selector);
        if (!el) return;
        var instance = bootstrap.Modal.getInstance(el) || new bootstrap.Modal(el);
        if (action === 'show') instance.show();
        else if (action === 'hide') instance.hide();
    }

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
        var colors = { success: {bg:'#d1e7dd',border:'#badbcc',text:'#0f5132'},
                       warning: {bg:'#fff3cd',border:'#ffecb5',text:'#664d03'},
                       info:    {bg:'#cff4fc',border:'#b6effb',text:'#055160'},
                       error:   {bg:'#f8d7da',border:'#f5c2c7',text:'#842029'} };
        var c = colors[type] || colors.error;
        var icons = { success:'fe-check-circle', warning:'fe-alert-triangle', info:'fe-info', error:'fe-alert-circle' };
        var icon = icons[type] || icons.error;

        // Ensure toast container exists
        if (!document.getElementById('v3-toast-container')) {
            $j('body').append('<div id="v3-toast-container" style="position:fixed;top:20px;right:20px;z-index:99999;max-width:420px;"></div>');
        }

        var id = 'v3-alert-' + Date.now();
        var html = '<div id="' + id + '" style="background:' + c.bg + ';border:1px solid ' + c.border + ';color:' + c.text + ';' +
            'padding:12px 40px 12px 16px;border-radius:6px;margin-bottom:10px;position:relative;' +
            'box-shadow:0 4px 12px rgba(0,0,0,0.15);font-size:14px;opacity:0;transition:opacity 0.3s ease;">' +
            '<i class="' + icon + '" style="margin-right:8px;"></i>' + escapeHtml(message) +
            '<span style="position:absolute;top:8px;right:12px;cursor:pointer;font-size:18px;line-height:1;opacity:0.6;" ' +
            'onclick="this.parentElement.remove()">&times;</span></div>';

        $j('#v3-toast-container').append(html);

        // Fade in
        setTimeout(function() { document.getElementById(id).style.opacity = '1'; }, 10);

        // Auto-dismiss after 5 seconds
        setTimeout(function() {
            var el = document.getElementById(id);
            if (el) { el.style.opacity = '0'; setTimeout(function() { if (el.parentNode) el.remove(); }, 300); }
        }, 5000);
    }

})();
