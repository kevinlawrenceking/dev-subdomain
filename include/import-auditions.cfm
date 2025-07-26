<!--- This ColdFusion page handles the import of audition templates, allowing users to upload files and view import results. --->

<cfparam name="step" default="1" />

<script>
    <!--- Enhanced functions for better user experience --->
    function unlock() {
        const fileInput = document.getElementById('fileInput');
        const submitButton = document.getElementById('buttonSubmit');
        const file = fileInput.files[0];
        
        if (file) {
            // Validate file type
            const allowedTypes = ['.xlsx', '.xls'];
            const fileExtension = '.' + file.name.split('.').pop().toLowerCase();
            
            if (allowedTypes.includes(fileExtension)) {
                // Validate file size (10MB limit)
                const maxSize = 10 * 1024 * 1024; // 10MB in bytes
                
                if (file.size <= maxSize) {
                    submitButton.removeAttribute("disabled");
                    submitButton.innerHTML = '<i class="fe-upload me-2"></i>Import ' + file.name;
                    fileInput.classList.remove('is-invalid');
                    fileInput.classList.add('is-valid');
                } else {
                    submitButton.setAttribute("disabled", "disabled");
                    fileInput.classList.remove('is-valid');
                    fileInput.classList.add('is-invalid');
                    alert('File size must be less than 10MB. Please choose a smaller file.');
                }
            } else {
                submitButton.setAttribute("disabled", "disabled");
                fileInput.classList.remove('is-valid');
                fileInput.classList.add('is-invalid');
                alert('Please select a valid Excel file (.xlsx or .xls)');
            }
        } else {
            submitButton.setAttribute("disabled", "disabled");
            submitButton.innerHTML = '<i class="fe-upload me-2"></i>Import Auditions';
            fileInput.classList.remove('is-valid', 'is-invalid');
        }
    }
    
    function resetForm() {
        const form = document.getElementById('upload');
        const fileInput = document.getElementById('fileInput');
        const submitButton = document.getElementById('buttonSubmit');
        
        form.reset();
        submitButton.setAttribute("disabled", "disabled");
        submitButton.innerHTML = '<i class="fe-upload me-2"></i>Import Auditions';
        fileInput.classList.remove('is-valid', 'is-invalid');
        document.getElementById('uploadProgress').style.display = 'none';
    }
    
    // Show progress when form is submitted
    document.addEventListener('DOMContentLoaded', function() {
        const form = document.getElementById('upload');
        form.addEventListener('submit', function() {
            document.getElementById('uploadProgress').style.display = 'block';
            document.getElementById('buttonSubmit').setAttribute('disabled', 'disabled');
        });
    });
</script>

<!--- Custom styles for improved appearance --->
<style>
    .import-section .card {
        border: none;
        box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
        transition: box-shadow 0.15s ease-in-out;
    }
    
    .import-section .card:hover {
        box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
    }
    
    .step-number {
        width: 40px;
        height: 40px;
        font-weight: 600;
        font-size: 1.1rem;
    }
    
    .table th {
        border-top: none;
        font-weight: 600;
        font-size: 0.875rem;
        letter-spacing: 0.025em;
        text-transform: uppercase;
    }
    
    .badge.bg-primary {
        padding: 0.5rem 0.75rem;
        font-size: 0.875rem;
    }
    
    @media (max-width: 768px) {
        .card-body.p-4 {
            padding: 1.5rem !important;
        }
        
        .d-flex.align-items-start {
            flex-direction: column !important;
        }
        
        .step-number {
            margin-bottom: 1rem;
        }
    }
</style>

