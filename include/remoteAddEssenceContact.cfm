<!--- This ColdFusion page handles the submission of a form for adding a new essence. --->

<form method="post" action="/include/remoteaddessenceContact2.cfm" class="parsley-examples" name="version-form" id="form-version" 
      data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden"
      data-parsley-trigger="keyup" data-parsley-validate>
    
    <!--- Output hidden user ID field --->
    <cfoutput>
        <input type="hidden" name="userid" value="#userid#" />
    </cfoutput>

    <div class="row">
        <!--- Form group for essence input --->
        <cfoutput>
            <div class="form-group col-md-12">
                <label class="control-label">Essence</label>
                <input class="form-control" required type="text" name="new_essenceName" id="new_essenceName" />
            </div>
            <div class="invalid-feedback">
                Please enter an essence.
            </div>
        </cfoutput>
    </div>

    <div class="row mt-2">
        <div class="col-6">
            <!--- Empty column for layout --->
        </div>
        <div class="col-6 text-right">
            <!--- Conditional button for going back if variable is defined --->

            <button type="submit" class="btn btn-primary btn-sm waves-effect waves-light" id="btn-save-event">Add</button>
        </div>
    </div>
</form>
