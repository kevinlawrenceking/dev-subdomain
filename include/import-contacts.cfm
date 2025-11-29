<!--- This ColdFusion page handles the import of contacts from an Excel template and displays the import history. --->

<script>
    function unlock() {
        document.getElementById('buttonSubmit').removeAttribute("disabled");
    }
</script>

<cfinclude template="/include/qry/imports.cfm" />

<cfparam name="step" default="1" />
<cfparam name="url.preview" default="false" />

<!--- ========================================
      PHASE 1: IMPORT PREVIEW
     ======================================== --->
<cfif url.preview EQ "true" AND structKeyExists(session, "pendingImport")>
    <cfset preview = session.pendingImport>
    <cfset validation = preview.validationResult>

    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-body">
                    <h4 class="header-title">Import Preview - Review Before Importing</h4>

                    <!--- Summary Alert --->
                    <div class="alert <cfif validation.errorCount GT 0>alert-warning<cfelse>alert-info</cfif>">
                        <h5><i class="fe-info mr-2"></i>Import Summary</h5>
                        <cfoutput>
                        <ul class="mb-0">
                            <li><strong>#validation.newCount#</strong> new contact(s) will be created</li>
                            <li><strong>#validation.updateCount#</strong> existing contact(s) will be updated (duplicates detected)</li>
                            <cfif validation.errorCount GT 0>
                                <li class="text-danger"><strong>#validation.errorCount#</strong> row(s) have errors and will be skipped</li>
                            </cfif>
                        </ul>
                        <p class="mt-2 mb-0"><strong>File:</strong> #preview.filename# | <strong>Uploaded:</strong> #dateFormat(preview.uploadDate, "mm/dd/yyyy")# #timeFormat(preview.uploadDate, "h:mm tt")#</p>
                        </cfoutput>
                    </div>

                    <!--- Errors Section --->
                    <cfif validation.errorCount GT 0>
                        <div class="alert alert-danger">
                            <h5><i class="fe-alert-triangle mr-2"></i>Errors Found (#validation.errorCount#)</h5>
                            <p>The following rows have validation errors and will <strong>not</strong> be imported:</p>
                            <div style="max-height: 300px; overflow-y: auto;">
                                <table class="table table-sm table-bordered">
                                    <thead>
                                        <tr>
                                            <th>Row</th>
                                            <th>Name</th>
                                            <th>Errors</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfoutput>
                                        <cfloop array="#validation.errors#" index="error">
                                            <tr>
                                                <td>#error.row#</td>
                                                <td>#error.name#</td>
                                                <td>
                                                    <ul class="mb-0 pl-3">
                                                        <cfloop array="#error.errors#" index="errMsg">
                                                            <li><small>#errMsg#</small></li>
                                                        </cfloop>
                                                    </ul>
                                                </td>
                                            </tr>
                                        </cfloop>
                                        </cfoutput>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </cfif>

                    <!--- Duplicates Section --->
                    <cfif validation.updateCount GT 0>
                        <div class="alert alert-info">
                            <h5><i class="fe-users mr-2"></i>Duplicates Found (#validation.updateCount#)</h5>
                            <p>The following contacts already exist and will be <strong>updated</strong> with new information:</p>
                            <div style="max-height: 300px; overflow-y: auto;">
                                <table class="table table-sm table-bordered">
                                    <thead>
                                        <tr>
                                            <th>Row</th>
                                            <th>Imported Name</th>
                                            <th>Matches Existing</th>
                                            <th>Match Type</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfoutput>
                                        <cfloop array="#validation.duplicates#" index="dup">
                                            <tr>
                                                <td>#dup.row#</td>
                                                <td>#dup.name#</td>
                                                <td>
                                                    <a href="/app/contact/index.cfm?contactid=#dup.contactid#" target="_blank">
                                                        #dup.matchedContact#
                                                    </a>
                                                </td>
                                                <td><span class="badge badge-secondary">#dup.matchType#</span></td>
                                            </tr>
                                        </cfloop>
                                        </cfoutput>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </cfif>

                    <!--- Action Buttons --->
                    <div class="mt-4">
                        <cfoutput>
                        <form method="post" action="/include/upload_confirm.cfm" class="d-inline">
                            <input type="hidden" name="uploadid" value="#preview.uploadid#">
                            <button type="submit" class="btn btn-success"
                                    <cfif validation.errorCount EQ validation.newCount + validation.updateCount + validation.errorCount>disabled</cfif>>
                                <i class="fe-check mr-1"></i>
                                Confirm and Import
                                <cfif validation.newCount + validation.updateCount GT 0>
                                    (#validation.newCount + validation.updateCount# contacts)
                                </cfif>
                            </button>
                        </form>
                        </cfoutput>
                        <a href="/app/contacts-import/" class="btn btn-secondary">
                            <i class="fe-x mr-1"></i> Cancel
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!--- Clear the session after showing preview --->
    <!--- <cfset structDelete(session, "pendingImport")> --->

<cfelseif isDefined('uploadid')>
    <!--- Include upload details if upload ID is defined --->
    <cfinclude template="/include/qry/upload_details_141_1.cfm" />
    
    <cfset conlist = valuelist(upload_details.contactid) />
    <cfinclude template="/include/qry/results_141_2.cfm" />

    <h6>
        <cfoutput>#results.recordcount# relationship contacts were imported. Click on a name to view details.</cfoutput>
    </h6>
    
    <table id="basic-datatable" class="table display dt-responsive nowrap w-100 table-striped" role="grid">
        <thead>
            <cfoutput query="results" maxrows="1">
                <cfif (Results.CurrentRow MOD 2)>
                    <cfset rowtype = "Odd" />
                <cfelse>
                    <cfset rowtype = "Even" />
                </cfif>

                <tr class="#rowtype#">
                    <th>#head1#</th>
                    <th>#head2#</th>
                    <th>#head3#</th>
                    <th>#head4#</th>
                    <th>#head5#</th>
                    <th>#head6#</th>
                </tr>
            </cfoutput>
        </thead>
        <tbody>
            <cfloop query="results">
                <!--- Process each result row --->
                <cfset phonenumber = results.col3 />
                <cfset cleanPhoneNumber = reReplace(phoneNumber, "[^0-9]", "", "ALL")>

                <cfif len(cleanPhoneNumber) is "10">
                    <cfoutput>
                        <cfset formatPhoneNumber = "(#left(cleanPhoneNumber, 3)#) #mid(cleanPhoneNumber, 4, 3)#-#right(cleanPhoneNumber, 4)#" />
                        <cfset anchorPhoneNumber = "#left(cleanPhoneNumber, 3)#-#mid(cleanPhoneNumber, 4, 3)#-#right(cleanPhoneNumber, 4)#" />
                    </cfoutput>
                <cfelse>
                    <cfoutput>
                        <cfset formatPhoneNumber = "#phoneNumber#*" /> 
                        <cfset anchorPhoneNumber = "#cleanPhoneNumber#*" /> 
                    </cfoutput>
                </cfif>

                <cfoutput>
                    <cfset cur_link = "/app/contact/index.cfm?contactid=#results.contactid#" />

                    <tr role="row">
                        <td>
                            <a href="#cur_link#" class="text-body font-weight-semibold">
                                #results.col1#
                            </a>
                        </td>
                        <td>#col2#</td>
                        <td><a href="tel:#anchorPhoneNumber#">#formatPhoneNumber#</a></td>
                        <td>#col4#</td>
                        <td>#col5#</td>
                        <td>
                            <cfif status is not "Added">
                                <font color="red">#status#</font>
                            <cfelse>
                                #status#
                            </cfif>
                        </td>
                    </tr>
                </cfoutput>
            </cfloop>
        </tbody>
    </table>

<cfelse>
    <!--- Display the import template upload form if upload ID is not defined --->
    <div class="row">
        <div class="col-12">
            <div class="card mb-3">
                <div class="card-body">
                    <h5>Step One: Download Import Template</h5>
                    <p>Download the import template in your preferred format:</p>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <div class="card border">
                                <div class="card-body text-center">
                                    <i class="fe-file-text" style="font-size: 2rem; color: #28a745;"></i>
                                    <h6 class="mt-2">CSV Template</h6>
                                    <p class="text-muted small">Works with Excel, Numbers, and Google Sheets</p>
                                    <a href="/include/download_contact_template.cfm?format=csv" target="_blank" class="btn btn-success btn-sm">
                                        <i class="fe-download mr-1"></i> Download CSV
                                    </a>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="card border">
                                <div class="card-body text-center">
                                    <i class="fe-file" style="font-size: 2rem; color: #217346;"></i>
                                    <h6 class="mt-2">Excel Template</h6>
                                    <p class="text-muted small">Traditional Excel format (.xlsx)</p>
                                    <a href="/include/download_contact_template.cfm?format=xlsx" target="_blank" class="btn btn-success btn-sm">
                                        <i class="fe-download mr-1"></i> Download Excel
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="alert alert-info">
                        <i class="fe-info mr-2"></i>
                        <strong>Mac Users:</strong> We recommend using the <strong>CSV template</strong> which opens perfectly in Apple Numbers, Excel, and Google Sheets.
                    </div>

                    <hr class="my-4">

                    <h5>Step Two: Upload Your Completed File</h5>
                    <p>Fill in your contacts in the template, save it, and upload the file below.</p>
                    <p class="text-muted small">Accepted formats: <strong>.xlsx</strong> (Excel) or <strong>.csv</strong> (Comma-separated values)</p>

                    <form action="/include/upload.cfm" method="post" enctype="multipart/form-data" id="upload">
                        <cfoutput>
                            <input type="hidden" name="userid" value="#userid#" />
                        </cfoutput>

                        <div class="custom-file mb-3">
                            <input type="file" class="custom-file-input" id="fileUpload" name="file"
                                   accept=".xlsx,.csv" onchange="unlock(); updateFileName(this);" required>
                            <label class="custom-file-label" for="fileUpload">Choose file...</label>
                        </div>

                        <button type="submit" id="buttonSubmit" disabled
                                class="btn btn-primary waves-effect waves-light"
                                style="background-color: #406e8e; border: #406e8e">
                            <i class="fe-upload mr-1"></i> Upload and Preview
                        </button>
                    </form>

                    <div class="dropzone-previews mt-3" id="file-previews"></div>
                </div>
            </div>

            <script>
            function updateFileName(input) {
                var fileName = input.files[0].name;
                var label = input.nextElementSibling;
                label.textContent = fileName;
            }
            </script>    
        </div>
    </div>

    <div class="row">
        <div class="col-12">
            <div class="card mb-3">
                <div class="card-body">
                    <h4 class="header-title">Import History <span class="small right"></span></h4>
                    <div class="d-flex justify-content-between">
                        <div class="float-left">
                            <cfoutput>
                                <p>You have <strong>#imports.recordcount#</strong> imports</p>
                            </cfoutput>
                        </div>
                    </div>

                    <table id="basic-datatable" class="table dt-responsive nowrap w-100 table-striped" role="grid">
                        <thead>
                            <tr class="#rowtype#">
                                <th width="50">Total Import</th>
                                <th>Batch ID</th>
                                <th>Date</th>
                                <th>Time</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="imports">
                                <cfoutput>
                                    <tr>
                                        <td><a title="View" href="/app/contacts/?byimport=#imports.uploadid#">#imports.total_adds#</a></td>
                                        <td>#imports.uploadid#</td>
                                        <td>#this.formatDate(imports.timestamp)#</td>
                                        <td>#timeFormat(imports.timestamp)#</td>
                                    </tr>
                                </cfoutput>
                            </cfloop>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</cfif>

<script>
    $(document).ready(function() {
        $("#basic-datatable").DataTable({
            "pageLength": 100,
            responsive: true,
            language: {
                paginate: {
                    previous: "<i class='mdi mdi-chevron-left'>",
                    next: "<i class='mdi mdi-chevron-right'>"
                }
            },
            drawCallback: function() {
                $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
            }
        });
        
        var a = $("#datatable-buttons").DataTable({
            lengthChange: false,
            buttons: [{
                extend: "copy",
                className: "btn-light"
            }, {
                extend: "print",
                className: "btn-light"
            }, {
                extend: "pdf",
                className: "btn-light"
            }],
            language: {
                paginate: {
                    previous: "<i class='mdi mdi-chevron-left'>",
                    next: "<i class='mdi mdi-chevron-right'>"
                }
            },
            drawCallback: function() {
                $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
            }
        });
    });
</script>
