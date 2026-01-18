<!--- This ColdFusion page displays a modal for editing item details. --->
<cfparam name="url.itemid" default="">

<!--- Include item details query template --->
<cfinclude template="/include/qry/itemDetails_130_1.cfm" />

<cfoutput>
    <div class="modal-header">
        <h5 class="modal-title" id="editModalLabel">Edit Details</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span >
&times;</span>
        </button>
    </div>
    <div class="modal-body">
        <!--- Form for updating item details --->
        <form id="updateForm" class="parsley-examples" 
              data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" 
              data-parsley-trigger="keyup" 
              data-parsley-validate>
            <input type="hidden" name="itemid" value="#itemDetails.itemid#" />
            <div class="form-group">
                <label for="valueText">Text</label>
                <input type="text" class="form-control" id="valueText" name="valueText" value="#itemDetails.valueText#" required />
            </div>
            <button type="submit" class="btn btn-primary">Save changes</button>
        </form>
    </div>
</cfoutput>
