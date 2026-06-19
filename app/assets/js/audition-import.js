/**
 * Audition Import - JavaScript Controller
 * Handles file upload, parsing, review grid, and import finalization
 *
 * All calls go to /ajax/import-auditions/ namespace
 *
 * noConflict-safe - uses local $j alias, never relies on global $
 * Bounded wait for jQuery + init guard to prevent double initialization
 */

(function() {
    'use strict';

    // Guard flag to ensure initAud runs exactly once
    var initialized = false;

    // Local jQuery alias - set after jQuery becomes available
    var $j = null;

    // Bounded wait for jQuery availability
    var maxWaitMs = 2000;
    var pollEveryMs = 50;
    var waited = 0;

    function showJQueryError() {
        var alertDiv = document.createElement('div');
        alertDiv.style.cssText = 'position:fixed;top:0;left:0;right:0;background:#dc3545;color:#fff;padding:15px;text-align:center;z-index:99999;font-family:sans-serif;';
        alertDiv.innerHTML = '<strong>Error:</strong> Audition Import requires jQuery. Please ensure jQuery is loaded before this script.';
        if (document.body) {
            document.body.insertBefore(alertDiv, document.body.firstChild);
        } else {
            document.addEventListener('DOMContentLoaded', function() {
                document.body.insertBefore(alertDiv, document.body.firstChild);
            });
        }
        console.error('[AUD] FATAL: jQuery not available after ' + maxWaitMs + 'ms. Audition Import cannot initialize.');
    }

    function waitForJQuery() {
        if (typeof window.jQuery !== 'undefined') {
            // jQuery is available - set alias and initialize
            $j = window.jQuery;
            console.log('[AUD] jQuery detected after ' + waited + 'ms');
            $j(document).ready(initAud);
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

    // Main initialization function - runs exactly once
    function initAud() {
        if (initialized) {
            console.log('[AUD] initAud called but already initialized - skipping');
            return;
        }
        initialized = true;

        console.log('[AUD] Audition Import JavaScript loaded');
        console.log('[AUD] ========== DOCUMENT READY ==========');
        console.log('[AUD] Initializing Audition Import...');

        initUpload();
        initJobActions();
        initReviewGrid();
        initModals();
        loadCategoryOptions();
        initStatusControls();
        initBulkEdit();

        // Check for active job
        var jobIdInput = document.getElementById('job-id');
        var jobStatusInput = document.getElementById('job-status');
        console.log('[AUD] job-id element:', jobIdInput);
        console.log('[AUD] job-status element:', jobStatusInput);

        if (jobIdInput) {
            state.jobId = parseInt(jobIdInput.value);
            var status = jobStatusInput ? jobStatusInput.value : 'unknown';
            console.log('[AUD] Active job:', state.jobId, 'Status:', status);
            console.log('[AUD] state object:', JSON.stringify(state));

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
        contact_name: { type: 'text', label: 'Contact Name', group: 'contact' },
        contact_email: { type: 'email', label: 'Contact Email', group: 'contact' },
        project_name: { type: 'text', label: 'Project Name', group: 'project' },
        role_name: { type: 'text', label: 'Role Name', group: 'project' },
        casting_director: { type: 'text', label: 'Casting Director', group: 'project' },
        agency: { type: 'text', label: 'Agency', group: 'project' },
        audition_date: { type: 'date', label: 'Audition Date', group: 'schedule' },
        audition_time: { type: 'text', label: 'Audition Time', group: 'schedule' },
        callback_date: { type: 'date', label: 'Callback Date', group: 'schedule' },
        booking_date: { type: 'date', label: 'Booking Date', group: 'schedule' },
        location: { type: 'text', label: 'Location', group: 'details' },
        medium: { type: 'select', label: 'Category', group: 'details', options: [
            { value: '', label: '(None)' },
            { value: 'film', label: 'Film' },
            { value: 'tv', label: 'TV' },
            { value: 'commercial', label: 'Commercial' },
            { value: 'theater', label: 'Theater' },
            { value: 'voiceover', label: 'Voiceover' },
            { value: 'other', label: 'Other' }
        ]},
        status: { type: 'select', label: 'Status', group: 'details', options: [
            { value: '', label: '(None)' },
            { value: 'scheduled', label: 'Scheduled' },
            { value: 'completed', label: 'Completed' },
            { value: 'callback', label: 'Callback' },
            { value: 'booked', label: 'Booked' },
            { value: 'pass', label: 'Pass' }
        ]},
        self_tape: { type: 'select', label: 'Self-Tape', group: 'details', options: [
            { value: '', label: '(None)' },
            { value: '1', label: 'Yes' },
            { value: '0', label: 'No' }
        ]},
        notes: { type: 'textarea', label: 'Notes', group: 'other' },
        audsubcatid: { type: 'category_select', label: 'Category', group: 'project' }
    };

    // Category options loaded from server (populated on init)
    var categoryOptions = [];

    // State
    var state = {
        jobId: 0,
        currentFilter: '',
        currentPage: 1,
        pageSize: 50,
        stats: {},
        searchQuery: ''
    };

    // Note: Initialization moved to initAud() function
    // initAud is called via $j(document).ready after jQuery is detected

    // ========================================
    // FILE UPLOAD - 
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

        // Sample test data buttons
        var testButtons = document.querySelectorAll('.btn-load-test');
        testButtons.forEach(function(btn) {
            btn.addEventListener('click', function(e) {
                e.stopPropagation();
                var scenario = this.getAttribute('data-scenario');
                loadTestData(scenario);
            });
        });
    }

    function uploadFile(file) {
        console.log('[AUD] Uploading file:', file.name);

        // Validate file type (CSV, XLS, XLSX only)
        var validTypes = ['text/csv', 'application/vnd.ms-excel',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'];
        var validExts = ['csv', 'xls', 'xlsx'];
        var ext = file.name.split('.').pop().toLowerCase();

        if (!validTypes.includes(file.type) && !validExts.includes(ext)) {
            showAlert('error', 'Invalid file type. Please upload CSV, XLS, or XLSX files.');
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

        // Include CSRF token (from hidden input on page and session token)
        var csrfToken = $j('#csrf-token').val() || '';
        if (csrfToken) {
            formData.append('csrf_token', csrfToken);
        }

        // Also get the Application.cfc CSRF token from meta tag
        var appCsrfMeta = document.querySelector('meta[name="csrf-token"]');
        var appCsrfToken = appCsrfMeta ? appCsrfMeta.getAttribute('content') : '';

        $j.ajax({
            url: '/ajax/import-auditions/upload.cfm?bypass=1',
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            headers: appCsrfToken ? { 'X-CSRF-Token': appCsrfToken } : {},
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
                console.log('[AUD] Upload response:', response);
                if (cfGet(response, 'success')) {
                    // Extract job_id from response.data.job
                    var rData = cfGet(response, 'data') || {};
                    var job = cfGet(rData, 'job') || {};
                    var jobId = cfGet(job, 'job_id') || 0;

                    // Check if this is a duplicate file (V3 uses code field)
                    if (cfGet(response, 'code') === 'DUPLICATE_FILE') {
                        var dupeName = cfGet(job, 'source_filename') || 'this file';
                        var dupeStatus = cfGet(job, 'status') || 'unknown';
                        console.log('[AUD] Duplicate file detected:', dupeName, 'existing job status:', dupeStatus);
                        $j('#upload-progress').hide();
                        $j('#upload-area').show();
                        showAlert('warning',
                            'This file (<strong>' + escapeHtml(dupeName) + '</strong>) was already uploaded.' +
                            ' The existing job is in <strong>' + escapeHtml(dupeStatus) + '</strong> status.' +
                            ' <a href="/app/auditions-import/?job_id=' + jobId + '" class="alert-link">Open existing job</a>'
                        );
                        return;
                    }

                    if (!jobId) {
                        console.error('[AUD] Could not extract job_id from upload response:', response);
                        showAlert('error', 'Upload succeeded but no job ID was returned.');
                        $j('#upload-area').show();
                        $j('#upload-progress').hide();
                        return;
                    }

                    // Redirect to V3 job page
                    window.location.href = '/app/auditions-import/?job_id=' + jobId;
                } else {
                    var errMsg = cfGet(response, 'message') || 'Upload failed';
                    showAlert('error', errMsg);
                    $j('#upload-area').show();
                    $j('#upload-progress').hide();
                }
            },
            error: function(xhr, status, error) {
                console.error('[AUD] Upload error:', error, xhr.responseText);
                showErrorWithDebug(xhr, 'Upload failed.');
                $j('#upload-area').show();
                $j('#upload-progress').hide();
            }
        });
    }

    // ========================================
    // SAMPLE TEST DATA LOADER
    // ========================================

    function loadTestData(scenario) {
        console.log('[AUD] Loading test data, scenario:', scenario);

        // Disable buttons and show progress
        $j('.btn-load-test').prop('disabled', true);
        $j('#upload-area').hide();
        $j('#test-data-section').hide();
        $j('#upload-progress').show();
        $j('#upload-status').text('Generating test data (' + scenario + ')...');

        var csrfToken = $j('#csrf-token').val() || '';
        var appCsrfMeta = document.querySelector('meta[name="csrf-token"]');
        var appCsrfToken = appCsrfMeta ? appCsrfMeta.getAttribute('content') : '';

        $j.ajax({
            url: '/ajax/import-auditions/generate-test.cfm?bypass=1',
            type: 'POST',
            data: { scenario: scenario, csrf_token: csrfToken },
            headers: appCsrfToken ? { 'X-CSRF-Token': appCsrfToken } : {},
            dataType: 'json',
            success: function(response) {
                console.log('[AUD] Generate test response:', response);
                if (cfGet(response, 'success')) {
                    var rData = cfGet(response, 'data') || {};
                    var job = cfGet(rData, 'job') || {};
                    var jobId = cfGet(job, 'job_id') || 0;

                    if (!jobId) {
                        showAlert('error', 'Test data generated but no job ID was returned.');
                        resetTestDataUI();
                        return;
                    }

                    // Redirect to job page (same as normal upload)
                    window.location.href = '/app/auditions-import/?job_id=' + jobId;
                } else {
                    var errMsg = cfGet(response, 'message') || 'Failed to generate test data';
                    showAlert('error', errMsg);
                    resetTestDataUI();
                }
            },
            error: function(xhr, status, error) {
                console.error('[AUD] Generate test error:', error, xhr.responseText);
                showErrorWithDebug(xhr, 'Failed to generate test data.');
                resetTestDataUI();
            }
        });
    }

    function resetTestDataUI() {
        $j('.btn-load-test').prop('disabled', false);
        $j('#upload-area').show();
        $j('#test-data-section').show();
        $j('#upload-progress').hide();
    }

    // ========================================
    // JOB ACTIONS -
    // ========================================

    function initJobActions() {
        console.log('[AUD] initJobActions called');

        // Confirm mapping button
        $j('#btn-confirm-mapping').click(function() {
            confirmMappings();
        });

        // Finalize button
        $j('#btn-finalize').click(function() {
            finalizeImport();
        });


        // Export problems as CSV
        $j('#btn-export-problems').click(function() {
            var $btn = $j(this);
            $btn.prop('disabled', true).html('<i class="fe-loader fe-spin"></i> Exporting...');
            // Fetch all problem rows (up to 10000)
            $j.get('/ajax/import-auditions/rows.cfm?bypass=1&job_id=' + state.jobId + '&status=problem&page=1&limit=10000', function(response) {
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
                var csvRows = [['Row #', 'Project', 'Role', 'Date', 'Contact', 'Error Field', 'Error Message'].join(',')];
                rows.forEach(function(row) {
                    var d = row.data || row.DATA || {};
                    var project = getVal(d, 'project_name') || '';
                    var role = getVal(d, 'role_name') || '';
                    var audDate = getVal(d, 'audition_date') || '';
                    var contact = getVal(d, 'contact_name') || '';
                    var errors = row.errors || row.ERRORS || [];
                    if (errors.length === 0) {
                        csvRows.push([row.row_num || row.ROW_NUM, csvEscape(project), csvEscape(role), csvEscape(audDate), csvEscape(contact), '', ''].join(','));
                    } else {
                        errors.forEach(function(err) {
                            csvRows.push([row.row_num || row.ROW_NUM, csvEscape(project), csvEscape(role), csvEscape(audDate), csvEscape(contact), csvEscape(err.field || err.FIELD || ''), csvEscape(err.message || err.MESSAGE || '')].join(','));
                        });
                    }
                });
                var csvContent = csvRows.join('\n');
                var blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
                var link = document.createElement('a');
                link.href = URL.createObjectURL(blob);
                link.download = 'audition_import_problems_job_' + state.jobId + '.csv';
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
            var csrfToken = $j('#csrf-token').val() || '';
            $j.ajax({
                url: '/ajax/import-auditions/recompute.cfm?bypass=1',
                type: 'POST',
                contentType: 'application/json',
                headers: csrfToken ? { 'X-CSRF-Token': csrfToken } : {},
                data: JSON.stringify({ job_id: state.jobId, csrf_token: csrfToken }),
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
        console.log('[AUD] ========== PARSE STARTED ==========');
        console.log('[AUD] state.jobId =', state.jobId);
        console.log('[AUD] typeof state.jobId =', typeof state.jobId);

        if (!state.jobId || state.jobId <= 0) {
            console.error('[AUD] ERROR: Invalid job ID!');
            showAlert('error', 'Invalid job ID. Please refresh the page.');
            return;
        }

        console.log('[AUD] Sending request to /ajax/import-auditions/parse.cfm?bypass=1');

        $j('#parse-progress').show();

        var csrfToken = $j('#csrf-token').val() || '';
        $j.ajax({
            url: '/ajax/import-auditions/parse.cfm?bypass=1',
            type: 'POST',
            contentType: 'application/json',
            headers: csrfToken ? { 'X-CSRF-Token': csrfToken } : {},
            data: JSON.stringify({ job_id: state.jobId, csrf_token: csrfToken }),
            success: function(response) {
                console.log('[AUD] ========== PARSE RESPONSE ==========');
                console.log('[AUD] Full response:', JSON.stringify(response, null, 2));

                // Log debug array if present
                if (response.debug && response.debug.length > 0) {
                    console.log('[AUD] Parse debug log (' + response.debug.length + ' entries):');
                    response.debug.forEach(function(line, idx) {
                        console.log('  [' + idx + '] ' + line);
                    });
                } else {
                    console.log('[AUD] No debug array in response');
                }

                if (cfGet(response, 'success')) {
                    console.log('[AUD] Parse successful, reloading page...');
                    // Reload page to show mapping step
                    window.location.reload();
                } else {
                    var parseMsg = cfGet(response, 'message') || 'Parsing failed';
                    console.log('[AUD] Parse failed:', parseMsg);
                    showAlert('error', parseMsg);
                    $j('#parse-progress').hide();
                }
            },
            error: function(xhr, status, error) {
                console.error('[AUD] ========== PARSE ERROR ==========');
                console.error('[AUD] Status:', status);
                console.error('[AUD] Error:', error);
                console.error('[AUD] Response text:', xhr.responseText);

                // Try to parse debug from error response
                showErrorWithDebug(xhr, 'Parsing failed.');
                $j('#parse-progress').hide();
            }
        });
    }

    // Auto-recompute: trigger recompute after auto-mapped columns
    // so rows get validated and job transitions to "reviewing" status
    function triggerAutoRecompute() {
        console.log('[AUD] ========== AUTO RECOMPUTE ==========');
        $j('#parse-progress').show();
        var csrfToken = $j('#csrf-token').val() || '';
        $j.ajax({
            url: '/ajax/import-auditions/recompute.cfm?bypass=1',
            type: 'POST',
            contentType: 'application/json',
            headers: csrfToken ? { 'X-CSRF-Token': csrfToken } : {},
            data: JSON.stringify({ job_id: state.jobId, csrf_token: csrfToken }),
            timeout: 120000,
            success: function(response) {
                console.log('[AUD] Auto-recompute response:', response);
                window.location.reload();
            },
            error: function(xhr, status, error) {
                console.error('[AUD] Auto-recompute failed:', error);
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
        console.log('[AUD] ========== LOAD COLUMN MAPPINGS ==========');
        console.log('[AUD] Loading column mappings for job:', state.jobId);
        $j.get('/ajax/import-auditions/columns.cfm?bypass=1&job_id=' + state.jobId, function(response) {
            console.log('[AUD] Columns response:', response);
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
            'project':         'project_name',
            'role':            'role_name',
            'date':            'audition_date',
            'contact':         'contact_name',
            'cd':              'casting_director',
            'castingdirector': 'casting_director',
            'email':           'contact_email',
            'time':            'audition_time',
            'selftape':        'self_tape'
        };

        var html = '<table class="table table-sm" style="table-layout:fixed;width:100%;"><thead><tr><th style="width:150px;">Source Column</th><th>Sample Values</th><th style="width:200px;">Maps To</th></tr></thead><tbody>';

        columns.forEach(function(col) {
            var colId = cfGet(col, 'column_id');
            var sourceName = cfGet(col, 'source_name') || '';
            var sourceIndex = cfGet(col, 'source_column_index');
            var mappedField = cfGet(col, 'mapped_field') || cfGet(col, 'target_key') || '';
            var userConfirmed = cfGet(col, 'user_confirmed');

            // For un-confirmed columns, try source-name matching first.
            // This overrides potentially incorrect backend auto-mapping
            // (e.g. "role_name" header wrongly auto-mapped to contact_name).
            var effectiveMapping = mappedField;
            if (sourceName) {
                var srcNorm = normalize(sourceName);
                var sourceMatch = '';
                // 1) Check smart defaults (e.g. "role" -> role_name)
                if (smartDefaults[srcNorm]) {
                    sourceMatch = smartDefaults[srcNorm];
                } else {
                    // 2) Normalized match against field key or display name
                    for (var i = 0; i < availableFields.length; i++) {
                        var fKey = cfGet(availableFields[i], 'field') || '';
                        var fName = cfGet(availableFields[i], 'display_name') || '';
                        if (srcNorm === normalize(fKey) || srcNorm === normalize(fName)) {
                            sourceMatch = fKey;
                            break;
                        }
                    }
                }
                // Use source-name match if found and column not user-confirmed
                if (sourceMatch && (!userConfirmed || !effectiveMapping)) {
                    effectiveMapping = sourceMatch;
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
        console.log('[AUD] ========== CONFIRM MAPPINGS ==========');
        console.log('[AUD] Confirming mappings for job:', state.jobId);

        // Collect mappings
        var mappings = [];
        $j('.mapping-select').each(function() {
            mappings.push({
                column_id: parseInt($j(this).data('column-id')),
                field: $j(this).val()
            });
        });

        console.log('[AUD] Mappings to send:', JSON.stringify(mappings));

        // Show spinner and disable button during recompute
        var $btn = $j('#btn-confirm-mapping');
        var originalHtml = $btn.html();
        $btn.prop('disabled', true).html('<i class="fe-loader fe-spin"></i> Processing...');

        var csrfToken = $j('#csrf-token').val() || '';
        var requestData = { job_id: state.jobId, mappings: mappings, csrf_token: csrfToken };
        console.log('[AUD] Full request data:', JSON.stringify(requestData));

        // V3 uses recompute endpoint to apply mappings and validate
        $j.ajax({
            url: '/ajax/import-auditions/recompute.cfm?bypass=1',
            type: 'POST',
            contentType: 'application/json',
            headers: csrfToken ? { 'X-CSRF-Token': csrfToken } : {},
            data: JSON.stringify(requestData),
            timeout: 60000, // 60 second timeout
            success: function(response) {
                console.log('[AUD] ========== RECOMPUTE RESPONSE ==========');
                console.log('[AUD] Recompute response:', response);
                console.log('[AUD] Response type:', typeof response);
                var rSuccess = cfGet(response, 'success');
                console.log('[AUD] Response success:', rSuccess);
                if (rSuccess) {
                    console.log('[AUD] Success! Reloading page...');
                    window.location.reload();
                } else {
                    var rMsg = cfGet(response, 'message') || 'Failed to process';
                    console.log('[AUD] Failed:', rMsg);
                    showAlert('error', rMsg);
                    $btn.prop('disabled', false).html(originalHtml);
                }
            },
            error: function(xhr, status, error) {
                console.error('[AUD] ========== RECOMPUTE ERROR ==========');
                console.error('[AUD] Status:', status, 'HTTP:', xhr.status);
                showErrorWithDebug(xhr, 'Failed to process mappings.');
                $btn.prop('disabled', false).html(originalHtml);
            },
            complete: function(xhr, status) {
                console.log('[AUD] AJAX complete. Status:', status);
            }
        });
    }

    // ========================================
    // REVIEW GRID - 
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

    // ========================================
    // CATEGORY OPTIONS
    // ========================================

    function loadCategoryOptions() {
        $j.get('/ajax/import-auditions/categories.cfm?bypass=1', function(response) {
            if (cfGet(response, 'success')) {
                var data = cfGet(response, 'data') || {};
                categoryOptions = cfGet(data, 'options') || [];
                console.log('[AUD] Loaded', categoryOptions.length, 'category options');
                populateHeaderCategorySelect();
            }
        });
    }

    function populateHeaderCategorySelect() {
        var $sel = $j('#header-category-select');
        if (!$sel.length || categoryOptions.length === 0) return;
        $sel.find('option:not(:first)').remove();
        categoryOptions.forEach(function(opt) {
            var id = opt.audsubcatid || opt.AUDSUBCATID;
            var name = opt.audcatname || opt.AUDCATNAME;
            $sel.append('<option value="' + id + '">' + escapeHtml(name) + '</option>');
        });

        // Bulk apply handler
        $sel.off('change').on('change', function() {
            var val = $j(this).val();
            if (!val) return;
            var name = $j(this).find('option:selected').text();
            if (!confirm('Set category to "' + name + '" for all rows that don\'t have one yet?')) {
                $j(this).val('');
                return;
            }
            bulkApplyCategory(val);
            $j(this).val('');
        });
    }

    function bulkApplyCategory(audsubcatid) {
        var csrfToken = $j('#csrf-token').val() || '';
        $j.ajax({
            url: '/ajax/import-auditions/bulk_category.cfm?bypass=1',
            type: 'POST',
            contentType: 'application/json',
            headers: csrfToken ? { 'X-CSRF-Token': csrfToken } : {},
            data: JSON.stringify({
                job_id: state.jobId,
                audsubcatid: parseInt(audsubcatid),
                csrf_token: csrfToken
            }),
            success: function(response) {
                if (cfGet(response, 'success')) {
                    var data = cfGet(response, 'data') || {};
                    var count = cfGet(data, 'updated_count') || 0;
                    showAlert('success', count + ' row(s) updated with category');
                    loadRows();
                } else {
                    showAlert('error', cfGet(response, 'message') || 'Failed to update');
                }
            },
            error: function(xhr) {
                showErrorWithDebug(xhr, 'Bulk category update failed.');
            }
        });
    }

    function getCategoryNameById(audsubcatid) {
        var id = parseInt(audsubcatid);
        for (var i = 0; i < categoryOptions.length; i++) {
            var optId = categoryOptions[i].audsubcatid || categoryOptions[i].AUDSUBCATID;
            if (parseInt(optId) === id) {
                return categoryOptions[i].audcatname || categoryOptions[i].AUDCATNAME;
            }
        }
        return '';
    }

    function buildCategorySelect(rowId, currentValue, isDisabled) {
        var val = currentValue ? parseInt(currentValue) : 0;
        var missing = !val || val === 0;
        var cls = missing ? 'is-invalid' : '';
        var disabled = isDisabled ? ' disabled' : '';
        var html = '<select class="form-control form-control-sm row-category-select ' + cls + '"' +
            ' data-row-id="' + rowId + '"' + disabled +
            ' style="font-size:11px;padding:1px 4px;min-width:100px;">';
        html += '<option value=""' + (missing ? ' selected' : '') + '>-- Select --</option>';
        categoryOptions.forEach(function(opt) {
            var id = opt.audsubcatid || opt.AUDSUBCATID;
            var name = opt.audcatname || opt.AUDCATNAME;
            var selected = (parseInt(id) === val) ? ' selected' : '';
            html += '<option value="' + id + '"' + selected + '>' + escapeHtml(name) + '</option>';
        });
        html += '</select>';
        return html;
    }

    function handleInlineCategoryChange($select) {
        var rowId = $select.data('row-id');
        var val = $select.val();
        var csrfToken = $j('#csrf-token').val() || '';

        $select.prop('disabled', true);
        $j.ajax({
            url: '/ajax/import-auditions/fact_update.cfm?bypass=1',
            type: 'POST',
            contentType: 'application/json',
            headers: csrfToken ? { 'X-CSRF-Token': csrfToken } : {},
            data: JSON.stringify({
                job_id: state.jobId,
                row_id: rowId,
                fields: { audsubcatid: val },
                csrf_token: csrfToken
            }),
            success: function(response) {
                $select.prop('disabled', false);
                if (cfGet(response, 'success')) {
                    // Update visual state
                    if (val) {
                        $select.removeClass('is-invalid');
                    } else {
                        $select.addClass('is-invalid');
                    }
                    // Refresh to update status badges and stats
                    loadRows();
                } else {
                    showAlert('error', cfGet(response, 'message') || 'Update failed');
                }
            },
            error: function(xhr) {
                $select.prop('disabled', false);
                showErrorWithDebug(xhr, 'Category update failed.');
            }
        });
    }

    function loadRows() {
        console.log('[AUD] Loading rows for job:', state.jobId, 'Filter:', state.currentFilter);

        // Show loading indicator
        $j('#review-tbody').html('<tr><td colspan="9" class="text-center p-4"><i class="fe-loader fe-spin"></i> Loading rows...</td></tr>');

        var url = '/ajax/import-auditions/rows.cfm?bypass=1&job_id=' + state.jobId +
            '&status=' + encodeURIComponent(state.currentFilter) +
            '&page=' + state.currentPage +
            '&limit=' + state.pageSize +
            (state.searchQuery ? '&search=' + encodeURIComponent(state.searchQuery) : '');

        $j.get(url, function(response) {
            console.log('[AUD] ========== ROWS RESPONSE ==========');
            console.log('[AUD] Rows response:', response);
            console.log('[AUD] Rows success:', cfGet(response, 'success'), 'Code:', cfGet(response, 'code'));
            // Log debug breadcrumbs if present (handle both cases - CF returns uppercase)
            var data = cfGet(response, 'data') || {};
            var debugTrail = cfGet(data, 'debug');
            if (debugTrail) {
                console.log('[AUD] Debug trail:', debugTrail.join(' -> '));
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
                console.error('[AUD] Load rows failed with code:', cfGet(response, 'code'));
                $j('#review-tbody').html('<tr><td colspan="9" class="text-center text-danger">' + escapeHtml(cfGet(response, 'message') || 'Unknown error') + '</td></tr>');
            }
        }).fail(function(xhr, status, error) {
            console.error('[AUD] Load rows HTTP error:', xhr.status, status, error);
            $j('#review-tbody').html('<tr><td colspan="9" class="text-center text-danger">Failed to load rows. Please refresh the page.</td></tr>');
        });
    }

    // Helper to get value from object with case-insensitive key lookup
    function getVal(obj, key) {
        if (!obj) return '';
        return obj[key] || obj[key.toUpperCase()] || obj[key.toLowerCase()] || '';
    }

    function renderRows(rows) {
        if (!rows || rows.length === 0) {
            $j('#review-tbody').html('<tr><td colspan="9" class="text-center text-muted p-4">No rows found</td></tr>');
            return;
        }

        var html = '';
        rows.forEach(function(row) {
            var data = row.data || row.DATA || {};
            var validation = row.validation || row.VALIDATION || {};
            var rowId = row.row_id || row.ROW_ID;
            var rowNum = row.row_num || row.ROW_NUM;
            var rowStatus = row.status || row.STATUS;
            var bestMatchScore = row.best_match_score || row.BEST_MATCH_SCORE;
            var createdAuditionId = row.created_auditionid || row.CREATED_AUDITIONID || row.created_audition_id || row.CREATED_AUDITION_ID;
            var errors = row.errors || row.ERRORS || [];
            var duplicates = row.duplicates || row.DUPLICATES || [];

            var project = getVal(data, 'project_name') || '-';
            var role = getVal(data, 'role_name') || '-';
            var audDate = getVal(data, 'audition_date') || '-';
            var contact = getVal(data, 'contact_name') || '-';
            var audsubcatid = getVal(data, 'audsubcatid') || '';

            var rowClass = rowStatus === 'imported' ? 'table-light' : (rowStatus === 'ignored' ? 'table-light text-muted' : '');
            html += '<tr data-row-id="' + rowId + '" class="' + rowClass + '">';
            html += '<td><input type="checkbox" class="row-checkbox" data-row-id="' + rowId + '" value="' + rowId + '"';
            if (rowStatus === 'imported' || rowStatus === 'ignored') html += ' disabled';
            html += '></td>';
            html += '<td>' + rowNum + '</td>';
            html += '<td>' + escapeHtml(project) + '</td>';
            html += '<td>' + escapeHtml(role) + '</td>';
            html += '<td>' + escapeHtml(audDate) + '</td>';
            html += '<td>' + escapeHtml(contact) + '</td>';

            // Category inline dropdown
            html += '<td>';
            if (rowStatus === 'imported') {
                var catName = getCategoryNameById(audsubcatid);
                html += catName ? escapeHtml(catName) : '<span class="text-muted">-</span>';
            } else if (rowStatus === 'ignored') {
                var catName2 = getCategoryNameById(audsubcatid);
                html += catName2 ? '<span class="text-muted">' + escapeHtml(catName2) + '</span>' : '<span class="text-muted">-</span>';
            } else {
                html += buildCategorySelect(rowId, audsubcatid, false);
            }
            html += '</td>';

            html += '<td><span class="status-badge status-' + rowStatus + '">' + rowStatus + '</span></td>';
            html += '<td>';

            if (rowStatus === 'ready') {
                html += '<button class="btn btn-xs btn-outline-primary btn-edit" data-row-id="' + rowId + '" title="Edit"><i class="fe-edit"></i></button> ';
                html += '<button class="btn btn-xs btn-outline-secondary btn-exclude" data-row-id="' + rowId + '" title="Exclude from import"><i class="fe-x-circle"></i></button> ';
            } else if (rowStatus === 'problem') {
                html += '<button class="btn btn-xs btn-outline-primary btn-edit" data-row-id="' + rowId + '" title="Edit & fix"><i class="fe-edit"></i></button> ';
                html += '<button class="btn btn-xs btn-outline-secondary btn-exclude" data-row-id="' + rowId + '" title="Exclude from import"><i class="fe-x-circle"></i></button> ';
            } else if (rowStatus === 'dupe') {
                html += '<button class="btn btn-xs btn-outline-warning btn-resolve-dupe" data-row-id="' + rowId + '" title="Resolve duplicate"><i class="fe-users"></i></button> ';
            } else if (rowStatus === 'ignored') {
                html += '<button class="btn btn-xs btn-outline-success btn-restore" data-row-id="' + rowId + '" title="Include in import"><i class="fe-check-circle"></i></button> ';
            } else if (rowStatus === 'imported' && createdAuditionId) {
                html += '<a href="/app/audition/?audprojectid=' + createdAuditionId + '" class="btn btn-xs btn-outline-info" title="View audition"><i class="fe-eye"></i></a> ';
                html += '<button class="btn btn-xs btn-outline-warning btn-undo" data-row-id="' + rowId + '" title="Undo import"><i class="fe-rotate-ccw"></i></button>';
            }

            html += '</td>';
            html += '</tr>';

            // Show validation errors
            if (rowStatus === 'problem' && errors && errors.length > 0) {
                html += '<tr class="bg-light"><td colspan="9">';
                html += '<small class="text-danger">';
                errors.forEach(function(err) {
                    var errField = err.field || err.FIELD || '';
                    var errMsg = err.message || err.MESSAGE || '';
                    html += '<i class="fe-alert-circle"></i> <strong>' + escapeHtml(errField) + ':</strong> ' + escapeHtml(errMsg) + '<br>';
                });
                html += '</small></td></tr>';
            }

            // Show duplicate info
            if (rowStatus === 'dupe' && duplicates && duplicates.length > 0) {
                html += '<tr class="bg-warning-light"><td colspan="9">';
                html += '<small class="text-warning"><i class="fe-alert-triangle"></i> ';
                var dupeProject = duplicates[0].project_name || duplicates[0].PROJECT_NAME || 'Unknown';
                var dupeRole = duplicates[0].role_name || duplicates[0].ROLE_NAME || '';
                var dupeDate = duplicates[0].audition_date || duplicates[0].AUDITION_DATE || '';
                var dupeLabel = dupeProject;
                if (dupeRole) dupeLabel += ' / ' + dupeRole;
                if (dupeDate) dupeLabel += ' (' + dupeDate + ')';
                html += 'Possible duplicate of: <strong>' + escapeHtml(dupeLabel) + '</strong>';
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

        // Bind inline category dropdowns
        $j('.row-category-select').on('change', function() {
            handleInlineCategoryChange($j(this));
        });

        // Bind undo buttons
        $j('.btn-undo').click(function() {
            undoImportedRow($j(this).data('row-id'));
        });

        // Update bulk edit toolbar state based on checkbox selection
        updateBulkEditToolbar();
    }

    function hasFieldError(validation, field) {
        // Handle both object format {valid: bool, error: string} and simple boolean format
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
        $j.get('/ajax/import-auditions/rows.cfm?bypass=1&job_id=' + state.jobId + '&stats_only=1', function(response) {
            console.log('[AUD] ========== STATS RESPONSE ==========');
            console.log('[AUD] Stats response:', response);
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
        console.log('[AUD] Single row action:', action, 'Row:', rowId);

        var csrfToken = $j('#csrf-token').val() || '';
        if (!csrfToken) {
            showAlert('error', 'Security token missing. Please refresh the page.');
            return;
        }

        $j.ajax({
            url: '/ajax/import-auditions/row_action.cfm?bypass=1',
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
                console.log('[AUD] Row action response:', response);
                if (response.success) {
                    loadRows();
                } else {
                    showAlert('error', response.message);
                }
            },
            error: function(xhr) {
                showErrorWithDebug(xhr, 'Row action failed.');
            }
        });
    }

    // ========================================
    // MODALS - 
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
        $j('#dupe-import-new').click(function() {
            setDupeAction('create');
        });
    }

    var currentEditRowId = 0;
    var currentEditData = {};

    function editRow(rowId) {
        console.log('[AUD] Editing row:', rowId);
        currentEditRowId = rowId;

        // Fetch single row detail - V3 ENDPOINT
        $j.get('/ajax/import-auditions/row.cfm?bypass=1&job_id=' + state.jobId + '&row_id=' + rowId, function(response) {
            console.log('[AUD] Row detail response:', response);
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
        currentEditData = row.data || {};
        var validation = row.validation || {};

        var fieldGroups = {
            'Contact': ['contact_name', 'contact_email'],
            'Project': ['project_name', 'role_name', 'audsubcatid', 'casting_director', 'agency'],
            'Schedule': ['audition_date', 'audition_time', 'callback_date', 'booking_date'],
            'Details': ['location', 'medium', 'status', 'self_tape'],
            'Other': ['notes']
        };

        // Build error lookup from row.errors array (field -> message)
        var errorLookup = {};
        (row.errors || []).forEach(function(e) {
            errorLookup[e.field] = e.message;
        });

        var html = '<form id="edit-form">';

        // Only show fields that have data or errors
        var fieldsWithData = Object.keys(currentEditData).filter(function(k) {
            return currentEditData[k] !== '' && currentEditData[k] !== null;
        });
        var fieldsWithErrors = Object.keys(validation).filter(function(k) {
            var v = validation[k];
            if (typeof v === 'boolean') return !v;
            return v && !v.valid;
        });
        var relevantFields = new Set(fieldsWithData.concat(fieldsWithErrors));

        // Always show core fields
        ['project_name', 'role_name', 'audsubcatid', 'audition_date', 'contact_name'].forEach(function(f) {
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

                var colClass = fieldDef.type === 'textarea' ? 'col-12' : 'col-md-6';

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

        bsModal('#edit-modal', 'show');
    }

    function renderFieldWidget(field, fieldDef, value, inputClass) {
        var html = '';

        switch (fieldDef.type) {
            case 'email':
                html = '<input type="email" class="form-control form-control-sm ' + inputClass + '" ' +
                    'name="' + field + '" value="' + escapeHtml(value) + '" placeholder="email@example.com">';
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

            case 'category_select':
                html = '<select class="form-control form-control-sm ' + inputClass + '" name="' + field + '">';
                html += '<option value="">-- Select Category --</option>';
                var currentVal = value ? parseInt(value) : 0;
                categoryOptions.forEach(function(opt) {
                    var id = opt.audsubcatid || opt.AUDSUBCATID;
                    var name = opt.audcatname || opt.AUDCATNAME;
                    var selected = (parseInt(id) === currentVal) ? ' selected' : '';
                    html += '<option value="' + id + '"' + selected + '>' + escapeHtml(name) + '</option>';
                });
                html += '</select>';
                break;

            case 'textarea':
                html = '<textarea class="form-control form-control-sm ' + inputClass + '" ' +
                    'name="' + field + '" rows="3">' + escapeHtml(value) + '</textarea>';
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

    function saveEdit() {
        var data = {};

        $j('#edit-form input, #edit-form select, #edit-form textarea').each(function() {
            var name = $j(this).attr('name');
            if (name) {
                data[name] = $j(this).val();
            }
        });

        console.log('[AUD] Saving edit for row:', currentEditRowId, 'Data:', data);

        // Get CSRF token for fact_update
        var csrfToken = $j('#csrf-token').val() || '';
        if (!csrfToken) {
            console.error('[AUD] CSRF token not found for fact_update');
            showAlert('error', 'Security token missing. Please refresh the page.');
            return;
        }

        var $btn = $j('#edit-save');
        $btn.prop('disabled', true).html('<i class="fe-loader fe-spin"></i> Saving...');

        // fact_update for individual field updates
        $j.ajax({
            url: '/ajax/import-auditions/fact_update.cfm?bypass=1',
            type: 'POST',
            contentType: 'application/json',
            headers: {
                'X-CSRF-Token': csrfToken  // Header CSRF (preferred)
            },
            data: JSON.stringify({
                job_id: state.jobId,
                row_id: currentEditRowId,
                fields: data,
                csrf_token: csrfToken  // Body CSRF (fallback)
            }),
            success: function(response) {
                console.log('[AUD] Save response:', response);
                // Log debug breadcrumbs if present
                if (response.data && response.data.debug) {
                    console.log('[AUD] Debug trail:', response.data.debug.join(' -> '));
                }
                $btn.prop('disabled', false).html('<i class="fe-check"></i> Save Changes');
                if (response.success) {
                    bsModal('#edit-modal', 'hide');
                    showAlert('success', 'Row updated and revalidated');
                    loadRows();
                } else {
                    console.error('[AUD] Fact update failed with code:', response.code);
                    showAlert('error', response.message || 'Validation failed');
                }
            },
            error: function(xhr, status, error) {
                console.error('[AUD] Save error:', xhr.status, status, error);
                $btn.prop('disabled', false).html('<i class="fe-check"></i> Save Changes');
                showErrorWithDebug(xhr, 'Failed to save.');
            }
        });
    }

    var currentDupeRowId = 0;

    function resolveDupe(rowId) {
        console.log('[AUD] Resolving duplicate for row:', rowId);
        currentDupeRowId = rowId;

      
        $j.get('/ajax/import-auditions/row.cfm?bypass=1&job_id=' + state.jobId + '&row_id=' + rowId, function(response) {
            console.log('[AUD] Dupe row response:', response);
            if (!response.success || !response.data.row) return;

            var row = response.data.row;
            var data = row.data || {};
            var dupes = row.duplicates || [];

            var html = '<div class="row">';

            // Import row
            html += '<div class="col-md-6">';
            html += '<h6>Importing:</h6>';
            html += '<table class="table table-sm">';
            html += '<tr><td><strong>Project</strong></td><td>' + escapeHtml(data.project_name || '-') + '</td></tr>';
            html += '<tr><td><strong>Role</strong></td><td>' + escapeHtml(data.role_name || '-') + '</td></tr>';
            html += '<tr><td><strong>Date</strong></td><td>' + escapeHtml(data.audition_date || '-') + '</td></tr>';
            html += '<tr><td><strong>Casting Director</strong></td><td>' + escapeHtml(data.casting_director || '-') + '</td></tr>';
            html += '<tr><td><strong>Contact</strong></td><td>' + escapeHtml(data.contact_name || '-') + '</td></tr>';
            html += '</table>';
            html += '</div>';

            // Existing audition
            if (dupes.length > 0) {
                var match = dupes[0];
                html += '<div class="col-md-6">';
                html += '<h6>Existing Audition' + (row.best_match_score ? ' (Score: ' + row.best_match_score + ')' : '') + ':</h6>';
                html += '<table class="table table-sm">';
                html += '<tr><td><strong>Project</strong></td><td>' + escapeHtml(match.project_name || match.PROJECT_NAME || '-') + '</td></tr>';
                html += '<tr><td><strong>Role</strong></td><td>' + escapeHtml(match.role_name || match.ROLE_NAME || '-') + '</td></tr>';
                html += '<tr><td><strong>Date</strong></td><td>' + escapeHtml(match.audition_date || match.AUDITION_DATE || '-') + '</td></tr>';
                html += '<tr><td><strong>Casting Director</strong></td><td>' + escapeHtml(match.casting_director || match.CASTING_DIRECTOR || '-') + '</td></tr>';
                html += '</table>';
                if (match.reasons && match.reasons.length > 0) {
                    html += '<p class="text-muted small">Match reasons: ' + match.reasons.join(', ') + '</p>';
                }
                var auditionId = match.audition_id || match.AUDITION_ID || match.auditionid || match.AUDITIONID || '';
                if (auditionId) {
                    html += '<a href="/app/audition/?audprojectid=' + auditionId + '" target="_blank" class="btn btn-xs btn-outline-info">View Audition</a>';
                }
                html += '</div>';
            }

            html += '</div>';

            $j('#dupe-modal-body').html(html);
            bsModal('#dupe-modal', 'show');
        });
    }

    function setDupeAction(action) {
        console.log('[AUD] Setting dupe action:', action, 'for row:', currentDupeRowId);

        // Get CSRF token for row_action
        var csrfToken = $j('#csrf-token').val() || '';
        if (!csrfToken) {
            console.error('[AUD] CSRF token not found for dupe action');
            showAlert('error', 'Security token missing. Please refresh the page.');
            return;
        }

      
        $j.ajax({
            url: '/ajax/import-auditions/row_action.cfm?bypass=1',
            type: 'POST',
            contentType: 'application/json',
            headers: {
                'X-CSRF-Token': csrfToken  // Header CSRF (preferred)
            },
            data: JSON.stringify({
                job_id: state.jobId,
                row_id: currentDupeRowId,
                action: action,
                csrf_token: csrfToken  // Body CSRF (fallback)
            }),
            success: function(response) {
                console.log('[AUD] Row action response:', response);
                // Log debug breadcrumbs if present
                if (response.data && response.data.debug) {
                    console.log('[AUD] Debug trail:', response.data.debug.join(' -> '));
                }
                bsModal('#dupe-modal', 'hide');
                if (response.success) {
                    loadRows();
                } else {
                    console.error('[AUD] Dupe action failed with code:', response.code);
                    showAlert('error', response.message);
                }
            },
            error: function(xhr, status, error) {
                console.error('[AUD] Dupe action HTTP error:', xhr.status, status, error);
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
        console.log('[AUD] Changing job status:', jobId, '->', newStatus);

        var csrfToken = $j('#csrf-token').val() || '';
        // For history page actions where csrf-token hidden input may not exist,
        // generate one or skip CSRF (server will handle)
        
        $j.ajax({
            url: '/ajax/import-auditions/status.cfm?bypass=1',
            type: 'POST',
            contentType: 'application/json',
            headers: csrfToken ? { 'X-CSRF-Token': csrfToken } : {},
            data: JSON.stringify({
                job_id: jobId,
                new_status: newStatus,
                csrf_token: csrfToken
            }),
            success: function(response) {
                console.log('[AUD] Status change response:', response);
                if (response.data && response.data.debug) {
                    console.log('[AUD] Debug trail:', response.data.debug.join(' -> '));
                }
                if (response.success) {
                    showAlert('success', response.message || 'Status updated');
                    setTimeout(function() {
                        if (reloadPage || newStatus === 'cancelled') {
                            window.location.href = '/app/auditions-import/';
                        } else {
                            window.location.reload();
                        }
                    }, 1000);
                } else {
                    console.error('[AUD] Status change failed:', response.code, response.message);
                    showAlert('error', response.message || 'Status change failed');
                }
            },
            error: function(xhr, status, error) {
                console.error('[AUD] Status change HTTP error:', xhr.status, status, error);
                showErrorWithDebug(xhr, 'Status change failed.');
            }
        });
    }

    // ========================================
    // FINALIZE - 
    // ========================================

    function finalizeImport() {
        var readyCount = state.stats.ready || 0;
        var problemCount = state.stats.problem || 0;
        var dupeCount = state.stats.dupe || 0;
        var ignoredCount = state.stats.ignored || 0;

        var msg = 'Import ' + readyCount + ' audition' + (readyCount !== 1 ? 's' : '') + '?\n\n';
        msg += readyCount + ' will be imported\n';
        if (problemCount > 0) msg += problemCount + ' with errors will be skipped\n';
        if (dupeCount > 0) msg += dupeCount + ' unresolved duplicates will be skipped\n';
        if (ignoredCount > 0) msg += ignoredCount + ' excluded by you\n';
        msg += '\nYou can undo individual rows after import.';

        if (!confirm(msg)) {
            return;
        }

        console.log('[AUD] Finalizing import for job:', state.jobId);

        // Get CSRF token from hidden input
        var csrfToken = $j('#csrf-token').val() || '';
        if (!csrfToken) {
            console.error('[AUD] CSRF token not found in #csrf-token input');
            showAlert('error', 'Security token missing. Please refresh the page and try again.');
            return;
        }

        // Enhanced progress UI with timing message for large imports
        var $btn = $j('#btn-finalize');
        var $progress = $j('#finalize-progress');
        $btn.prop('disabled', true).html('<i class="fe-loader fe-spin"></i> Importing...');
        $progress.show();

        // Show timing message for large imports (over 100 rows)
        if (readyCount > 100) {
            showAlert('info', 'Importing ' + readyCount + ' auditions. This may take a moment...');
        }

        // V3 ENDPOINT - send csrf_token in BOTH header AND body (belt+suspenders)
        var requestPayload = {
            job_id: state.jobId,
            csrf_token: csrfToken
        };
        console.log('[AUD] ========== FINALIZE REQUEST ==========');
        console.log('[AUD] Finalize payload:', JSON.stringify(requestPayload));
        $j.ajax({
            url: '/ajax/import-auditions/finalize.cfm?bypass=1',  
            type: 'POST',
            contentType: 'application/json',
            dataType: 'json',
            headers: {
                'X-CSRF-Token': csrfToken  // Header CSRF (preferred)
            },
            data: JSON.stringify(requestPayload),
            success: function(response) {
                console.log('[AUD] ========== FINALIZE RESPONSE ==========');
                console.log('[AUD] Finalize response:', response);
                // Log debug breadcrumbs if present
                if (response.data && response.data.debug) {
                    console.log('[AUD] Debug trail:', response.data.debug.join(' -> '));
                }
                $j('#finalize-progress').hide();

                if (response.success || response.SUCCESS) {
                    // Log import counts for debugging
                    var respData = response.data || response.DATA || {};
                    if (respData.counts || respData.COUNTS) {
                        var c = respData.counts || respData.COUNTS;
                        console.log('[AUD] Finalize counts: imported_new=' + (c.imported_new || c.IMPORTED_NEW || 0) +
                            ' updated=' + (c.updated_existing || c.UPDATED_EXISTING || 0) +
                            ' skipped_already=' + (c.skipped_already_imported || c.SKIPPED_ALREADY_IMPORTED || 0) +
                            ' failed=' + (c.failed || c.FAILED || 0));
                    }
                    if (respData.warnings || respData.WARNINGS) {
                        var w = respData.warnings || respData.WARNINGS || [];
                        if (w.length > 0) {
                            console.warn('[AUD] Finalize warnings:', w);
                        }
                    }
                    showAlert('success', response.message || response.MESSAGE || 'Import completed successfully!');
                    setTimeout(function() {
                        window.location.reload();
                    }, 1500);
                } else {
                    var errCode = response.code || response.CODE || 'UNKNOWN';
                    var errMsg = response.message || response.MESSAGE || 'Import failed';
                    console.error('[AUD] Finalize failed with code:', errCode, 'message:', errMsg);
                    console.error('[AUD] Full failure response:', JSON.stringify(response));
                    // Handle specific error codes with better UX
                    if (errCode === 'NO_ROWS_ELIGIBLE') {
                        showAlert('warning', errMsg || 'No rows are ready for import. Please review and approve rows first.');
                    } else {
                        showAlert('error', errMsg);
                    }
                    $j('#btn-finalize').prop('disabled', false).html('<i class="fe-check-circle"></i> Import <span id="import-count">' + (state.stats.ready || '...') + '</span> Auditions');
                }
            },
            error: function(xhr, status, error) {
                console.error('[AUD] ========== FINALIZE ERROR ==========');
                console.error('[AUD] Finalize HTTP error:', xhr.status, status, error);
                console.error('[AUD] Response text (first 2000 chars):', (xhr.responseText || '').substring(0, 2000));
                // Try to parse response even on error
                try {
                    var errResp = JSON.parse(xhr.responseText);
                    console.error('[AUD] Parsed error response:', errResp);
                    if (errResp.data && errResp.data.debug) {
                        console.error('[AUD] Error debug trail:', errResp.data.debug.join(' -> '));
                    }
                } catch(e) {
                    console.error('[AUD] Response is not JSON');
                }
                showErrorWithDebug(xhr, 'Import failed.');
                $j('#finalize-progress').hide();
                $j('#btn-finalize').prop('disabled', false);
            }
        });
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
        if (!document.getElementById('aud-toast-container')) {
            $j('body').append('<div id="aud-toast-container" style="position:fixed;top:20px;right:20px;z-index:99999;max-width:420px;"></div>');
        }

        var id = 'aud-alert-' + Date.now();
        var html = '<div id="' + id + '" style="background:' + c.bg + ';border:1px solid ' + c.border + ';color:' + c.text + ';' +
            'padding:12px 40px 12px 16px;border-radius:6px;margin-bottom:10px;position:relative;' +
            'box-shadow:0 4px 12px rgba(0,0,0,0.15);font-size:14px;opacity:0;transition:opacity 0.3s ease;">' +
            '<i class="' + icon + '" style="margin-right:8px;"></i>' + message +
            '<span style="position:absolute;top:8px;right:12px;cursor:pointer;font-size:18px;line-height:1;opacity:0.6;" ' +
            'onclick="this.parentElement.remove()">&times;</span></div>';

        $j('#aud-toast-container').append(html);

        // Fade in
        setTimeout(function() { document.getElementById(id).style.opacity = '1'; }, 10);

        // Auto-dismiss after 5 seconds
        setTimeout(function() {
            var el = document.getElementById(id);
            if (el) { el.style.opacity = '0'; setTimeout(function() { if (el.parentNode) el.remove(); }, 300); }
        }, 15000);
    }

    // ========================================
    // UNDO IMPORTED ROW (V2 Feature)
    // ========================================

    function undoImportedRow(rowId) {
        window.taoConfirmDelete('Undo this import? The created audition project, role, and event will be deleted.', function() {
            performUndoImportedRow(rowId);
        });
    }

    function performUndoImportedRow(rowId) {
        console.log('[AUD] Undoing imported row:', rowId);

        var csrfToken = $j('#csrf-token').val() || '';
        if (!csrfToken) {
            showAlert('error', 'Security token missing. Please refresh the page.');
            return;
        }

        var $btn = $j('.btn-undo[data-row-id="' + rowId + '"]');
        $btn.prop('disabled', true).html('<i class="fe-loader fe-spin"></i>');

        $j.ajax({
            url: '/ajax/import-auditions/undo.cfm?bypass=1',
            type: 'POST',
            contentType: 'application/json',
            dataType: 'json',
            headers: { 'X-CSRF-Token': csrfToken },
            data: JSON.stringify({ row_id: rowId, csrf_token: csrfToken }),
            success: function(response) {
                if (cfGet(response, 'success')) {
                    showAlert('success', cfGet(response, 'message') || 'Import undone successfully.');
                    // Reload the current view to show updated row status
                    loadRows();
                } else {
                    showAlert('error', cfGet(response, 'message') || 'Undo failed.');
                    $btn.prop('disabled', false).html('<i class="fe-rotate-ccw"></i>');
                }
            },
            error: function(xhr) {
                showErrorWithDebug(xhr, 'Undo failed.');
                $btn.prop('disabled', false).html('<i class="fe-rotate-ccw"></i>');
            }
        });
    }

    // ========================================
    // BULK FIELD EDITING (V2 Feature)
    // ========================================

    function initBulkEdit() {
        // Select-all checkbox
        $j(document).on('change', '#select-all-rows', function() {
            var checked = this.checked;
            $j('.row-checkbox:not(:disabled)').prop('checked', checked);
            updateBulkEditToolbar();
        });

        // Individual checkbox change
        $j(document).on('change', '.row-checkbox', function() {
            updateBulkEditToolbar();
            // Update select-all state
            var total = $j('.row-checkbox:not(:disabled)').length;
            var checked = $j('.row-checkbox:checked').length;
            $j('#select-all-rows').prop('checked', total > 0 && checked === total);
        });

        // Apply bulk edit button
        $j('#btn-apply-bulk-edit').click(function() {
            applyBulkEdit();
        });

        // Show/hide value input based on field selection
        $j('#bulk-edit-field').change(function() {
            var field = $j(this).val();
            var $valueInput = $j('#bulk-edit-value');
            var $valueSelect = $j('#bulk-edit-value-select');

            $valueInput.hide().val('');
            $valueSelect.hide().val('');

            if (!field) return;

            var def = fieldDefinitions[field];
            if (def && def.type === 'select' && def.options) {
                // Build select options
                var html = '';
                def.options.forEach(function(opt) {
                    html += '<option value="' + escapeHtml(opt.value) + '">' + escapeHtml(opt.label) + '</option>';
                });
                $valueSelect.html(html).show();
            } else if (def && def.type === 'date') {
                $valueInput.attr('type', 'date').show();
            } else {
                $valueInput.attr('type', 'text').show();
            }
        });
    }

    function getSelectedRowIds() {
        var ids = [];
        $j('.row-checkbox:checked').each(function() {
            ids.push(parseInt($j(this).val()));
        });
        return ids;
    }

    function updateBulkEditToolbar() {
        var selectedCount = $j('.row-checkbox:checked').length;
        $j('#bulk-edit-selected-count').text(selectedCount);
        if (selectedCount > 0) {
            $j('#bulk-edit-toolbar').css('display', 'flex');
        } else {
            $j('#bulk-edit-toolbar').hide();
        }
    }

    function applyBulkEdit() {
        var rowIds = getSelectedRowIds();
        if (rowIds.length === 0) {
            showAlert('warning', 'No rows selected.');
            return;
        }

        var fieldKey = $j('#bulk-edit-field').val();
        if (!fieldKey) {
            showAlert('warning', 'Please select a field to edit.');
            return;
        }

        // Get value from either text input or select dropdown
        var newValue = '';
        if ($j('#bulk-edit-value-select').is(':visible')) {
            newValue = $j('#bulk-edit-value-select').val();
        } else {
            newValue = $j('#bulk-edit-value').val();
        }

        var csrfToken = $j('#csrf-token').val() || '';
        if (!csrfToken) {
            showAlert('error', 'Security token missing. Please refresh the page.');
            return;
        }

        var fieldLabel = fieldDefinitions[fieldKey] ? fieldDefinitions[fieldKey].label : fieldKey;
        if (!confirm('Set "' + fieldLabel + '" to "' + newValue + '" for ' + rowIds.length + ' row(s)?')) {
            return;
        }

        var $btn = $j('#btn-apply-bulk-edit');
        $btn.prop('disabled', true).html('<i class="fe-loader fe-spin"></i> Applying...');

        $j.ajax({
            url: '/ajax/import-auditions/bulk_edit.cfm?bypass=1',
            type: 'POST',
            contentType: 'application/json',
            dataType: 'json',
            headers: { 'X-CSRF-Token': csrfToken },
            data: JSON.stringify({
                job_id: state.jobId,
                row_ids: rowIds,
                field_key: fieldKey,
                new_value: newValue,
                csrf_token: csrfToken
            }),
            success: function(response) {
                $btn.prop('disabled', false).html('<i class="fe-check"></i> Apply to Selected');
                if (cfGet(response, 'success')) {
                    var data = cfGet(response, 'data') || {};
                    var updatedCount = cfGet(data, 'updated_count') || 0;
                    showAlert('success', updatedCount + ' row(s) updated.');
                    // Clear selection and reload
                    $j('#select-all-rows').prop('checked', false);
                    loadRows();
                } else {
                    showAlert('error', cfGet(response, 'message') || 'Bulk edit failed.');
                }
            },
            error: function(xhr) {
                $btn.prop('disabled', false).html('<i class="fe-check"></i> Apply to Selected');
                showErrorWithDebug(xhr, 'Bulk edit failed.');
            }
        });
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
            console.log('[AUD] Correlation ID: ' + correlationId + ' (use this to search server logs)');
        }

        // Log debug trail to console
        if (debugTrail.length > 0) {
            console.group('[AUD] Debug trail (cid=' + correlationId + ')');
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
            console.log('[AUD] Phase times:', phaseTimes);
        }
        if (firstFailure && typeof firstFailure === 'object' && Object.keys(firstFailure).length > 0) {
            console.log('[AUD] First failure:', firstFailure);
        }
    }

})();
