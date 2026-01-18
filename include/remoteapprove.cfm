<!--- This ColdFusion page handles the approval process for tickets, displaying relevant details and allowing users to update test status and rejection notes. --->

<cfinclude template="/include/qry/details_212_1.cfm" />
<cfinclude template="/include/qry/users_212_2.cfm" />
<cfinclude template="/include/qry/find_212_3.cfm" />

<!--- Check if a record is found in the find query --->
<cfif #find.recordcount# is "1">
    <cfset testid = find.id />
    <cfoutput>
        <cfset new_teststatus = "#find.teststatus#" />
        <cfset new_rejectNotes = "#find.rejectNotes#" />
    </cfoutput>
<cfelse>
    <cfset testid = 0>
    <cfset new_teststatus = "" />
    <cfset new_rejectNotes = "" />
</cfif>

<div class="row">
    <cfset cur_icon="">
    
    <!--- Form for approving the ticket --->
    <form class="px-3 col-md-12" id="<cfoutput>approveform#details.recid#</cfoutput>" method="post" action="/include/remoteapprove2.cfm">
        <cfoutput query="details">
            <input type="hidden" name="oldverid" value="#oldverid#" />
            <input type="hidden" name="new_ticketid" value="#details.recid#" />
            <input type="hidden" name="testid" value="#testid#" />
            <input type="hidden" name="new_userid" value="#users.new_userid#" />  
            
            <div class="form-group col-md-12">
                <h5>Ticket No. #details.recid#</h5>
                <p>#details.ticketname#</p>
            </div>  
            
            <div class="form-group col-md-12">
                <h5>Tested By</h5>
                <p>#users.username#</p>
            </div>  
        </cfoutput>                            

        <div class="form-group col-md-6">
            <label for="tickettype">Test Status</label>
            <select class="form-control" name="new_teststatus" id="new_teststatus" required>
                <option value="Approved" <cfif #new_teststatus# is "Approved"> Selected </cfif> >Approved</option>
                <option value="Rejected" <cfif #new_teststatus# is "Rejected"> Selected </cfif> >Rejected</option>
            </select>
        </div>   

        <cfoutput>
            <div class="form-group col-md-12">
                <label for="tickettype">If Rejected, state reason:</label>
                <textarea class="form-control" type="text" id="new_rejectNotes" name="new_rejectNotes" placeholder="Details" rows="2">#new_rejectNotes#</textarea>    
            </div>  
        </cfoutput>
    </form>

    <div class="row mt-2">
        <div class="col-6"></div>
        <div class="col-6 text-right">
            <a href="javascript:history.go(-1)">
                <button type="button" class="btn btn-light mr-1 btn-sm" data-bs-dismiss="modal">Back</button>
            </a>
            <button onclick="form_submit()" type="submit" class="btn btn-primary btn-sm waves-effect waves-light" id="btn-save-event">Update</button>
        </div>
    </div>
</div>

<cfoutput>
    <script type="text/javascript">
        function form_submit() {
            document.getElementById("<cfoutput>approveform#details.recid#</cfoutput>").submit();
        }    
    </script>
</cfoutput>