<!--- Improved Import Interface --->
<div class="container-fluid import-section">
    <div class="row">
        <div class="col-12">
            <div class="card mb-4 shadow-sm">
                <div class="card-header bg-primary text-white">
                    <h4 class="card-title mb-0">
                        <i class="fe-upload me-2"></i>Import Auditions
                    </h4>
                    <p class="mb-0 mt-1 opacity-75">Follow these simple steps to import your audition data</p>
                </div>
                <div class="card-body p-4">
                
                <!--- Step 1: Download Template --->
                <div class="d-flex align-items-start mb-4">
                    <div class="flex-shrink-0 me-3">
                        <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center step-number">
                            <strong>1</strong>
                        </div>
                    </div>
                    <div class="flex-grow-1">
                        <h5 class="mb-2">Download Import Template</h5>
                        <p class="text-muted mb-3">
                            Get the Excel template with the correct format for importing your audition data.
                        </p>
                        <cfoutput>
                            <a href="#application.auditionimporttemplate#" download target="_blank" 
                               class="btn btn-outline-primary btn-lg">
                                <i class="fe-download me-2"></i>Download Template
                            </a>
                        </cfoutput>
                        <div class="mt-2">
                            <small class="text-warning">
                                <i class="fe-alert-triangle me-1"></i>
                                <strong>Important:</strong> Data must be in this exact format to import successfully.
                            </small>
                        </div>
                    </div>
                </div>

                <hr class="my-4">

                <!--- Step 2: Upload File --->
                <div class="d-flex align-items-start">
                    <div class="flex-shrink-0 me-3">
                        <div class="bg-success text-white rounded-circle d-flex align-items-center justify-content-center step-number">
                            <strong>2</strong>
                        </div>
                    </div>
                    <div class="flex-grow-1">
                        <h5 class="mb-2">Upload Your File</h5>
                        <p class="text-muted mb-3">
                            Once you've filled out the template and saved it as an Excel file (.xlsx), upload it here.
                        </p>

                        <form action="/include/upload_audition.cfm" method="post" enctype="multipart/form-data" id="upload" class="needs-validation" novalidate>
                            <cfoutput>
                                <input type="hidden" name="userid" value="#userid#" />
                            </cfoutput>
                            
                            <div class="mb-3">
                                <label for="fileInput" class="form-label fw-semibold">Select Excel File</label>
                                <input type="file" 
                                       class="form-control form-control-lg" 
                                       name="file" 
                                       id="fileInput"
                                       accept=".xlsx,.xls"
                                       onchange="unlock();" 
                                       required>
                                <div class="invalid-feedback">
                                    Please select an Excel file to upload.
                                </div>
                                <small class="form-text text-muted mt-1">
                                    <i class="fe-info me-1"></i>
                                    Accepted formats: .xlsx, .xls (Max file size: 10MB)
                                </small>
                            </div>

                            <div class="d-flex gap-2 flex-wrap">
                                <button type="submit" 
                                        class="btn btn-success btn-lg" 
                                        id="buttonSubmit" 
                                        disabled>
                                    <i class="fe-upload me-2"></i>Import Auditions
                                </button>
                                <button type="button" 
                                        class="btn btn-outline-secondary btn-lg" 
                                        onclick="resetForm()">
                                    <i class="fe-refresh-cw me-2"></i>Reset
                                </button>
                            </div>
                        </form>

                        <!--- Progress indicator (hidden by default) --->
                        <div id="uploadProgress" class="mt-3" style="display: none;">
                            <div class="d-flex align-items-center">
                                <div class="spinner-border spinner-border-sm text-primary me-2" role="status">
                                    <span class="visually-hidden">Loading...</span>
                                </div>
                                <span class="text-primary">Processing your import...</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<cfif isDefined('uploadid')>
    <!--- Include upload details and process the results --->
    <cfinclude template="/include/qry/upload_details_140_1.cfm" />
    <cfset conlist = valuelist(upload_details.audprojectid) />
    <cfinclude template="/include/qry/results_140_2.cfm" />

    <div class="row">
        <div class="col-12">
            <div class="card mb-4 shadow-sm border-success">
                <div class="card-header bg-success text-white">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h4 class="card-title mb-0">
                                <i class="fe-check-circle me-2"></i>Import Results
                            </h4>
                            <cfoutput>
                                <p class="mb-0 mt-1 opacity-75">
                                    Successfully processed #results.recordcount# audition<cfif results.recordcount NEQ 1>s</cfif>
                                </p>
                            </cfoutput>
                        </div>
                        <div class="text-end">
                            <cfoutput>
                                <div class="badge bg-light text-success fs-6 px-3 py-2">
                                    #results.recordcount# Records
                                </div>
                            </cfoutput>
                        </div>
                    </div>
                </div>
                <div class="card-body">
                    <div class="alert alert-info d-flex align-items-center mb-4" role="alert">
                        <i class="fe-info me-2"></i>
                        <div>
                            Click on any project name to view its details. Items marked as "Invalid" can be fixed using the Fix button.
                        </div>
                    </div>
                    
                    <div class="table-responsive">
                        <table id="basic-datatable" class="table table-hover table-striped mb-0" role="grid">
                            <thead class="table-dark">
                                <cfoutput query="results" maxrows="1">
                                    <tr>
                                        <th class="text-nowrap"><i class="fe-calendar me-1"></i>Date/Time</th>
                                        <th class="text-nowrap"><i class="fe-film me-1"></i>Project</th>
                                        <th class="text-nowrap"><i class="fe-user me-1"></i>Role</th>
                                        <th class="text-nowrap"><i class="fe-tag me-1"></i>Category</th>
                                        <th class="text-nowrap"><i class="fe-users me-1"></i>Source</th>
                                        <th class="text-nowrap text-center"><i class="fe-check-circle me-1"></i>Import Status</th>
                                    </tr>
                                </cfoutput>
                            </thead>
                            <tbody>
                                <cfloop query="results">
                                    <!--- Include error details for each result --->
                                    <cfinclude template="/include/qry/errs_125_2.cfm" />
                                    <cfset err_list = valuelist(errs.error_msg)>
                                    <cfoutput>
                                        <tr id="row-#results.id#">
                                            <td>
                                                <cfif len(results.audprojectid)>
                                                    <a href="/app/audition/?audprojectid=#results.audprojectid#" class="text-decoration-none">
                                                        <cfset myDateTime = results.col1b>
                                                        <cfset myFormattedDateTime = dateformat(myDateTime, "mm/dd/yyyy")>
                                                        <i class="fe-calendar me-1 text-muted"></i>#myFormattedDateTime#
                                                    </a>
                                                <cfelse>
                                                    <cfset myDateTime = results.col1b>
                                                    <cfset myFormattedDateTime = dateformat(myDateTime, "mm/dd/yyyy")>
                                                    <i class="fe-calendar me-1 text-muted"></i>#myFormattedDateTime#
                                                </cfif>
                                            </td>
                                            <td>
                                                <cfif len(results.audprojectid)>
                                                    <a href="/app/audition/?audprojectid=#results.audprojectid#" class="fw-semibold text-decoration-none">
                                                        #col2#
                                                    </a>
                                                <cfelse>
                                                    <span class="text-muted">#col2#</span>
                                                </cfif>
                                            </td>
                                            <td>#col3#</td>
                                            <td>
                                                <cfif col4 NEQ "">
                                                    <span class="badge bg-light text-dark border">#col4#</span>
                                                <cfelse>
                                                    <span class="text-muted">—</span>
                                                </cfif>
                                            </td>
                                            <td>#col5#</td>
                                            <td class="text-center">
                                                <cfif col6 EQ "invalid">
                                                    <div class="d-flex align-items-center justify-content-center gap-2">
                                                        <span class="badge bg-danger">
                                                            <i class="fe-alert-circle me-1"></i>Invalid
                                                        </span>
                                                        <button type="button" 
                                                                class="btn btn-sm btn-warning" 
                                                                onclick="loadForm(#results.id#)"
                                                                title="#err_list#">
                                                            <i class="fe-tool me-1"></i>Fix
                                                        </button>
                                                    </div>
                                                <cfelse>
                                                    <span class="badge bg-success">
                                                        <i class="fe-check me-1"></i>#col6#
                                                    </span>
                                                </cfif>
                                            </td>
                                        </tr>
                                    </cfoutput>
                                </cfloop>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</cfif>

