<!---
    Contact Import V2 - Main Import Page
    Features:
    - File upload (CSV, XLS, XLSX, VCF/vCard)
    - Google Contacts CSV and Apple/iCloud vCard support
    - Column mapping review with auto-detection
    - Review grid with inline editing
    - Duplicate detection and resolution
    - Dry-run preview before import
    - Relationship system enrollment (Target/Maintenance)
    - Finalize import
--->

<cfparam name="url.job_id" default="0">

<!--- Check for existing job --->
<cfset hasActiveJob = false>
<cfset activeJob = {}>

<cfif isNumeric(url.job_id) and url.job_id gt 0>
    <cfset importService = new services.ContactImportV2Service()>
    <cfset activeJob = importService.getJob(url.job_id)>
    <cfif activeJob.found and activeJob.userid eq userid>
        <cfset hasActiveJob = true>
    </cfif>
</cfif>

<!--- Get import history --->
<cfif not hasActiveJob>
    <cfset importService = new services.ContactImportV2Service()>
    <cfset importHistory = importService.getJobsByUser(userid)>
</cfif>

<style>
.import-step {
    padding: 20px;
    margin-bottom: 20px;
    border-radius: 8px;
    background: #fff;
    border: 1px solid #e3e3e3;
}
.import-step.disabled {
    opacity: 0.5;
    pointer-events: none;
}
.import-step h5 {
    margin-bottom: 15px;
    font-weight: 600;
}
.import-step .step-number {
    display: inline-block;
    width: 28px;
    height: 28px;
    background: #406e8e;
    color: #fff;
    border-radius: 50%;
    text-align: center;
    line-height: 28px;
    margin-right: 10px;
    font-size: 14px;
}
.import-step.completed .step-number {
    background: #28a745;
}

/* File upload area */
.upload-area {
    border: 2px dashed #ccc;
    border-radius: 8px;
    padding: 40px;
    text-align: center;
    cursor: pointer;
    transition: all 0.2s;
}
.upload-area:hover, .upload-area.dragover {
    border-color: #406e8e;
    background: #f8f9fa;
}
.upload-area .upload-icon {
    font-size: 48px;
    color: #ccc;
    margin-bottom: 10px;
}

/* Review grid */
.review-tabs {
    margin-bottom: 20px;
}
.review-tabs .nav-link {
    font-weight: 500;
}
.review-tabs .nav-link .badge {
    margin-left: 5px;
}

.review-table {
    font-size: 14px;
}
.review-table th {
    white-space: nowrap;
}
.review-table td {
    vertical-align: middle;
}
.review-table .field-error {
    border-color: #dc3545 !important;
}
.review-table .field-warning {
    border-color: #ffc107 !important;
}

