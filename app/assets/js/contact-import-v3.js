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
        initStatusControls();

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

            if (status === 'uploaded' || status === 'created' || status === 'pending') {
                // Auto-parse: no button needed, just start parsing immediately
                parseFile();
            } else if (status === 'parsed' || status === 'mapping') {
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
        stats: {},
        searchQuery: ''
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

        // Validate file size. Must match the ColdFusion server post limit
        // (20 MB). A larger client cap lets 20-50MB files through to a hard
        // server-side "Post Size exceeds the maximum limit 20 MB" error
        // instead of this friendly message -- the cause of the logged failures.
        if (file.size > 20971520) {
            showAlert('error', 'File too large. Maximum size is 20MB.');
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
                if (cfGet(response, 'success')) {
                    // Extract job_id from response.data.job
                    var rData = cfGet(response, 'data') || {};
                    var job = cfGet(rData, 'job') || {};
                    var jobId = cfGet(job, 'job_id') || 0;

                    // Check if this is a duplicate file (V3 uses code field)
                    if (cfGet(response, 'code') === 'DUPLICATE_FILE') {
                        var dupeName = cfGet(job, 'source_filename') || 'this file';
                        var dupeStatus = cfGet(job, 'status') || 'unknown';
                        console.log('[V3] Duplicate file detected:', dupeName, 'existing job status:', dupeStatus);
                        $j('#upload-progress').hide();
                        $j('#upload-area').show();
                        showAlert('warning',
                            'This file (<strong>' + escapeHtml(dupeName) + '</strong>) was already uploaded.' +
                            ' The existing job is in <strong>' + escapeHtml(dupeStatus) + '</strong> status.' +
                            ' <a href="/app/contacts-import-v3/?job_id=' + jobId + '" class="alert-link">Open existing job</a>'
                        );
                        return;
                    }

                    if (!jobId) {
                        console.error('[V3] Could not extract job_id from upload response:', response);
                        showAlert('error', 'Upload succeeded but no job ID was returned.');
                        $j('#upload-area').show();
                        $j('#upload-progress').hide();
                        return;
                    }

                    // Redirect to V3 job page
                    window.location.href = '/app/contacts-import-v3/?job_id=' + jobId;
                } else {
                    var errMsg = cfGet(response, 'message') || 'Upload failed';
                    showAlert('error', errMsg);
                    $j('#upload-area').show();
                    $j('#upload-progress').hide();
                }
            },
            error: function(xhr, status, error) {
                console.error('[V3] Upload error:', error, xhr.responseText);
                showErrorWithDebug(xhr, 'Upload failed.');
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

        // Export problems as CSV
        $j('#btn-export-problems').click(function() {
            var $btn = $j(this);
            $btn.prop('disabled', true).html('<i class="fe-loader fe-spin"></i> Exporting...');
            // Fetch all problem rows (up to 10000)
            $j.get('/ajax/importv3/rows.cfm?bypass=1&job_id=' + state.jobId + '&status=problem&page=1&limit=10000', function(response) {
                $btn.prop('disabled', false).html('<i class="fe-download"></i> Export Problems');
                if (!response.success) {
                    showAlert('error', 'Could not fetch problem rows');
                    return;
                }
                var data = response.data || response.DATA || {};
                var rows = data.rows || data.ROWS || [];
                if (rows.length === 0) {
                    showAlert('info', 'No problem rows to export');
                    return;
                }
                // Build CSV
                var csvRows = [['Row #', 'Name', 'Email', 'Phone', 'Company', 'Error Field', 'Error Message'].join(',')];
                rows.forEach(function(row) {
                    var d = row.data || row.DATA || {};
                    var name = getVal(d, 'contactFullName') || ((getVal(d, 'first_name') || getVal(d, 'firstName') || '') + ' ' + (getVal(d, 'last_name') || getVal(d, 'lastName') || '')).trim();
                    var email = getVal(d, 'email_business') || getVal(d, 'email_personal') || '';
                    var phone = getVal(d, 'phone_work') || getVal(d, 'phone_mobile') || '';
                    var company = getVal(d, 'company') || '';
                    var errors = row.errors || row.ERRORS || [];
                    if (errors.length === 0) {
                        csvRows.push([row.row_num || row.ROW_NUM, csvEscape(name), csvEscape(email), csvEscape(phone), csvEscape(company), '', ''].join(','));
                    } else {
                        errors.forEach(function(err) {
                            csvRows.push([row.row_num || row.ROW_NUM, csvEscape(name), csvEscape(email), csvEscape(phone), csvEscape(company), csvEscape(err.field || err.FIELD || ''), csvEscape(err.message || err.MESSAGE || '')].join(','));
                        });
                    }
                });
                var csvContent = csvRows.join('\n');
                var blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
                var link = document.createElement('a');
                link.href = URL.createObjectURL(blob);
                link.download = 'import_problems_job_' + state.jobId + '.csv';
                link.click();
                showAlert('success', 'Exported ' + rows.length + ' problem rows');
            }).fail(function() {
                $btn.prop('disabled', false).html('<i class="fe-download"></i> Export Problems');
                showAlert('error', 'Export failed');
            });
        });

        // Refresh validation: re-run recompute
        $j('#btn-refresh-validation').click(function() {
            var $btn = $j(this);
            var originalHtml = $btn.html();
            $btn.prop('disabled', true).html('<i class="fe-loader fe-spin"></i> Refreshing...');
            $j.ajax({
                url: '/ajax/importv3/recompute.cfm?bypass=1',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ job_id: state.jobId }),
                timeout: 120000,
                success: function(response) {
                    $btn.prop('disabled', false).html(originalHtml);
                    if (cfGet(response, 'success')) {
                        showAlert('success', 'Validation refreshed. Reloading...');
                        setTimeout(function() { window.location.reload(); }, 800);
                    } else {
                        showAlert('error', cfGet(response, 'message') || 'Refresh failed');
                    }
                },
                error: function(xhr) {
                    $btn.prop('disabled', false).html(originalHtml);
                    showErrorWithDebug(xhr, 'Refresh failed.');
                }
            });
        });

        // Stale lock: Force unlock stuck job
        $j('#btn-force-unlock').click(function() {
            var jobId = $j(this).data('job-id');
            if (confirm('This will reset the job back to reviewing status so you can continue working with it. Proceed?')) {
                changeJobStatus(jobId, 'reviewing');
            }
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

                if (cfGet(response, 'success')) {
                    var respData = cfGet(response, 'data') || {};
                    var isAutoMapped = cfGet(respData, 'auto_mapped');
                    if (isAutoMapped) {
                        // VCF: columns are auto-mapped, trigger recompute then reload to review grid
                        console.log('[V3] VCF auto-mapped, triggering recompute...');
                        triggerAutoRecompute();
                    } else {
                        console.log('[V3] Parse successful, reloading page...');
                        // Reload page to show mapping step
                        window.location.reload();
                    }
                } else {
                    var parseMsg = cfGet(response, 'message') || 'Parsing failed';
                    console.log('[V3] Parse failed:', parseMsg);
                    showAlert('error', parseMsg);
                    $j('#parse-progress').hide();
                }
            },
            error: function(xhr, status, error) {
                console.error('[V3] ========== PARSE ERROR ==========');
                console.error('[V3] Status:', status);
                console.error('[V3] Error:', error);
                console.error('[V3] Response text:', xhr.responseText);

                // Try to parse debug from error response
                showErrorWithDebug(xhr, 'Parsing failed.');
                $j('#parse-progress').hide();
            }
        });
    }

    // VCF auto-recompute: after VCF parse with auto-mapped columns, trigger recompute
    // so rows get validated and job transitions to "reviewing" status
    function triggerAutoRecompute() {
        console.log('[V3] ========== AUTO RECOMPUTE (VCF) ==========');
        $j('#parse-progress').show();

        $j.ajax({
            url: '/ajax/importv3/recompute.cfm?bypass=1',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ job_id: state.jobId }),
            timeout: 120000,
            success: function(response) {
                console.log('[V3] Auto-recompute response:', response);
                window.location.reload();
            },
            error: function(xhr, status, error) {
                console.error('[V3] Auto-recompute failed:', error);
                // Reload anyway - user can trigger recompute manually via column mapping
                window.location.reload();
            }
        });
    }

    // Helper: get property from object handling ColdFusion uppercase key serialization
    function cfGet(obj, key) {
        if (!obj) return undefined;
        if (obj[key] !== undefined) return obj[key];
        if (obj[key.toUpperCase()] !== undefined) return obj[key.toUpperCase()];
        return undefined;
    }

    function loadColumnMappings() {
        console.log('[V3] ========== LOAD COLUMN MAPPINGS ==========');
        console.log('[V3] Loading column mappings for job:', state.jobId);
        $j.get('/ajax/importv3/columns.cfm?bypass=1&job_id=' + state.jobId, function(response) {
            console.log('[V3] Columns response:', response);
            var success = cfGet(response, 'success');
            var data = cfGet(response, 'data') || {};
            if (success) {
                var columns = cfGet(data, 'columns') || [];
                var availFields = cfGet(data, 'available_fields') || [];
                renderColumnMappings(columns, availFields);
            } else {
                var msg = cfGet(response, 'message') || 'Unknown error';
                $j('#mapping-container').html('<p class="text-danger">' + msg + '</p>');
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
            'address':  'address1',
            'tag':      'tags',
            'tag1':     'tags',
            'tag2':     'tags',
            'category': 'tags',
            'postalcode': 'zip',
            'zipcode':  'zip',
            'streetaddress': 'address1',
            'jobtitle': 'title',
            'meetingdate': 'relationship_start',
            'relationshipsystem': 'relationship_system'
        };

        var html = '<table class="table table-sm" style="table-layout:fixed;width:100%;"><thead><tr><th style="width:150px;">Source Column</th><th>Sample Values</th><th style="width:200px;">Maps To</th></tr></thead><tbody>';

        columns.forEach(function(col) {
            var colId = cfGet(col, 'column_id');
            var sourceName = cfGet(col, 'source_name') || '';
            var sourceIndex = cfGet(col, 'source_column_index');
            var mappedField = cfGet(col, 'mapped_field') || cfGet(col, 'target_key') || '';

            // If backend didn't map, try exact match on source column name
            var effectiveMapping = mappedField;
            if (!effectiveMapping && sourceName) {
                var srcNorm = normalize(sourceName);
                // 1) Check smart defaults first (e.g. "email" -> business email)
                if (smartDefaults[srcNorm]) {
                    effectiveMapping = smartDefaults[srcNorm];
                } else {
                    // 2) Fall back to normalized match against field key or display name
                    for (var i = 0; i < availableFields.length; i++) {
                        var fKey = cfGet(availableFields[i], 'field') || '';
                        var fName = cfGet(availableFields[i], 'display_name') || '';
                        if (srcNorm === normalize(fKey) || srcNorm === normalize(fName)) {
                            effectiveMapping = fKey;
                            break;
                        }
                    }
                }
            }

            // Build sample values display
            var samples = cfGet(col, 'sample_values') || [];
            var sampleHtml = '';
            if (samples.length > 0) {
                var shown = samples.slice(0, 3);
                sampleHtml = shown.map(function(s) { return '<span class="badge bg-light text-dark me-1" style="font-weight:normal;font-size:11px;">' + escapeHtml(s) + '</span>'; }).join('');
                if (samples.length > 3) {
                    sampleHtml += '<span class="text-muted small">+' + (samples.length - 3) + ' more</span>';
                }
            } else {
                sampleHtml = '<span class="text-muted small">(no data)</span>';
            }

            html += '<tr>';
            html += '<td><strong>' + escapeHtml(sourceName || 'Column ' + ((sourceIndex || 0) + 1)) + '</strong></td>';
            html += '<td style="max-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">' + sampleHtml + '</td>';
            html += '<td>';
            html += '<select class="form-control form-control-sm mapping-select" data-column-id="' + colId + '">';
            html += '<option value="">(Do not import)</option>';

            availableFields.forEach(function(field) {
                var fKey = cfGet(field, 'field') || '';
                var fName = cfGet(field, 'display_name') || '';
                var selected = fKey === effectiveMapping ? 'selected' : '';
                html += '<option value="' + fKey + '" ' + selected + '>' + escapeHtml(fName) + '</option>';
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
                var rSuccess = cfGet(response, 'success');
                console.log('[V3] Response success:', rSuccess);
                if (rSuccess) {
                    console.log('[V3] Success! Reloading page...');
                    window.location.reload();
                } else {
                    var rMsg = cfGet(response, 'message') || 'Failed to process';
                    console.log('[V3] Failed:', rMsg);
                    showAlert('error', rMsg);
                    $btn.prop('disabled', false).html(originalHtml);
                }
            },
            error: function(xhr, status, error) {
                console.error('[V3] ========== RECOMPUTE ERROR ==========');
                console.error('[V3] Status:', status, 'HTTP:', xhr.status);
                showErrorWithDebug(xhr, 'Failed to process mappings.');
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
        // Search input with debounce
        var searchTimer = null;
        $j('#row-search').on('input', function() {
            var val = $j(this).val().trim();
            clearTimeout(searchTimer);
            $j('#row-search-clear').toggle(val.length > 0);
            searchTimer = setTimeout(function() {
                state.searchQuery = val;
                state.currentPage = 1;
                loadRows();
            }, 350);
        });

        $j('#row-search-clear').click(function() {
            $j('#row-search').val('');
            $j(this).hide();
            state.searchQuery = '';
            state.currentPage = 1;
            loadRows();
        });

        // Tab clicks
        $j('#review-tabs .nav-link').click(function(e) {
            e.preventDefault();
            $j('#review-tabs .nav-link').removeClass('active');
            $j(this).addClass('active');
            state.currentFilter = $j(this).data('filter');
            state.currentPage = 1;
            loadRows();
        });

        // Wizard navigation: Step 3 -> Step 4
        $j('#btn-goto-finalize').click(function() {
            $j('#step-review').hide();
            $j('#step-finalize').show();
            updateStepper(4);
            window.scrollTo(0, 0);
        });

        // Wizard navigation: Step 4 -> Step 3
        $j('#btn-back-to-review').click(function() {
            $j('#step-finalize').hide();
            $j('#step-review').show();
            updateStepper(3);
            window.scrollTo(0, 0);
        });
    }

    function loadRows() {
        console.log('[V3] Loading rows for job:', state.jobId, 'Filter:', state.currentFilter);

        // Phase 7: Show loading indicator
        $j('#review-tbody').html('<tr><td colspan="7" class="text-center p-4"><i class="fe-loader fe-spin"></i> Loading rows...</td></tr>');

        var url = '/ajax/importv3/rows.cfm?bypass=1&job_id=' + state.jobId +
            '&status=' + encodeURIComponent(state.currentFilter) +
            '&page=' + state.currentPage +
            '&limit=' + state.pageSize +
            (state.searchQuery ? '&search=' + encodeURIComponent(state.searchQuery) : '');

        $j.get(url, function(response) {
            console.log('[V3] ========== ROWS RESPONSE ==========');
            console.log('[V3] Rows response:', response);
            console.log('[V3] Rows success:', cfGet(response, 'success'), 'Code:', cfGet(response, 'code'));
            // Log debug breadcrumbs if present (handle both cases - CF returns uppercase)
            var data = cfGet(response, 'data') || {};
            var debugTrail = cfGet(data, 'debug');
            if (debugTrail) {
                console.log('[V3] Debug trail:', debugTrail.join(' -> '));
            }
            if (cfGet(response, 'success')) {
                // Handle both lowercase and uppercase keys (CF returns uppercase)
                var rows = cfGet(data, 'rows') || [];
                var total = cfGet(data, 'total') || 0;
                var page = cfGet(data, 'page') || 1;
                var totalPages = cfGet(data, 'total_pages') || cfGet(data, 'totalPages') || 1;
                renderRows(rows);
                renderPagination(total, page, totalPages);
                updateStats();
            } else {
                console.error('[V3] Load rows failed with code:', cfGet(response, 'code'));
                $j('#review-tbody').html('<tr><td colspan="7" class="text-center text-danger">' + escapeHtml(cfGet(response, 'message') || 'Unknown error') + '</td></tr>');
            }
        }).fail(function(xhr, status, error) {
            console.error('[V3] Load rows HTTP error:', xhr.status, status, error);
            $j('#review-tbody').html('<tr><td colspan="7" class="text-center text-danger">Failed to load rows. Please refresh the page.</td></tr>');
        });
    }

    // Helper to get value from object with case-insensitive key lookup
    function getVal(obj, key) {
        if (!obj) return '';
        return obj[key] || obj[key.toUpperCase()] || obj[key.toLowerCase()] || '';
    }

    function renderRows(rows) {
        if (!rows || rows.length === 0) {
            $j('#review-tbody').html('<tr><td colspan="7" class="text-center text-muted p-4">No rows found</td></tr>');
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
            var importError = row.import_error || row.IMPORT_ERROR || '';

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
                html += '<tr class="bg-light"><td colspan="7">';
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
                html += '<tr class="bg-warning-light"><td colspan="7">';
                html += '<small class="text-warning"><i class="fe-alert-triangle"></i> ';
                var dupeName = duplicates[0].contactFullName || duplicates[0].CONTACTFULLNAME || duplicates[0].recordname || duplicates[0].RECORDNAME || 'Unknown';
                html += 'Possible duplicate of: <strong>' + escapeHtml(dupeName) + '</strong>';
                if (bestMatchScore) {
                    html += ' (Score: ' + bestMatchScore + ')';
                }
                html += '</small></td></tr>';
            }

            // Show import failure reason
            if (status === 'failed' && importError) {
                html += '<tr class="bg-light"><td colspan="7">';
                html += '<small class="text-danger"><i class="fe-alert-circle"></i> <strong>Import failed:</strong> ' + escapeHtml(importError) + '</small>';
                html += '</td></tr>';
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

    function updateStats() {
        // V3 uses the rows endpoint with stats_only mode
        $j.get('/ajax/importv3/rows.cfm?bypass=1&job_id=' + state.jobId + '&stats_only=1', function(response) {
            console.log('[V3] ========== STATS RESPONSE ==========');
            console.log('[V3] Stats response:', response);
            // CF serializes keys uppercase: handle both cases
            var data = cfGet(response, 'data') || {};
            var stats = cfGet(data, 'stats');
            if (cfGet(response, 'success') && stats) {
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

                // If all rows are imported while we're finalizing, reload to show completed view
                var total = stats.total || 0;
                var imported = stats.imported || 0;
                var currentStatus = ($j('#job-status').val() || '').toLowerCase();
                if (total > 0 && imported >= total && currentStatus === 'finalizing') {
                    window.location.reload();
                    return;
                }

                // Show/hide "Continue to Import" button based on ready count
                $j('#btn-goto-finalize').toggle((stats.ready || 0) > 0);

                // Show warning if no ready rows
                if ((stats.ready || 0) === 0) {
                    $j('#finalize-warning').show();
                    $j('#finalize-warning-text').text('No rows are ready for import. Please fix validation errors or resolve duplicates.');
                    $j('#btn-finalize').prop('disabled', true);
                } else {
                    $j('#finalize-warning').hide();
                    $j('#btn-finalize').prop('disabled', false);
                }

                // Show/hide export problems button
                $j('#btn-export-problems').toggle((stats.problem || 0) > 0);

                // Build finalize pre-check summary
                var precheckHtml = '';
                precheckHtml += '<div class="col-auto"><span class="text-success"><strong>' + (stats.ready || 0) + '</strong> ready to import</span></div>';
                if ((stats.problem || 0) > 0) {
                    precheckHtml += '<div class="col-auto"><span class="text-danger">' + stats.problem + ' with errors (will be skipped)</span></div>';
                }
                if ((stats.dupe || 0) > 0) {
                    precheckHtml += '<div class="col-auto"><span class="text-warning">' + stats.dupe + ' unresolved duplicates (will be skipped)</span></div>';
                }
                if ((stats.ignored || 0) > 0) {
                    precheckHtml += '<div class="col-auto"><span class="text-muted">' + stats.ignored + ' excluded by you</span></div>';
                }
                if ((stats.imported || 0) > 0) {
                    precheckHtml += '<div class="col-auto"><span style="color:#406e8e;">' + stats.imported + ' already imported</span></div>';
                }
                $j('#precheck-details').html(precheckHtml);
                $j('#finalize-precheck').show();
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
                if (cfGet(response, 'success')) {
                    loadRows();
                } else {
                    showAlert('error', cfGet(response, 'message') || 'Action failed');
                }
            },
            error: function(xhr) {
                showErrorWithDebug(xhr, 'Row action failed.');
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
            // ColdFusion serializes struct keys uppercase - use cfGet helper
            var rData = cfGet(response, 'data') || {};
            var rowData = cfGet(rData, 'row');
            if (cfGet(response, 'success') && rowData) {
                renderEditModal(rowData);
            } else {
                showAlert('error', cfGet(response, 'message') || 'Could not load row data');
            }
        }).fail(function(xhr, status, error) {
            console.error('[V3] Edit row fetch error:', xhr.status, status, error);
            showErrorWithDebug(xhr, 'Failed to load row for editing.');
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
        currentEditData = normalizeKeys(cfGet(row, 'data') || {});
        var validation = normalizeKeys(cfGet(row, 'validation') || {});

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
        // Send camelCase keys as-is - they match fact field_name in the DB
        var data = {};

        $j('#edit-form input, #edit-form select, #edit-form textarea').each(function() {
            var name = $j(this).attr('name');
            if (name) {
                data[name] = $j(this).val();
            }
        });

        // Recompute contactFullName from first + last
        if (data.firstName !== undefined || data.lastName !== undefined) {
            var fn = (data.firstName || '').trim();
            var ln = (data.lastName || '').trim();
            data.contactFullName = (fn + ' ' + ln).trim();
        }

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
                var rData = cfGet(response, 'data') || {};
                var rDebug = cfGet(rData, 'debug');
                if (rDebug) {
                    console.log('[V3] Debug trail:', rDebug.join(' -> '));
                }
                $btn.prop('disabled', false).html('<i class="fe-check"></i> Save Changes');
                if (cfGet(response, 'success')) {
                    bsModal('#edit-modal', 'hide');
                    // Check if row status changed after revalidation
                    var rRow = cfGet(rData, 'row') || {};
                    var newStatus = cfGet(rRow, 'status') || '';
                    if (newStatus && newStatus !== state.currentFilter && state.currentFilter !== 'all') {
                        showAlert('success', 'Row revalidated - status changed to: ' + newStatus);
                        state.currentFilter = 'all';
                        $j('.filter-btn').removeClass('active');
                        $j('.filter-btn[data-filter="all"]').addClass('active');
                    } else {
                        showAlert('success', 'Row updated and revalidated');
                    }
                    loadRows();
                } else {
                    console.error('[V3] Fact update failed with code:', cfGet(response, 'code'));
                    showAlert('error', cfGet(response, 'message') || 'Validation failed');
                }
            },
            error: function(xhr, status, error) {
                console.error('[V3] Save error:', xhr.status, status, error);
                $btn.prop('disabled', false).html('<i class="fe-check"></i> Save Changes');
                showErrorWithDebug(xhr, 'Failed to save.');
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
            var rSuccess = cfGet(response, 'success');
            var rData = cfGet(response, 'data') || {};
            var rRow = cfGet(rData, 'row');
            if (!rSuccess || !rRow) {
                showAlert('error', cfGet(response, 'message') || 'Could not load duplicate info');
                return;
            }

            var row = rRow;
            var data = cfGet(row, 'data') || {};
            var dupes = cfGet(row, 'duplicates') || [];

            var html = '<div class="row">';

            // Import row
            html += '<div class="col-md-6">';
            html += '<h6>Importing:</h6>';
            html += '<table class="table table-sm">';
            html += '<tr><td><strong>Name</strong></td><td>' + escapeHtml(cfGet(data, 'contactFullName') || ((cfGet(data, 'firstName') || '') + ' ' + (cfGet(data, 'lastName') || ''))) + '</td></tr>';
            html += '<tr><td><strong>Email</strong></td><td>' + escapeHtml(cfGet(data, 'email_business') || cfGet(data, 'email_personal') || '-') + '</td></tr>';
            html += '<tr><td><strong>Phone</strong></td><td>' + escapeHtml(cfGet(data, 'phone_work') || cfGet(data, 'phone_mobile') || '-') + '</td></tr>';
            html += '<tr><td><strong>Company</strong></td><td>' + escapeHtml(cfGet(data, 'company') || '-') + '</td></tr>';
            html += '</table>';
            html += '</div>';

            // Existing contact
            if (dupes.length > 0) {
                var match = dupes[0];
                var bestScore = cfGet(row, 'best_match_score');
                var matchName = cfGet(match, 'contactFullName') || cfGet(match, 'recordname') || '';
                var matchEmail = cfGet(match, 'email');
                var matchPhone = cfGet(match, 'phone');
                var matchReasons = cfGet(match, 'reasons');
                var matchContactId = cfGet(match, 'contactid');
                html += '<div class="col-md-6">';
                html += '<h6>Existing Contact' + (bestScore ? ' (Score: ' + bestScore + ')' : '') + ':</h6>';
                html += '<table class="table table-sm">';
                html += '<tr><td><strong>Name</strong></td><td>' + escapeHtml(matchName) + '</td></tr>';
                if (matchEmail) {
                    html += '<tr><td><strong>Email</strong></td><td class="text-success">' + escapeHtml(matchEmail) + '</td></tr>';
                }
                if (matchPhone) {
                    html += '<tr><td><strong>Phone</strong></td><td class="text-success">' + escapeHtml(matchPhone) + '</td></tr>';
                }
                html += '</table>';
                if (matchReasons && matchReasons.length > 0) {
                    html += '<p class="text-muted small">Match reasons: ' + matchReasons.join(', ') + '</p>';
                }
                html += '<a href="/app/contact/?contactid=' + matchContactId + '" target="_blank" class="btn btn-xs btn-outline-info">View Contact</a>';
                html += '</div>';
            }

            html += '</div>';

            $j('#dupe-modal-body').html(html);
            bsModal('#dupe-modal', 'show');
        }).fail(function(xhr, status, error) {
            console.error('[V3] Resolve dupe fetch error:', xhr.status, status, error);
            showErrorWithDebug(xhr, 'Failed to load duplicate info.');
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
                var rData = cfGet(response, 'data') || {};
                var rDebug = cfGet(rData, 'debug');
                if (rDebug) {
                    console.log('[V3] Debug trail:', rDebug.join(' -> '));
                }
                bsModal('#dupe-modal', 'hide');
                if (cfGet(response, 'success')) {
                    loadRows();
                } else {
                    console.error('[V3] Dupe action failed with code:', cfGet(response, 'code'));
                    showAlert('error', cfGet(response, 'message'));
                }
            },
            error: function(xhr, status, error) {
                console.error('[V3] Dupe action HTTP error:', xhr.status, status, error);
                bsModal('#dupe-modal', 'hide');
                showErrorWithDebug(xhr, 'Duplicate action failed.');
            }
        });
    }

    // ========================================
    // STATUS CHANGE
    // ========================================

    function initStatusControls() {
        // Active job status change dropdown
        $j(document).on('click', '.btn-change-status', function(e) {
            e.preventDefault();
            var newStatus = $j(this).data('new-status');
            var statusLabel = newStatus === 'cancelled' ? 'cancel this import' : 'return this job to review';
            if (!confirm('Are you sure you want to ' + statusLabel + '?')) return;
            changeJobStatus(state.jobId, newStatus);
        });

        // History table reset buttons
        $j(document).on('click', '.btn-history-reset', function(e) {
            e.preventDefault();
            var histJobId = $j(this).data('job-id');
            if (!confirm('Reset this job back to review status?')) return;
            changeJobStatus(histJobId, 'reviewing', true);
        });

        // History table cancel buttons
        $j(document).on('click', '.btn-history-cancel', function(e) {
            e.preventDefault();
            var histJobId = $j(this).data('job-id');
            if (!confirm('Cancel this import job?')) return;
            changeJobStatus(histJobId, 'cancelled', true);
        });
    }

    function changeJobStatus(jobId, newStatus, reloadPage) {
        console.log('[V3] Changing job status:', jobId, '->', newStatus);

        var csrfToken = $j('#csrf-token').val() || '';
        // For history page actions where csrf-token hidden input may not exist,
        // generate one or skip CSRF (server will handle)
        
        $j.ajax({
            url: '/ajax/importv3/status.cfm?bypass=1',
            type: 'POST',
            contentType: 'application/json',
            headers: csrfToken ? { 'X-CSRF-Token': csrfToken } : {},
            data: JSON.stringify({
                job_id: jobId,
                new_status: newStatus,
                csrf_token: csrfToken
            }),
            success: function(response) {
                console.log('[V3] Status change response:', response);
                if (response.data && response.data.debug) {
                    console.log('[V3] Debug trail:', response.data.debug.join(' -> '));
                }
                if (response.success) {
                    showAlert('success', response.message || 'Status updated');
                    setTimeout(function() {
                        if (reloadPage || newStatus === 'cancelled') {
                            window.location.href = '/app/contacts-import-v3/';
                        } else {
                            window.location.reload();
                        }
                    }, 1000);
                } else {
                    console.error('[V3] Status change failed:', response.code, response.message);
                    showAlert('error', response.message || 'Status change failed');
                }
            },
            error: function(xhr, status, error) {
                console.error('[V3] Status change HTTP error:', xhr.status, status, error);
                showErrorWithDebug(xhr, 'Status change failed.');
            }
        });
    }

    // ========================================
    // FINALIZE - V3 ENDPOINTS
    // ========================================

    function finalizeImport() {
        var readyCount = state.stats.ready || 0;
        var problemCount = state.stats.problem || 0;
        var dupeCount = state.stats.dupe || 0;
        var ignoredCount = state.stats.ignored || 0;

        var msg = 'Import ' + readyCount + ' contact' + (readyCount !== 1 ? 's' : '') + '?\n\n';
        msg += readyCount + ' will be imported\n';
        if (problemCount > 0) msg += problemCount + ' with errors will be skipped\n';
        if (dupeCount > 0) msg += dupeCount + ' unresolved duplicates will be skipped\n';
        if (ignoredCount > 0) msg += ignoredCount + ' excluded by you\n';
        msg += '\nThis action cannot be undone.';

        if (!confirm(msg)) {
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
        var requestPayload = {
            job_id: state.jobId,
            csrf_token: csrfToken
        };
        console.log('[V3] ========== FINALIZE REQUEST ==========');
        console.log('[V3] Finalize payload:', JSON.stringify(requestPayload));
        $j.ajax({
            url: '/ajax/importv3/finalize.cfm?bypass=1',  // V3 ENDPOINT - bypass=1 required
            type: 'POST',
            contentType: 'application/json',
            dataType: 'json',
            headers: {
                'X-CSRF-Token': csrfToken  // Phase 5.2: Header CSRF (preferred)
            },
            data: JSON.stringify(requestPayload),
            success: function(response) {
                console.log('[V3] ========== FINALIZE RESPONSE ==========');
                console.log('[V3] Finalize response:', response);
                // Log debug breadcrumbs if present
                if (response.data && response.data.debug) {
                    console.log('[V3] Debug trail:', response.data.debug.join(' -> '));
                }
                $j('#finalize-progress').hide();

                if (response.success || response.SUCCESS) {
                    // Log import counts for debugging
                    var respData = response.data || response.DATA || {};
                    if (respData.counts || respData.COUNTS) {
                        var c = respData.counts || respData.COUNTS;
                        console.log('[V3] Finalize counts: imported_new=' + (c.imported_new || c.IMPORTED_NEW || 0) +
                            ' updated=' + (c.updated_existing || c.UPDATED_EXISTING || 0) +
                            ' skipped_already=' + (c.skipped_already_imported || c.SKIPPED_ALREADY_IMPORTED || 0) +
                            ' failed=' + (c.failed || c.FAILED || 0));
                    }
                    if (respData.warnings || respData.WARNINGS) {
                        var w = respData.warnings || respData.WARNINGS || [];
                        if (w.length > 0) {
                            console.warn('[V3] Finalize warnings:', w);
                        }
                    }
                    showAlert('success', response.message || response.MESSAGE || 'Import completed successfully!');
                    setTimeout(function() {
                        window.location.reload();
                    }, 1500);
                } else {
                    var errCode = response.code || response.CODE || 'UNKNOWN';
                    var errMsg = response.message || response.MESSAGE || 'Import failed';
                    console.error('[V3] Finalize failed with code:', errCode, 'message:', errMsg);
                    console.error('[V3] Full failure response:', JSON.stringify(response));
                    // Handle specific error codes with better UX
                    if (errCode === 'NO_ROWS_ELIGIBLE') {
                        showAlert('warning', errMsg || 'No rows are ready for import. Please review and approve rows first.');
                    } else {
                        showAlert('error', errMsg);
                    }
                    $j('#btn-finalize').prop('disabled', false).html('<i class="fe-check-circle"></i> Import <span id="import-count">' + (state.stats.ready || '...') + '</span> Contacts');
                }
            },
            error: function(xhr, status, error) {
                console.error('[V3] ========== FINALIZE ERROR ==========');
                console.error('[V3] Finalize HTTP error:', xhr.status, status, error);
                console.error('[V3] Response text (first 2000 chars):', (xhr.responseText || '').substring(0, 2000));
                // Try to parse response even on error
                try {
                    var errResp = JSON.parse(xhr.responseText);
                    console.error('[V3] Parsed error response:', errResp);
                    if (errResp.data && errResp.data.debug) {
                        console.error('[V3] Error debug trail:', errResp.data.debug.join(' -> '));
                    }
                } catch(e) {
                    console.error('[V3] Response is not JSON');
                }
                showErrorWithDebug(xhr, 'Import failed.');
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
                showErrorWithDebug(xhr, 'Preview failed.');
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

    // Update breadcrumb stepper to reflect current step
    function updateStepper(activeStep) {
        var $stepper = $j('#import-stepper');
        if (!$stepper.length) return;
        $stepper.find('.step-item').each(function(idx) {
            var stepNum = idx + 1;
            var $item = $j(this);
            var $circle = $item.find('.step-circle');
            $item.removeClass('active completed');
            if (stepNum < activeStep) {
                $item.addClass('completed');
                $circle.html('<i class="fe-check"></i>');
            } else if (stepNum === activeStep) {
                $item.addClass('active');
                $circle.html(stepNum);
            } else {
                $circle.html(stepNum);
            }
        });
    }

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

    function csvEscape(val) {
        if (!val) return '';
        val = String(val);
        if (val.indexOf(',') >= 0 || val.indexOf('"') >= 0 || val.indexOf('\n') >= 0) {
            return '"' + val.replace(/"/g, '""') + '"';
        }
        return val;
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
            '<i class="' + icon + '" style="margin-right:8px;"></i>' + message +
            '<span style="position:absolute;top:8px;right:12px;cursor:pointer;font-size:18px;line-height:1;opacity:0.6;" ' +
            'onclick="this.parentElement.remove()">&times;</span></div>';

        $j('#v3-toast-container').append(html);

        // Fade in
        setTimeout(function() { document.getElementById(id).style.opacity = '1'; }, 10);

        // Auto-dismiss after 5 seconds
        setTimeout(function() {
            var el = document.getElementById(id);
            if (el) { el.style.opacity = '0'; setTimeout(function() { if (el.parentNode) el.remove(); }, 300); }
        }, 15000);
    }

    /**
     * Show error with debug info from server response.
     * Extracts correlation_id, error code, message, and debug trail.
     * Falls back to generic message if response is not parseable.
     */
    function showErrorWithDebug(xhr, fallbackMsg) {
        var response = null;
        var msg = fallbackMsg || 'An error occurred.';
        var code = '';
        var correlationId = '';
        var debugTrail = [];

        // Try to parse response as JSON
        try {
            var rawText = (xhr && xhr.responseText) ? xhr.responseText : (typeof xhr === 'string' ? xhr : '');
            if (rawText) {
                response = JSON.parse(rawText);
            } else if (typeof xhr === 'object' && xhr !== null && !xhr.responseText) {
                // Already a parsed object
                response = xhr;
            }
        } catch(e) {
            // Not JSON - use status code
            if (xhr && xhr.status) {
                msg = fallbackMsg + ' (HTTP ' + xhr.status + ')';
            }
        }

        if (response) {
            var serverMsg = cfGet(response, 'message');
            code = cfGet(response, 'code') || '';
            correlationId = cfGet(response, 'correlation_id') || '';
            debugTrail = cfGet(response, 'debug') || [];

            if (serverMsg) {
                msg = code ? '[' + code + '] ' + serverMsg : serverMsg;
            }
        }

        // Log correlation ID to console for server log lookup
        if (correlationId) {
            console.log('[V3] Correlation ID: ' + correlationId + ' (use this to search server logs)');
        }

        // Log debug trail to console
        if (debugTrail.length > 0) {
            console.group('[V3] Debug trail (cid=' + correlationId + ')');
            debugTrail.forEach(function(entry) {
                if (typeof entry === 'string') {
                    console.log(entry);
                } else if (typeof entry === 'object') {
                    var ts = cfGet(entry, 'ts') || '';
                    var level = cfGet(entry, 'level') || '';
                    var stage = cfGet(entry, 'stage') || '';
                    var entryMsg = cfGet(entry, 'msg') || '';
                    console.log('[' + ts + 'ms] [' + level + '] ' + stage + ': ' + entryMsg);
                }
            });
            console.groupEnd();
        }

        // Show toast with error
        showAlert('error', msg);

        // Log any phase_times or first_failure from data
        var data = response ? (cfGet(response, 'data') || {}) : {};
        var phaseTimes = cfGet(data, 'phase_times');
        var firstFailure = cfGet(data, 'first_failure');
        if (phaseTimes && typeof phaseTimes === 'object' && Object.keys(phaseTimes).length > 0) {
            console.log('[V3] Phase times:', phaseTimes);
        }
        if (firstFailure && typeof firstFailure === 'object' && Object.keys(firstFailure).length > 0) {
            console.log('[V3] First failure:', firstFailure);
        }
    }

})();
