<!--- This ColdFusion page handles the approval of testing instructions through a form submission. --->

<h4>Approve testing instructions</h4>

<form id="<cfoutput>approveform#details.recid#</cfoutput>" method="post" action="/include/testing3.cfm">

    <cfoutput query="details">

        <input type="hidden" name="new_ticketid" value="#details.recid#" />
        <input type="hidden" name="old_ticketstatus" value="#details.ticketstatus#" />
        
        <div class="form-group col-md-12">
            <label for="tickettype">Edit the testing instructions, if needed: </label>
            <textarea class="form-control" type="text" id="new_testingscript" name="new_testingscript" placeholder="Details" rows="4">#trim(details.testingscript)#</textarea>
        </div>

    </cfoutput>

    <div class="form-group col-md-3">
        <label for="new_ticketstatus">Test Status</label>
        <select class="form-control" name="new_ticketstatus" id="new_ticketstatus" required>
            
            <cfoutput query="statuses">

                <!--- Check if the current status matches the details status --->
                <cfif #statuses.name# is "#details.ticketstatus#">
                    <option value="#statuses.name#" selected>#statuses.name#</option>
                </cfif>

                <!--- If the status does not match, display it as an option --->
                <cfif #statuses.name# is not "#details.ticketstatus#">
                    <option value="#statuses.name#">#statuses.name#</option>
                </cfif>

            </cfoutput>

        </select>
    </div>

    <div class="row mt-2">
        <div class="col-6">
            <button onclick="form_submit()" type="submit" class="btn btn-primary btn-sm waves-effect waves-light" id="btn-save-event">
                Continue
            </button>
        </div>

        <div class="col-6 text-right">
            <a href="javascript:history.go(-1)">
                <button type="button" class="btn btn-light mr-1 btn-sm" data-bs-dismiss="modal">
                    Back
                </button>
            </a>
        </div>
    </div>

</form>