<!--- Always show import history if record count is not zero --->
<cfinclude template="/include/qry/auditions_import.cfm" />

<cfif imports.recordcount GT 0>
    <div class="row">
        <div class="col-12">
            <div class="card mb-4 shadow-sm">
                <div class="card-header bg-light border-bottom">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h5 class="card-title mb-0">
                                <i class="fe-clock me-2 text-muted"></i>Import History
                            </h5>
                            <cfoutput>
                                <small class="text-muted">You have <strong>#imports.recordcount#</strong> previous import<cfif imports.recordcount NEQ 1>s</cfif></small>
                            </cfoutput>
                        </div>
                        <div>
                            <button class="btn btn-sm btn-outline-secondary" type="button" data-bs-toggle="collapse" data-bs-target="##importHistoryCollapse" aria-expanded="false">
                                <i class="fe-chevron-down"></i>
                            </button>
                        </div>
                    </div>
                </div>
                <div class="collapse" id="importHistoryCollapse">
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0" id="basic-datatable-history">
                                <thead class="table-light">
                                    <tr>
                                        <th class="px-3 py-3" style="width: 90px;">
                                            <i class="fe-hash me-1 text-muted"></i>Batch ID
                                        </th>
                                        <th class="px-3 py-3">
                                            <i class="fe-calendar me-1 text-muted"></i>Date
                                        </th>
                                        <th class="px-3 py-3">
                                            <i class="fe-clock me-1 text-muted"></i>Time
                                        </th>
                                        <th class="px-3 py-3 text-center" style="width: 100px;">
                                            <i class="fe-eye me-1 text-muted"></i>Actions
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfloop query="imports">
                                        <cfoutput>
                                            <tr>
                                                <td class="px-3 py-3">
                                                    <span class="badge bg-primary fs-6">#imports.uploadid#</span>
                                                </td>
                                                <td class="px-3 py-3">
                                                    <span class="text-body fw-medium">#dateformat(imports.timestamp, "mm/dd/yyyy")#</span>
                                                </td>
                                                <td class="px-3 py-3">
                                                    <span class="text-muted">#timeformat(imports.timestamp, "h:mm tt")#</span>
                                                </td>
                                                <td class="px-3 py-3 text-center">
                                                    <a href="/app/auditions/?byimport=#imports.uploadid#" 
                                                       class="btn btn-sm btn-outline-primary" 
                                                       title="View imported auditions">
                                                        <i class="fe-eye"></i>
                                                    </a>
                                                </td>
                                            </tr>
                                        </cfoutput>
                                    </cfloop>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</cfif>

