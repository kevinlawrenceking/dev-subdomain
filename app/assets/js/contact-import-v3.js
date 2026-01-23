/**
 * Contact Import V3 - JavaScript Controller
 * Handles file upload, parsing, review grid, and import finalization
 *
 * V3 ENDPOINTS - All calls go to /ajax/importv3/ namespace
 */

(function() {
    'use strict';

    // Local jQuery alias (works even if the page uses jQuery.noConflict() so $ is not global)
    var $;

    console.log('[V3] Contact Import V3 JavaScript loaded');
    console.log('[V3] jQuery available at load time:', typeof window.jQuery !== 'undefined');
    console.log('[V3] $ available at load time:', typeof window.$ !== 'undefined');

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

    // Initialize on DOM ready - wait for jQuery if not yet loaded
    function initV3() {
        // Bind local $ to jQuery (handles noConflict pages)
        $ = window.jQuery;

        console.log('[V3] Initializing Contact Import V3...');
        initUpload();
        initJobActions();
        initReviewGrid();
        initModals();

        // Check for active job
        var jobIdInput = document.getElementById('job-id');
        if (jobIdInput) {
            state.jobId = parseInt(jobIdInput.value);
            var status = document.getElementById('job-status').value;
            console.log('[V3] Active job:', state.jobId, 'Status:', status);

            if (status === 'parsed' || status === 'mapping') {
                loadColumnMappings();
            } else if (status === 'reviewing' || status === 'finalizing' || status === 'completed') {
                loadRows();
            }
        }
    }

    // Wait for jQuery to be available before initializing
    function waitForJQuery(callback) {
        console.log('[V3] waitForJQuery check - jQuery available:', typeof window.jQuery !== 'undefined');
        if (typeof window.jQuery !== 'undefined') {
            console.log('[V3] jQuery found, calling $(document).ready()');
            window.jQuery(document).ready(callback);
        } else {
            // jQuery not loaded yet, wait and retry
            console.log('[V3] jQuery not yet available, retrying in 50ms...');
            setTimeout(function() {
                waitForJQuery(callback);
            }, 50);
        }
    }

    console.log('[V3] Calling waitForJQuery...');
    waitForJQuery(initV3);

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
                    window.location.href = '/app/contacts-import-v3/?job_id=' + response.data.job_id;
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
        // Parse button
        $('#btn-parse').click(function() {
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
        console.log('[V3] Parsing file for job:', state.jobId);
        $('#btn-parse').prop('disabled', true);
        $('#parse-progress').show();

        $.ajax({
            url: '/ajax/importv3/parse.cfm',  // V3 ENDPOINT
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ job_id: state.jobId }),
            success: function(response) {
                console.log('[V3] Parse response:', response);
                if (response.success) {
                    // Reload page to show mapping step
                    window.location.reload();
                } else {
                    showAlert('error', response.message || 'Parsing failed');
                    $('#btn-parse').prop('disabled', false);
                    $('#parse-progress').hide();
                }
            },
            error: function(xhr) {
                console.error('[V3] Parse error:', xhr.responseText);
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
            $('#review-tbody').html('<tr><td colspan="8
