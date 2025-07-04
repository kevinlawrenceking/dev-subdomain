<!--- This ColdFusion page handles the ticket update form for the admin support system. --->
<cfset sel_search = "">
<cfparam name="select_userid" default="%" />
<cfparam name="select_ticketstatus" default="%" />
<cfparam name="select_tickettype" default="%" />     
<cfparam name="select_pgid" default="%" />  

<div class="row">
    <div class="col-xl-6 col-lg-8 col-md-12">
        <div class="card mb-3">
            <div class="card-body">
                <form method="post" action="/include/admin-support-update2.cfm" class="parsley-examples" name="ticket-form" id="form-ticket" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate>
                    <cfoutput>
                        <!--- Hidden Fields --->
                        <input type="hidden" name="verid" value="#ticketDetails.verid#" />
                        <input type="hidden" name="ticketid" value="#ticketDetails.ticketid#" />
                        <input type="hidden" name="recid" value="#ticketDetails.ticketid#" />
                        <input type="hidden" name="old_ticketName" value="#ticketDetails.ticketName#" />
                        <input type="hidden" name="old_pgid" value="#ticketDetails.pgid#" />
                        <input type="hidden" name="old_userid" value="#ticketDetails.userid#" />
                        <input type="hidden" name="old_tickettype" value="#ticketDetails.tickettype#" />
                        <input type="hidden" name="old_environ" value="#ticketDetails.environ#" />
                        <input type="hidden" name="old_ticketpriority" value="#ticketDetails.ticketpriority#" />
                        <input type="hidden" name="old_ticketdetails" value="#ticketDetails.ticketdetails#" />
                        <input type="hidden" name="old_ticketResponse" value="#ticketDetails.ticketResponse#" />
                        <input type="hidden" name="old_verid" value="#ticketDetails.verid#" />
                        <input type="hidden" name="old_estHours" value="#ticketDetails.estHours#" />
                        <input type="hidden" name="old_testingscript" value="#ticketDetails.testingscript#" />
                        <input type="hidden" name="old_patchnote" value="#ticketDetails.patchnote#" />
                        <input type="hidden" name="old_customTestPageName" value="#ticketDetails.customTestPageName#" />
                        <input type="hidden" name="old_customTestPageLink" value="#ticketDetails.customTestPageLink#" />

                        <div class="row">
                            <div class="col-12">
                                <div class="form-group">
                                    <label class="control-label">Name<span class="text-danger">*</span></label>
                                    <input class="form-control" placeholder="Add Ticket Name" value="#ticketDetails.ticketName#" type="text" name="new_ticketName" id="new_ticketName" data-parsley-minlength="3" data-parsley-minlength-message="Min length 3 characters" data-parsley-maxlength="200" data-parsley-maxlength-message="Max length 200 characters" data-parsley-required data-parsley-error-message="Name is required" />  
                                </div>
                            </div>
                        </div>

                    </cfoutput>

                    <!--- Select Fields --->
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="new_pgid">Page<span class="text-danger">*</span></label>
                                <select class="form-control" name="new_pgid" id="new_pgid" required>
                                    <cfoutput query="pages">
                                        <option value="#pages.id#" <cfif pages.id EQ ticketDetails.pgid> selected </cfif>>#pages.name#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="new_userid">Requester<span class="text-danger">*</span></label>
                                <select class="form-control" name="new_userid" id="new_userid" required>
                                    <cfoutput query="users">
                                        <option value="#users.id#" <cfif users.id EQ ticketDetails.userid> selected </cfif>>#users.name#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="new_ticketstatus">Status<span class="text-danger">*</span></label>
                                <select class="form-control" name="new_ticketstatus" id="new_ticketstatus" required>
                                    <cfoutput query="ticketStatuses">
                                        <option value="#ticketStatuses.id#" <cfif ticketStatuses.id EQ ticketDetails.ticketstatus> selected </cfif>>#ticketStatuses.name#</option>
                                    </cfoutput>
                                </select>
                                <input type="hidden" name="old_ticketstatus" value="#ticketDetails.ticketstatus#" />
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="new_tickettype">Type<span class="text-danger">*</span></label>
                                <select class="form-control" name="new_tickettype" id="new_tickettype" required>
                                    <cfoutput query="ticketTypes">
                                        <option value="#ticketTypes.id#" <cfif ticketTypes.id EQ ticketDetails.tickettype> selected </cfif>>#ticketTypes.name#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="new_environ">Environment<span class="text-danger">*</span></label>
                                <select class="form-control" name="new_environ" id="new_environ" required>
                                    <option value="D" <cfif ticketDetails.environ EQ "D"> selected </cfif>>Development</option>
                                    <option value="P" <cfif ticketDetails.environ EQ "P"> selected </cfif>>Production</option>
                                </select>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="new_ticketpriority">Priority<span class="text-danger">*</span></label>
                                <select class="form-control" name="new_ticketpriority" id="new_ticketpriority" required>
                                    <cfoutput query="ticketPriorities">
                                        <option value="#ticketPriorities.id#" <cfif ticketPriorities.id EQ ticketDetails.ticketpriority> selected </cfif>>#ticketPriorities.name#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>

                        <div class="col-md-12">
                            <div class="form-group">
                                <label for="new_ticketDetails">Ticket Details<span class="text-danger">*</span></label>
                                <cfoutput>
                                    <textarea class="form-control" name="new_ticketDetails" id="new_ticketDetails" rows="2" required>#ticketDetails.ticketdetails#</textarea>
                                </cfoutput>
                            </div>

                            <div class="form-group">
                                <label for="new_ticketResponse">Developer Response</label>
                                <cfoutput>
                                    <textarea class="form-control" name="new_ticketResponse" id="new_ticketResponse" rows="2">#ticketDetails.ticketResponse#</textarea>
                                </cfoutput>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="new_estHours">Est. Hours<span class="text-danger">*</span></label>
                                <select class="form-control" name="new_estHours" id="new_estHours" required>
                                    <cfloop index="z" step=".25" from="0" to="50">
                                        <cfoutput>
                                            <option value="#z#" <cfif z EQ ticketDetails.esthours> selected </cfif>>#z#</option>
                                        </cfoutput>
                                    </cfloop>
                                </select>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="new_verid">Assigned Release</label>
                                <select class="form-control" name="new_verid" id="new_verid">
                                    <option value="">None</option>
                                    <cfoutput query="vers">
                                        <option value="#vers.id#" <cfif vers.id EQ ticketDetails.verid> selected </cfif>>#vers.name#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                    </div>

                    <cfoutput>
                        <!--- Patch Note and Testing Script --->
                        <div class="form-group">
                            <label for="new_patchNote">Patch Note</label>
                            <input class="form-control" placeholder="Add Patch Note" value="#ticketDetails.patchNote#" type="text" name="new_patchNote" id="new_patchNote" />
                        </div>

                        <div class="form-group">
                            <label for="new_testingscript">Testing Script</label>
                            <textarea class="form-control" name="new_testingscript" id="new_testingscript" rows="2">#ticketDetails.testingscript#</textarea>
                        </div>

                        <!--- Custom Test Page Info --->
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="new_customTestPageName">Custom Test Page Name</label>
                                    <input class="form-control" placeholder="Add Page Name" value="#ticketDetails.customTestPageName#" type="text" name="new_customTestPageName" id="new_customTestPageName" />
                                </div>
                            </div>

                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="new_customTestPageLink">Custom Test Page Link</label>
                                    <input class="form-control" placeholder="Add Page Link" value="#ticketDetails.customTestPageLink#" type="text" name="new_customTestPageLink" id="new_customTestPageLink" />
                                </div>
                            </div>
                        </div>

                    </cfoutput>
                    
                    <!--- Submit Button --->
                    <div class="row mt-2">
                        <div class="col-6"></div>
                        <div class="col-6 text-right">
                            <input type="submit" class="btn btn-primary btn-sm waves-effect waves-light" value="Update" />
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    $(document).ready(function() {
        $(".form-ticket").parsley();
    });

    $('#eventStartTime').timepicker();
    $('#eventStopTime').timepicker();
    $('#eventStart').datepicker({ autoclose: true });
    $('#endRecur').datepicker({ autoclose: true });
</script>