<!--- Close main container --->
</div>

<!--- Toast Container for success messages --->
<div class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 9999;">
    <div id="successToast" class="toast align-items-center text-bg-success border-0" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="d-flex">
            <div class="toast-body">
                Record updated successfully!
            </div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
    </div>
</div>

<!--- Modal for Fixing Invalid Records --->
<div class="modal fade" id="fixModal" tabindex="-1" role="dialog" aria-labelledby="fixModalLabel" >

    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="fixModalLabel">Fix Invalid Record</h5>
                <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                    <span >
&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form id="fixForm" onsubmit="return submitFixForm();">
                    <input type="hidden" name="recordId" id="recordId" />
                    <div class="form-group">
                        <label for="projName">Project</label>
                        <input type="text" class="form-control" name="projName" id="projName" />
                    </div>
                    <div class="row">
                        <div class="form-group col-md-6">
                            <label for="audRoleName">Role</label>
                            <input type="text" class="form-control" name="audRoleName" id="audRoleName" />
                        </div>
                        <div class="form-group col-md-6">
                            <label for="projDate">Project Date</label>
                            <input type="date" class="form-control" name="projDate" id="projDate" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group col-md-6">
                            <label for="audsubcatid">Category</label>
                            <select class="form-control" name="audsubcatid" id="audsubcatid">
                                <option value="">Select Category</option>
                            </select>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="audsource">Source</label>
                            <select class="form-control" name="audsource" id="audsource">
                                <option value="">Select Source</option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group col-md-6">
                            <label for="cdfirstname">CD First Name</label>
                            <input type="text" class="form-control" name="cdfirstname" id="cdfirstname" />
                        </div>
                        <div class="form-group col-md-6">
                            <label for="cdlastname">CD Last Name</label>
                            <input type="text" class="form-control" name="cdlastname" id="cdlastname" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group col-md-3">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="callback_yn" id="callback_yn" value="Y" />
                                <label class="form-check-label" for="callback_yn">Callback</label>
                            </div>
                        </div>
                        <div class="form-group col-md-3">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="redirect_yn" id="redirect_yn" value="Y" />
                                <label class="form-check-label" for="redirect_yn">Redirect</label>
                            </div>
                        </div>
                        <div class="form-group col-md-3">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="pin_yn" id="pin_yn" value="Y" />
                                <label class="form-check-label" for="pin_yn">Pin</label>
                            </div>
                        </div>
                        <div class="form-group col-md-3">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="booked_yn" id="booked_yn" value="Y" />
                                <label class="form-check-label" for="booked_yn">Booked</label>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="projDescription">Project Description</label>
                        <textarea class="form-control" name="projDescription" id="projDescription" rows="2"></textarea>
                    </div>
                    <div class="form-group">
                        <label for="charDescription">Character Description</label>
                        <textarea class="form-control" name="charDescription" id="charDescription" rows="2"></textarea>
                    </div>
                    <div class="form-group">
                        <label for="note">Notes</label>
                        <textarea class="form-control" name="note" id="note" rows="2"></textarea>
                    </div>
                    <div class="form-group">
                        <input type="text" class="form-control" name="status" id="status" />
                    </div>
                    <button type="submit" id="fixFormSubmitButton" class="btn btn-primary">Save changes</button>
                </form>
            </div>
        </div>
    </div>
