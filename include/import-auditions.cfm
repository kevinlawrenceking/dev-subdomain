<!--- This ColdFusion page handles the import of audition templates, allowing users to upload files and view import results. --->

<cfparam name="step" default="1" />

<script>
    <!--- Function to enable the submit button when a file is selected --->
    function unlock() {
        document.getElementById('buttonSubmit').removeAttribute("disabled");
    }
</script>

<!--- Form for uploading the template --->
<div class="row">
    <div class="col-12">
        <div class="card mb-3">
            <div class="card-body">
                <h5>Step One: Import Template</h5>
                <cfoutput>
                <p>
                    Download the 
                    <a href="#application.auditionimporttemplate#" download target="new">
                        <strong><i class="fe-upload"></i> Import Template</strong>
                    </a> 
                    to copy and paste all the events you'd like to import. 
                    <strong>Imports must be in this format.</strong>
                </p>
                </cfoutput>
                <h5>Step Two: Upload Template</h5>
                <p>Once you've populated and saved the Import Template as an .xlsx file, select the file and upload.</p>

                <form action="/include/upload_audition.cfm" method="post" enctype="multipart/form-data" id="upload">
                    <cfoutput>
                        <input type="hidden" name="userid" value="#userid#" />
                    </cfoutput>
                    <input name="file" onchange="unlock();" type="file" />
                    <p></p>
                    <input type="submit" value="Upload" class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: #406e8e; border: #406e8e" id="buttonSubmit" disabled />
                </form>
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
            <div class="card mb-3">
                <div class="card-body">
                    <h4 class="header-title">Events imported <span class="small right"></span></h4>
                    <div class="d-flex justify-content-between">
                        <div class="float-left">
                            <cfoutput>
                                <p>#results.recordcount# events were imported. Click on a name to view details.</p>
                            </cfoutput>
                        </div>
                    </div>
                    <table id="basic-datatable" class="table display dt-responsive nowrap w-100 table-striped" role="grid">
                        <thead>
                            <cfoutput query="results" maxrows="1">
                                <tr>
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
                                <!--- Include error details for each result --->
                                <cfinclude template="/include/qry/errs_125_2.cfm" />
                                <cfset err_list = valuelist(errs.error_msg)>
                                <cfoutput>
                                    <cfif results.currentrow MOD 2 EQ 1>
                                        <cfset newclass="odd">
                                    <cfelse>
                                        <cfset newclass="even">
                                    </cfif>
                                    <tr class="#newclass#" role="row" id="row-#results.id#">
                                        <td>
                                            <a href="/app/audition/?audprojectid=#results.audprojectid#" class="text-body font-weight-semibold">
                                                <cfset myDateTime = results.col1b>
                                                <cfset myFormattedDateTime = this.formatDate(myDateTime)>
                                                #myFormattedDateTime#
                                            </a>
                                        </td>
                                        <td>
                                            <cfif len(results.audprojectid)>
                                                <a href="/app/audition/?audprojectid=#results.audprojectid#">#col2#</a>
                                            <cfelse>
                                                #col2#
                                            </cfif>
                                        </td>
                                        <td>#col3#</td>
                                        <td>#col4#</td>
                                        <td>#col5#</td>
                                        <td>
                                            <cfif col6 EQ "invalid">
                                                <a href="javascript:void(0);" data-toggle="modal" data-target="##fixModal" onclick="loadForm(#results.id#)" title="#err_list#">
                                                    <font color="red">Invalid <i class="fe-search"></i></font>
                                                    <button type="button" class="btn btn-sm btn-warning" onclick="loadForm(#results.id#)">Fix</button>
                                                </a>
                                            <cfelse>
                                                #col6#
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
</cfif>

<!--- Always show import history if record count is not zero --->
<cfinclude template="/include/qry/auditions_import.cfm" />

<cfif imports.recordcount GT 0>
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
                    <table id="basic-datatable-history" class="table dt-responsive nowrap w-100 table-striped" role="grid">
                        <thead>
                            <tr>
                                <th width="50">Batch ID</th>
                                <th>Date</th>
                                <th>Time</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="imports">
                                <cfoutput>
                                    <tr>
                                        <td><a title="View" href="/app/auditions/?byimport=#imports.uploadid#">#imports.uploadid#</a></td>
                                        <td>#this.formatDate(imports.timestamp)#</td>
                                        <td>#timeformat(imports.timestamp)#</td>
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