.status-badge {
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 500;
}
.status-ready { background: #d4edda; color: #155724; }
.status-problem { background: #f8d7da; color: #721c24; }
.status-dupe { background: #fff3cd; color: #856404; }
.status-ignored { background: #e2e3e5; color: #383d41; }
.status-imported { background: #cce5ff; color: #004085; }

/* Duplicate panel */
.dupe-panel {
    background: #fffcf0;
    border: 1px solid #ffc107;
    border-radius: 4px;
    padding: 10px;
    margin-top: 10px;
}
.dupe-candidate {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px;
    background: #fff;
    border-radius: 4px;
    margin-bottom: 8px;
}
.dupe-score {
    font-weight: bold;
    color: #856404;
}

/* Progress */
.import-progress {
    margin: 20px 0;
}
.import-progress .progress {
    height: 10px;
}

/* Inline editing */
.inline-edit {
    cursor: pointer;
    padding: 2px 5px;
    border-radius: 3px;
}
.inline-edit:hover {
    background: #f0f0f0;
}
.inline-edit.editing {
    background: #fff;
    border: 1px solid #406e8e;
}

/* Warning state for validation warnings */
.is-warning {
    border-color: #ffc107 !important;
    background-color: #fffdf5 !important;
}
.text-warning {
    color: #856404 !important;
}

/* Edit modal field groups */
.edit-field-group h6 {
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.edit-field-group .form-label {
    margin-bottom: 2px;
    font-weight: 500;
}

/* Phone input styling */
.phone-input::placeholder {
    color: #adb5bd;
}

/* Date input */
input[type="date"].form-control-sm {
    padding-top: 0.2rem;
    padding-bottom: 0.2rem;
}
</style>

<div class="row">
    <div class="col-12">
        <div class="page-title-box">
            <h4 class="page-title">Import Contacts</h4>
        </div>
    </div>
</div>

<cfif not hasActiveJob>
    <!--- UPLOAD STEP --->
    <div class="import-step" id="step-upload">
        <h5><span class="step-number">1</span> Upload File</h5>
        <p class="text-muted">Upload your contacts file (max 50MB)</p>

        <div class="upload-area" id="upload-area">
            <div class="upload-icon"><i class="fe-upload-cloud"></i></div>
            <p><strong>Drag and drop your file here</strong></p>
            <p class="text-muted">or click to browse</p>
            <p class="text-muted small">Supported formats: CSV, XLS, XLSX, VCF (vCard)<br>Google Contacts and Apple/iCloud exports supported</p>
            <input type="file" id="file-input" accept=".csv,.xls,.xlsx,.vcf" style="display:none">
        </div>

        <div class="import-progress" id="upload-progress" style="display:none">
            <div class="progress">
                <div class="progress-bar progress-bar-striped progress-bar-animated" role="progressbar" style="width: 0%"></div>
            </div>
            <p class="mt-2 text-center" id="upload-status">Uploading...</p>
        </div>
    </div>

    <!--- Download template link --->
    <div class="text-center mb-4">
        <a href="/include/download_contact_template.cfm" class="btn btn-outline-secondary btn-sm">
            <i class="fe-download"></i> Download Import Template
        </a>
    </div>

    <!--- IMPORT HISTORY --->
    <cfif importHistory.recordCount gt 0>
    <div class="card">
        <div class="card-body">
            <h5>Import History</h5>
            <table class="table table-sm">
                <thead>
                    <tr>
                        <th>File</th>
                        <th>Date</th>
                        <th>Status</th>
                        <th>Rows</th>
                        <th>Imported</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <cfoutput query="importHistory">
                    <tr>
                        <td>#importHistory.source_filename#</td>
                        <td>#dateFormat(importHistory.created_at, "mm/dd/yyyy")# #timeFormat(importHistory.created_at, "h:mm tt")#</td>
                        <td>
                            <span class="status-badge status-#lcase(importHistory.status)#">#importHistory.status#</span>
                        </td>
                        <td>#importHistory.total_rows#</td>
                        <td>#importHistory.imported_rows#</td>
                        <td>
                            <cfif importHistory.status neq "completed" and importHistory.status neq "cancelled">
                                <a href="?job_id=#importHistory.job_id#" class="btn btn-xs btn-primary">Continue</a>
                            </cfif>
                        </td>
                    </tr>
                    </cfoutput>
                </tbody>
            </table>
        </div>
    </div>
    </cfif>

<cfelse>
    <!--- ACTIVE JOB --->
    <cfoutput>
    <input type="hidden" id="job-id" value="#activeJob.job_id#">
    <input type="hidden" id="job-status" value="#activeJob.status#">

    <!--- Job info bar --->
    <div class="alert alert-info d-flex justify-content-between align-items-center">
        <div>
            <strong>File:</strong> #activeJob.source_filename#
            <span class="mx-2">|</span>
            <strong>Status:</strong> <span id="current-status" class="status-badge status-#lcase(activeJob.status)#">#activeJob.status#</span>
        </div>
        <div>
            <a href="/app/contacts-import-v2/" class="btn btn-sm btn-outline-secondary">Start New Import</a>
        </div>
    </div>

    <!--- Show appropriate step based on status --->
    <cfif activeJob.status eq "pending">
        <!--- Need to parse --->
        <div class="import-step" id="step-parse">
            <h5><span class="step-number">2</span> Parsing File</h5>
            <p>Click to parse and analyze your file.</p>
            <button class="btn btn-primary" id="btn-parse">
                <i class="fe-play"></i> Parse File
            </button>
            <div class="import-progress mt-3" id="parse-progress" style="display:none">
                <div class="progress">
                    <div class="progress-bar progress-bar-striped progress-bar-animated" role="progressbar" style="width: 100%"></div>
                </div>
                <p class="mt-2 text-center">Parsing file...</p>
            </div>
        </div>

    <cfelseif activeJob.status eq "parsed" or activeJob.status eq "mapping">
        <!--- Column mapping step --->
        <div class="import-step" id="step-mapping">
            <h5><span class="step-number">2</span> Map Columns</h5>
            <p class="text-muted">Review how columns from your file map to contact fields.</p>
            <div id="mapping-container">
                <p class="text-center"><i class="fe-loader fe-spin"></i> Loading column mappings...</p>
            </div>
            <div class="mt-3">
                <button class="btn btn-primary" id="btn-confirm-mapping">
                    <i class="fe-check"></i> Confirm Mapping & Continue
                </button>
            </div>
        </div>

    <cfelseif listFindNoCase("reviewing,importing,completed", activeJob.status)>
        <!--- Review grid --->
        <div class="import-step" id="step-review">
            <h5><span class="step-number">3</span> Review &amp; Fix</h5>

            <!--- Stats bar --->
            <div class="row mb-3" id="stats-bar">
                <div class="col">
                    <div class="card card-body p-2 text-center">
                        <div class="h4 mb-0" id="stat-total">#activeJob.total_rows#</div>
                        <small class="text-muted">Total</small>
                    </div>
                </div>
                <div class="col">
                    <div class="card card-body p-2 text-center bg-success text-white">
                        <div class="h4 mb-0" id="stat-ready">#activeJob.valid_rows#</div>
                        <small>Ready</small>
                    </div>
                </div>
                <div class="col">
                    <div class="card card-body p-2 text-center bg-danger text-white">
                        <div class="h4 mb-0" id="stat-problem">#activeJob.problem_rows#</div>
                        <small>Problems</small>
                    </div>
                </div>
                <div class="col">
                    <div class="card card-body p-2 text-center bg-warning">
                        <div class="h4 mb-0" id="stat-dupe">#activeJob.dupe_rows#</div>
                        <small>Duplicates</small>
                    </div>
                </div>
                <div class="col">
                    <div class="card card-body p-2 text-center bg-info text-white">
                        <div class="h4 mb-0" id="stat-imported">#activeJob.imported_rows#</div>
                        <small>Imported</small>
                    </div>
                </div>
            </div>

            <!--- Filter tabs --->
            <ul class="nav nav-tabs review-tabs" id="review-tabs">
                <li class="nav-item">
                    <a class="nav-link active" href="##" data-filter="">
                        All <span class="badge badge-secondary" id="tab-all">#activeJob.total_rows#</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="##" data-filter="ready">
                        Ready <span class="badge badge-success" id="tab-ready">#activeJob.valid_rows#</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="##" data-filter="problem">
                        Problems <span class="badge badge-danger" id="tab-problem">#activeJob.problem_rows#</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="##" data-filter="dupe">
                        Duplicates <span class="badge badge-warning" id="tab-dupe">#activeJob.dupe_rows#</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="##" data-filter="ignored">
                        Ignored <span class="badge badge-secondary" id="tab-ignored">0</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="##" data-filter="imported">
                        Imported <span class="badge badge-info" id="tab-imported">#activeJob.imported_rows#</span>
                    </a>
                </li>
            </ul>

            <!--- Bulk actions --->
            <div class="d-flex justify-content-between align-items-center my-3" id="bulk-actions" style="display:none !important;">
                <div>
                    <input type="checkbox" id="select-all"> <label for="select-all" class="mb-0 ml-1">Select All</label>
                    <span class="ml-3" id="selected-count">0 selected</span>
                </div>
                <div>
                    <button class="btn btn-sm btn-outline-secondary" id="bulk-ignore">Mark Ignored</button>
                    <button class="btn btn-sm btn-outline-primary" id="bulk-import">Mark for Import</button>
                </div>
            </div>

            <!--- Review table --->
            <div class="table-responsive">
                <table class="table table-sm table-hover review-table" id="review-table">
                    <thead>
                        <tr>
                            <th width="30"><input type="checkbox" id="check-all"></th>
                            <th width="40">##</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Company</th>
                            <th width="80">Status</th>
                            <th width="100">Action</th>
                        </tr>
                    </thead>
                    <tbody id="review-tbody">
                        <tr><td colspan="8" class="text-center p-4"><i class="fe-loader fe-spin"></i> Loading rows...</td></tr>
                    </tbody>
                </table>
            </div>

            <!--- Pagination --->
            <div class="d-flex justify-content-between align-items-center mt-3">
                <div id="pagination-info">Showing 0-0 of 0</div>
                <nav id="pagination-nav">
                    <ul class="pagination pagination-sm mb-0">
                    </ul>
                </nav>
            </div>
        </div>

        <!--- Finalize step --->
        <cfif activeJob.status neq "completed">
        <div class="import-step" id="step-finalize">
            <h5><span class="step-number">4</span> Preview & Finalize Import</h5>
            <p class="text-muted">Review what will be imported, then finalize to import contacts into your account.</p>
            <div class="alert alert-warning" id="finalize-warning" style="display:none">
                <i class="fe-alert-triangle"></i> <span id="finalize-warning-text"></span>
            </div>
            <div class="btn-toolbar mb-3">
                <button class="btn btn-outline-primary btn-lg mr-2" id="btn-dry-run">
                    <i class="fe-eye"></i> Preview Import (Dry Run)
                </button>
                <button class="btn btn-success btn-lg" id="btn-finalize" <cfif activeJob.status eq "importing">disabled</cfif>>
                    <i class="fe-check-circle"></i> Import <span id="import-count">#activeJob.valid_rows#</span> Contacts
                </button>
            </div>
            <div class="import-progress mt-3" id="dry-run-progress" style="display:none">
                <div class="progress">
                    <div class="progress-bar progress-bar-striped progress-bar-animated bg-info" role="progressbar" style="width: 100%"></div>
                </div>
                <p class="mt-2 text-center">Analyzing import...</p>
            </div>
            <div class="import-progress mt-3" id="finalize-progress" style="display:none">
                <div class="progress">
                    <div class="progress-bar progress-bar-striped progress-bar-animated bg-success" role="progressbar" style="width: 100%"></div>
                </div>
                <p class="mt-2 text-center">Importing contacts...</p>
            </div>
        </div>
        <cfelse>
        <div class="import-step completed">
            <h5><span class="step-number"><i class="fe-check"></i></span> Import Complete</h5>
            <p class="text-success"><strong>#activeJob.imported_rows#</strong> contacts were successfully imported.</p>
            <a href="/app/contacts/?byimport=#activeJob.job_id#" class="btn btn-primary">
                <i class="fe-users"></i> View Imported Contacts
            </a>
        </div>
        </cfif>

    </cfif>
    </cfoutput>
</cfif>

<!--- Duplicate resolution modal --->
<div class="modal fade" id="dupe-modal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Resolve Duplicate</h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body" id="dupe-modal-body">
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-outline-danger" id="dupe-skip">Skip This Row</button>
                <button type="button" class="btn btn-warning" id="dupe-update">Update Existing</button>
                <button type="button" class="btn btn-primary" id="dupe-import-new">Import as New</button>
            </div>
        </div>
    </div>
</div>

<!--- Edit row modal --->
<div class="modal fade" id="edit-modal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fe-edit"></i> Edit Row</h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body" id="edit-modal-body" style="max-height: 60vh; overflow-y: auto;">
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" id="edit-save"><i class="fe-check"></i> Save Changes</button>
            </div>
        </div>
    </div>
</div>

<script src="/app/assets/js/contact-import-v2.js"></script>