</div>

<!--- Place this script block at the end of your body section, right before the closing </body> tag --->
<script>
    <!--- Function to load record data into the modal form --->
    function loadForm(recordId) {
        $.ajax({
            url: '/include/get_record_data.cfm',
            type: 'GET',
            data: { id: recordId },
            success: function(data) {
                console.log("Raw response data:", data); // Log raw data for debugging
                try {
                    if (data) {
                        // Populate the select list for categories before setting the value
                        const categorySelect = $('#audsubcatid');
                        categorySelect.empty(); // Clear existing options
                        categorySelect.append(new Option("Select Category", "")); // Add default option

                        // Add new options from the categories
                        data.categories.forEach(category => {
                            categorySelect.append(new Option(category.NAME, category.ID)); 
                        });

                        // Set the selected value for categories by matching the ID
                        categorySelect.val(data.audsubcatid);

                        // Populate the select list for sources
                        const sourceSelect = $('#audsource');
                        sourceSelect.empty(); // Clear existing options
                        sourceSelect.append(new Option("Select Source", "")); // Add default option

                        // Add new options from the sources
                        data.sources.forEach(source => {
                            sourceSelect.append(new Option(source.NAME, source.NAME));
                        });

                        // Set the selected value for source
                        sourceSelect.val(data.audSource);

                        // Populate other fields
                        $('#recordId').val(data.id);
                        $('#projDate').val(data.projDate);
                        $('#projName').val(data.projName);
                        $('#audRoleName').val(data.audRoleName);
                        $('#cdfirstname').val(data.cdFirstName);
                        $('#cdlastname').val(data.cdLastName);
                        $('#callback_yn').prop('checked', data.callbackYN === 'Y');
                        $('#redirect_yn').prop('checked', data.redirectYN === 'Y');
                        $('#pin_yn').prop('checked', data.pinYN === 'Y');
                        $('#booked_yn').prop('checked', data.bookedYN === 'Y');
                        $('#projDescription').val(data.projDescription);
                        $('#charDescription').val(data.charDescription);
                        $('#note').val(data.note);
                        $('#status').val(data.status);

                        // Open the modal after the data has been populated
                        $('#fixModal').modal('show');
                    } else {
                        console.error("Record data is undefined or missing.");
                        alert('Error fetching record data.');
                    }
                } catch (e) {
                    console.error("Error parsing JSON:", e);
                    console.error("Response data:", data);
                    alert('Error fetching record data.');
                }
            },
            error: function(jqXHR, textStatus, errorThrown) {
                console.error("AJAX error:", textStatus, errorThrown);
                alert('Error fetching record data.');
            }
        });
    }

    <!--- Function to submit the fix form --->
    function submitFixForm() {
        var formData = $('#fixForm').serialize(); // Serialize the form data

        $.ajax({
            url: '/include/update_import_auditions.cfm', // URL to the ColdFusion page that will process the form data
            type: 'POST',
            data: formData,
            success: function(response) {
                if (typeof response === 'string') {
                    response = JSON.parse(response);
                }

                if (response.SUCCESS) {
                    // Show the success toast with a 3-second delay
                    var successToast = new bootstrap.Toast(document.getElementById('successToast'), {
                        delay: 3000 // 3 seconds
                    });
                    successToast.show();

                    $('#fixModal').modal('hide'); // Close the modal

                    // Optionally, you can refresh part of the page to show the updated data
                    location.reload(); // Reload the page to reflect the changes
                } else {
                    alert('Failed to update the record: ' + response.MESSAGE);
                }
            },
            error: function(jqXHR, textStatus, errorThrown) {
                console.error("AJAX error:", textStatus, errorThrown);
                alert('Error updating the record.');
            }
        });

        return false; // Prevent the default form submission
    }
</script>

