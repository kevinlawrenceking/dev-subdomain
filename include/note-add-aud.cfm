<!--- This ColdFusion page handles the display and submission of notes related to a contact, including visibility options and a text editor for note details. --->

<cfinclude template="/include/qry/relationships_13_1.cfm" />

<div class="row">

    <div class="col-xl-6 col-lg-8 col-md-12">
        <div class="card mb-3">
            <div class="card-body">
                
                <!--- Display the full name of the details --->
                <cfoutput>
                    <h4>#details.fullName#</h4>
                </cfoutput> 

                <!--- Form for adding a note --->
                <cfform method="post" action="/include/note-add-aud2.cfm" class="parsley-examples" name="event-form" id="form-event" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate>
                    
                    <cfoutput>
                        <!--- Hidden inputs for form submission --->
                        <input type="hidden" name="returnurl" value="#returnurl#" />
                        <input type="hidden" name="rcontactid" value="#contactid#" />
                        <input type="hidden" name="audprojectid" value="#audprojectid#" />
                        <input type="hidden" name="userid" value="#userid#" />
                    </cfoutput>
                    
                    <div class="row">
                        <div class="form-group col-md-12">
                            <label for="noteDetails">Note Title<span class="text-danger">*</span></label>
                            <input class="form-control" type="text" name="noteDetails" id="noteDetails" data-parsley-required />
                        </div>
                        <div class="form-group col-md-12">
                            <p>For more detailed notes, use the built-in text editor below:</p>
                        </div>           
                        
                        <div class="form-group col-md-12">
                            <label for="snow-editor">Details (Optional)</label>
                            <div id="snow-editor" style="height: 200px;"></div>
                        </div>
                        
                        <div class="form-group col-md-12">&nbsp;</div>
                        
                        <!--- Conditional visibility selection based on return URL --->
                        <cfif "#returnurl#" is "contact">
                            <div class="form-group col-md-12">
                                <label for="audTypeName">Who can see your note?<span class="text-danger">*</span> &nbsp; 
                                    <a class="primary" href="" data-bs-toggle="modal" data-bs-target="#helpmodal">
                                        <i class="mdi mdi-help-circle" style="color:black; font-size:1em;"></i>
                                    </a>
                                </label>
                                <select class="form-control" style="max-width:300px;" name="isPublic" id="isPublic" data-parsley-required data-parsley-error-message="Note type is required">
                                    <option value="1" selected>Public</option>
                                    <option value="0">Private</option>
                                </select>
                            </div>
                        <cfelse>
                            <input type="hidden" name="isPublic" value="0" />
                        </cfif>
                    </div>

                    <div class="row mt-2">
                        <textarea name="notetext" style="display:none" id="hiddenArea"></textarea>
                        <div class="col-md-12">
                            <a href="javascript:history.go(-1)">
                                <button type="button" class="btn btn-light mr-1 btn-sm" data-bs-dismiss="modal">Back</button>
                            </a>
                            <button type="submit" class="btn btn-primary btn-sm waves-effect waves-light" id="btn-save-event">Add</button>
                        </div>
                    </div>
                </cfform>
            </div>
        </div>
    </div>
</div>

<!--- Modal for help regarding note visibility --->
<div class="modal" id="helpmodal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Who can see your note?</h5>
                <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                    <span >
&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Notes with a status of <strong>Public</strong> will appear in the Team Share link for your team to view as well.</p>
                <p>Notes with a status of <strong>Private</strong> will be for your eyes only.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<script>
    $(document).ready(function() {
        $(".parsley-examples").parsley();
    });
</script>

<script>
    $("#form-event").on("submit", function() {
        $("#hiddenArea").val($("#snow-editor").html());
    });
</script>

<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), " \")#" />

