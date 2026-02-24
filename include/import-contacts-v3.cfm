<!---
    Contact Import V3 - Main Import Page
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
    <cfset importService = new services.ContactImportV3Service()>
    <cfset jobResult = importService.getJob(url.job_id)>
    <!--- getJob() returns { found: true/false, job: {...} } - extract job data --->
    <cfif structKeyExists(jobResult, "found") and jobResult.found and structKeyExists(jobResult, "job") and jobResult.job.userid eq session.userid>
        <cfset activeJob = jobResult.job>
        <cfset hasActiveJob = true>
    </cfif>
</cfif>

<!--- Get import history --->
<cfif not hasActiveJob>
    <cfset importService = new services.ContactImportV3Service()>
    <cfset importHistory = importService.getJobHistory(session.userid, 20)>
</cfif>

<!--- Ensure CSRF token exists for V3 API calls --->
<cfif not structKeyExists(session, "csrf_token") or not len(session.csrf_token)>
    <cfset session.csrf_token = createUUID()>
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
    border: 2px dashed #406e8e;
    border-radius: 8px;
    padding: 40px;
    text-align: center;
    cursor: pointer;
    transition: all 0.2s;
}
.upload-area:hover, .upload-area.dragover {
    border-color: var(--ct-link-hover-color);
    background: #f0f5f8;
}
.upload-area .upload-icon {
    font-size: 48px;
    color: #406e8e;
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
.status-completed { background: #d4edda; color: #155724; }
.status-failed { background: #f8d7da; color: #721c24; }
.status-cancelled { background: #e2e3e5; color: #383d41; }
.status-reviewing { background: #cce5ff; color: #004085; }
.status-finalizing { background: #fff3cd; color: #856404; }
.status-parsing { background: #fff3cd; color: #856404; }
.status-uploaded { background: #e2e3e5; color: #383d41; }
.status-parsed { background: #cce5ff; color: #004085; }
.status-mapping { background: #cce5ff; color: #004085; }

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

<!--- ============================================================
     PAGE HEADER
     ============================================================ --->

<!--- Toast alert container for V3 AJAX notifications --->
<div id="v3-alert-container"></div>

<!--- ============================================================
     MAIN CONTENT: Shows either upload/history OR active job view
     ============================================================ --->
<cfif not hasActiveJob>
    <!--- CSRF token for history table actions --->
    <cfoutput><input type="hidden" id="csrf-token" value="#encodeForHTMLAttribute(session.csrf_token)#"></cfoutput>
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
                            <cfif importHistory.status neq "completed" and importHistory.status neq "cancelled" and importHistory.status neq "failed">
                                <a href="?job_id=#importHistory.job_id#" class="btn btn-xs btn-primary">Continue</a>
                            </cfif>
                            <cfif importHistory.status eq "completed">
                                <a href="?job_id=#importHistory.job_id#" class="btn btn-xs btn-outline-info" title="View import details"><i class="fe-eye"></i></a>
                            </cfif>
                            <cfif importHistory.status eq "failed" or importHistory.status eq "finalizing">
                                <button class="btn btn-xs btn-outline-warning btn-history-reset" data-job-id="#importHistory.job_id#" title="Reset to review"><i class="fe-refresh-cw"></i></button>
                            </cfif>
                            <cfif importHistory.status neq "cancelled" and importHistory.status neq "completed">
                                <button class="btn btn-xs btn-outline-danger btn-history-cancel" data-job-id="#importHistory.job_id#" title="Cancel import"><i class="fe-x"></i></button>
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
    <!--- ============================================================
         ACTIVE JOB VIEW
         Shows the multi-step import workflow for the selected job.
         Hidden inputs provide state to the JS controller.
         ============================================================ --->
    <cfoutput>
    <input type="hidden" id="job-id" value="#activeJob.job_id#">
    <input type="hidden" id="job-status" value="#activeJob.status#">
    <input type="hidden" id="csrf-token" value="#encodeForHTMLAttribute(session.csrf_token)#">

    <!--- Job info bar --->
    <div class="alert d-flex justify-content-between align-items-center" style="background: rgba(64,110,142,0.1); border: 1px solid ##406e8e;">
        <div>
            <strong>File:</strong> #activeJob.source_filename#
            <span class="mx-2">|</span>
            <strong>Status:</strong> <span id="current-status" class="status-badge status-#lcase(activeJob.status)#">#activeJob.status#</span>
            <cfif listFindNoCase("completed,failed,cancelled", activeJob.status)>
                <button class="btn btn-sm btn-outline-warning ms-2" id="btn-reset-to-review" data-job-id="#activeJob.job_id#" title="Move job back to reviewing so you can re-examine or re-import rows">
                    <i class="fe-rotate-ccw"></i> Reset to Review
                </button>
            </cfif>
            <cfif activeJob.status neq "cancelled" and activeJob.status neq "completed">
                <button class="btn btn-sm btn-outline-danger ms-2" id="btn-cancel-job" data-job-id="#activeJob.job_id#" title="Cancel this import job">
                    <i class="fe-x-circle"></i> Cancel
                </button>
            </cfif>
        </div>
        <div class="d-flex align-items-center gap-2">
            <cfif listFindNoCase("reviewing,finalizing,completed,failed", activeJob.status)>
            <div class="dropdown d-inline-block">
                <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown" id="status-change-btn">
                    Change Status
                </button>
                <ul class="dropdown-menu">
                    <cfif activeJob.status eq "finalizing" or activeJob.status eq "completed" or activeJob.status eq "failed">
                    <li><a class="dropdown-item btn-change-status" href="##" data-new-status="reviewing"><i class="fe-refresh-cw"></i> Return to Review</a></li>
                    </cfif>
                    <cfif activeJob.status neq "cancelled">
                    <li><a class="dropdown-item btn-change-status text-danger" href="##" data-new-status="cancelled"><i class="fe-x-circle"></i> Cancel Import</a></li>
                    </cfif>
                </ul>
            </div>
            </cfif>
            <a href="/app/contacts-import-v3/" class="btn btn-sm btn-outline-secondary">Start New Import</a>
        </div>
    </div>

    <!--- Stale lock detection: warn if job is stuck in finalizing/parsing for over 10 minutes --->
    <cfif listFindNoCase("finalizing,parsing", activeJob.status) and structKeyExists(activeJob, "updated_at") and isDate(activeJob.updated_at)>
        <cfset variables.staleLockMinutes = dateDiff("n", activeJob.updated_at, now())>
        <cfif variables.staleLockMinutes gt 10>
            <div class="alert alert-warning d-flex align-items-center" id="stale-lock-warning">
                <i class="fe-alert-triangle me-2" style="font-size:20px;"></i>
                <div class="flex-grow-1">
                    <strong>This job appears stuck.</strong>
                    It has been in <strong>#activeJob.status#</strong> status for #variables.staleLockMinutes# minutes without completing.
                    This usually means the previous operation was interrupted. You can safely reset it.
                </div>
                <button class="btn btn-warning btn-sm ms-3" id="btn-force-unlock" data-job-id="#activeJob.job_id#">
                    <i class="fe-unlock"></i> Unlock &amp; Reset to Review
                </button>
            </div>
        </cfif>
    </cfif>

    <!--- ============================================================
         WORKFLOW STEPS - Show appropriate step based on job status
         Step 2: Parse | Step 2: Map Columns | Step 3: Review | Step 4: Finalize
         ============================================================ --->
    <cfif activeJob.status eq "created" or activeJob.status eq "pending" or activeJob.status eq "uploaded">
        <!--- STEP 2a: Parse File - job is uploaded but not yet parsed --->
        <div class="import-step" id="step-parse">
            <h5><span class="step-number">2</span> Parsing File</h5>
            <p>Click to parse and analyze your file.</p>
            <button class="btn btn-primary" id="btn-parse" style="background: linear-gradient(135deg, var(--ct-link-color), var(--ct-link-hover-color)); border:none;">
                <i class="fe-play"></i> Parse File
            </button>
            <div class="import-progress mt-3" id="parse-progress" style="display:none">
                <div class="progress">
                    <div class="progress-bar progress-bar-striped progress-bar-animated" role="progressbar" style="width: 100%; background: linear-gradient(135deg, var(--ct-link-color), var(--ct-link-hover-color));"></div>
                </div>
                <p class="mt-2 text-center">Parsing file...</p>
            </div>
        </div>

    <cfelseif activeJob.status eq "parsed" or activeJob.status eq "mapping">
        <!--- STEP 2b: Column Mapping - file is parsed, user maps source columns to contact fields --->
        <div class="import-step" id="step-mapping">
            <h5><span class="step-number">2</span> Map Columns</h5>
            <p class="text-muted">Review how columns from your file map to contact fields.</p>
            <div id="mapping-container">
                <p class="text-center"><i class="fe-loader fe-spin"></i> Loading column mappings...</p>
            </div>
            <div class="mt-3">
                <button class="btn btn-primary" id="btn-confirm-mapping" style="background: linear-gradient(135deg, var(--ct-link-color), var(--ct-link-hover-color)); border:none;">
                    <i class="fe-check"></i> Confirm Mapping & Continue
                </button>
            </div>
        </div>

    <cfelseif listFindNoCase("reviewing,importing,finalizing,completed", activeJob.status)>
        <!--- STEP 3: Review Grid - shows all rows with status, validation, and dupe info --->
        <div class="import-step" id="step-review">
            <div class="d-flex justify-content-between align-items-center">
                <h5 class="mb-0"><span class="step-number">3</span> Review &amp; Fix</h5>
                <div>
                    <button class="btn btn-sm btn-outline-danger" id="btn-export-problems" style="display:none;" title="Download CSV of rows with errors">
                        <i class="fe-download"></i> Export Problems
                    </button>
                    <cfif activeJob.status neq "completed">
                    <button class="btn btn-sm btn-outline-secondary ms-1" id="btn-refresh-validation" title="Re-run validation and duplicate detection on all rows">
                        <i class="fe-refresh-cw"></i> Refresh Validation
                    </button>
                    </cfif>
                </div>
            </div>

            <!--- Stats bar --->
            <div class="row mb-3" id="stats-bar">
                <div class="col">
                    <div class="card card-body p-2 text-center">
                        <div class="h4 mb-0" id="stat-total"><i class="fe-loader fe-spin" style="font-size:16px"></i></div>
                        <small class="text-muted">Total</small>
                    </div>
                </div>
                <div class="col">
                    <div class="card card-body p-2 text-center bg-success text-white">
                        <div class="h4 mb-0" id="stat-ready"><i class="fe-loader fe-spin" style="font-size:16px"></i></div>
                        <small>Ready</small>
                    </div>
                </div>
                <div class="col">
                    <div class="card card-body p-2 text-center bg-danger text-white">
                        <div class="h4 mb-0" id="stat-problem"><i class="fe-loader fe-spin" style="font-size:16px"></i></div>
                        <small>Problems</small>
                    </div>
                </div>
                <div class="col">
                    <div class="card card-body p-2 text-center bg-warning">
                        <div class="h4 mb-0" id="stat-dupe"><i class="fe-loader fe-spin" style="font-size:16px"></i></div>
                        <small>Duplicates</small>
                    </div>
                </div>
                <div class="col">
                    <div class="card card-body p-2 text-center" style="background: linear-gradient(135deg, var(--ct-link-color), var(--ct-link-hover-color)); color:##fff;">
                        <div class="h4 mb-0" id="stat-imported"><i class="fe-loader fe-spin" style="font-size:16px"></i></div>
                        <small>Imported</small>
                    </div>
                </div>
            </div>

            <!--- Search bar --->
            <div class="mb-2">
                <div class="input-group input-group-sm" style="max-width:350px;">
                    <span class="input-group-text"><i class="fe-search"></i></span>
                    <input type="text" class="form-control" id="row-search" placeholder="Search by name, email, company, phone...">
                    <button class="btn btn-outline-secondary" type="button" id="row-search-clear" style="display:none;">
                        <i class="fe-x"></i>
                    </button>
                </div>
            </div>

            <!--- Filter tabs --->
            <ul class="nav nav-tabs review-tabs" id="review-tabs">
                <li class="nav-item">
                    <a class="nav-link active" href="##" data-filter="">
                        All <span class="badge badge-secondary" id="tab-all">...</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="##" data-filter="ready">
                        Ready <span class="badge badge-success" id="tab-ready">...</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="##" data-filter="problem">
                        Problems <span class="badge badge-danger" id="tab-problem">...</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="##" data-filter="dupe">
                        Duplicates <span class="badge badge-warning" id="tab-dupe">...</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="##" data-filter="ignored">
                        Ignored <span class="badge badge-secondary" id="tab-ignored">...</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="##" data-filter="imported">
                        Imported <span class="badge" style="background:##406e8e;color:##fff;" id="tab-imported">...</span>
                    </a>
                </li>
            </ul>

            <!--- Review table --->
            <div class="table-responsive">
                <table class="table table-sm table-hover review-table" id="review-table">
                    <thead>
                        <tr>
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
                        <tr><td colspan="7" class="text-center p-4"><i class="fe-loader fe-spin"></i> Loading rows...</td></tr>
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

            <!--- Continue to finalize button --->
            <cfif activeJob.status neq "completed">
            <div class="text-end mt-4">
                <button class="btn btn-lg" id="btn-goto-finalize" style="background: linear-gradient(135deg, var(--ct-link-color), var(--ct-link-hover-color)); color:##fff; border:none;">
                    Continue to Import <i class="fe-arrow-right"></i>
                </button>
            </div>
            </cfif>
        </div>

        <!--- STEP 4: Preview & Finalize Import
              Dry-run shows what will happen; Finalize creates contacts --->
        <cfif activeJob.status neq "completed">
        <div class="import-step" id="step-finalize" style="display:none;">
            <div class="mb-3">
                <button class="btn btn-sm btn-outline-secondary" id="btn-back-to-review">
                    <i class="fe-arrow-left"></i> Back to Review
                </button>
            </div>
            <h5><span class="step-number">4</span> Preview & Finalize Import</h5>
            <p class="text-muted">Review what will be imported, then finalize to import contacts into your account.</p>
            <div class="alert alert-warning" id="finalize-warning" style="display:none">
                <i class="fe-alert-triangle"></i> <span id="finalize-warning-text"></span>
            </div>
            <div id="finalize-precheck" class="mb-3" style="display:none">
                <div class="card" style="border-left:4px solid ##406e8e;">
                    <div class="card-body py-2 px-3">
                        <strong class="small text-uppercase text-muted">Import Summary</strong>
                        <div class="row mt-1" id="precheck-details"></div>
                    </div>
                </div>
            </div>
            <div class="btn-toolbar mb-3">
                <button class="btn btn-outline-primary btn-lg mr-2" id="btn-dry-run">
                    <i class="fe-eye"></i> Preview Import (Dry Run)
                </button>
                <button class="btn btn-lg" id="btn-finalize" style="background: linear-gradient(135deg, var(--ct-link-color), var(--ct-link-hover-color)); color:##fff; border:none;" <cfif activeJob.status eq "finalizing">disabled</cfif>>
                    <i class="fe-check-circle"></i> Import <span id="import-count">...</span> Contacts
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
                    <div class="progress-bar progress-bar-striped progress-bar-animated" role="progressbar" style="width: 100%; background: linear-gradient(135deg, var(--ct-link-color), var(--ct-link-hover-color));"></div>
                </div>
                <p class="mt-2 text-center">Importing contacts...</p>
            </div>
        </div>
        <cfelse>
        <div class="import-step completed">
            <h5><span class="step-number"><i class="fe-check"></i></span> Import Complete</h5>
            <div class="row mb-3">
                <div class="col-auto">
                    <div class="card card-body p-2 text-center bg-success text-white" style="min-width:100px;">
                        <div class="h4 mb-0">#val(activeJob.imported_rows)#</div>
                        <small>Created</small>
                    </div>
                </div>
                <cfif val(activeJob.updated_rows) gt 0>
                <div class="col-auto">
                    <div class="card card-body p-2 text-center" style="min-width:100px;background:##cce5ff;color:##004085;">
                        <div class="h4 mb-0">#val(activeJob.updated_rows)#</div>
                        <small>Updated</small>
                    </div>
                </div>
                </cfif>
                <cfif val(activeJob.skipped_rows) gt 0>
                <div class="col-auto">
                    <div class="card card-body p-2 text-center" style="min-width:100px;background:##e2e3e5;color:##383d41;">
                        <div class="h4 mb-0">#val(activeJob.skipped_rows)#</div>
                        <small>Skipped</small>
                    </div>
                </div>
                </cfif>
                <cfif val(activeJob.problem_rows) gt 0>
                <div class="col-auto">
                    <div class="card card-body p-2 text-center bg-danger text-white" style="min-width:100px;">
                        <div class="h4 mb-0">#val(activeJob.problem_rows)#</div>
                        <small>Problems</small>
                    </div>
                </div>
                </cfif>
                <div class="col-auto">
                    <div class="card card-body p-2 text-center" style="min-width:100px;background:##f8f9fa;color:##6c757d;">
                        <div class="h4 mb-0">#val(activeJob.total_rows)#</div>
                        <small>Total Rows</small>
                    </div>
                </div>
            </div>
            <cfif isDate(activeJob.finished_at) and isDate(activeJob.started_at)>
                <p class="text-muted small mb-3">
                    Completed #dateFormat(activeJob.finished_at, "mm/dd/yyyy")# at #timeFormat(activeJob.finished_at, "h:mm tt")#
                    (Duration: #dateDiff("s", activeJob.started_at, activeJob.finished_at)#s)
                </p>
            </cfif>
            <a href="/app/contacts/?byimport=#activeJob.job_id#" class="btn btn-primary" style="background: linear-gradient(135deg, var(--ct-link-color), var(--ct-link-hover-color)); border:none;">
                <i class="fe-users"></i> View Imported Contacts
            </a>
        </div>
        </cfif>

    </cfif>
    </cfoutput>
</cfif>

<!--- ============================================================
     MODALS
     Duplicate resolution and row edit modals, used by the JS controller
     ============================================================ --->

<!--- Duplicate resolution modal - shows candidate matches and action buttons --->
<div class="modal fade" id="dupe-modal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header" style="background: rgba(64,110,142,0.1);">
                <h5 class="modal-title">Resolve Duplicate</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="dupe-modal-body">
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-outline-danger" id="dupe-skip">Skip This Row</button>
                <button type="button" class="btn btn-warning" id="dupe-update">Update Existing</button>
                <button type="button" class="btn btn-primary" id="dupe-import-new" style="background: linear-gradient(135deg, var(--ct-link-color), var(--ct-link-hover-color)); border:none;">Import as New</button>
            </div>
        </div>
    </div>
</div>

<!--- Edit row modal - dynamically populated by JS with type-specific field widgets --->
<div class="modal fade" id="edit-modal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header" style="background: rgba(64,110,142,0.1);">
                <h5 class="modal-title"><i class="fe-edit"></i> Edit Row</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="edit-modal-body" style="max-height: 60vh; overflow-y: auto;">
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" id="edit-save" style="background: linear-gradient(135deg, var(--ct-link-color), var(--ct-link-hover-color)); border:none;"><i class="fe-check"></i> Save Changes</button>
            </div>
        </div>
    </div>
</div>

<!--- ============================================================
     JAVASCRIPT CONTROLLER
     Cache-busted via timestamp query param
     ============================================================ --->
<script src="/app/assets/js/contact-import-v3.js?v=<cfoutput>#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#</cfoutput>"></script>
