<!--- This ColdFusion page handles the submission of a form to add a new panel with validation and user feedback. --->

<form action="/include/remotePaneladd2.cfm" method="post" class="parsley-examples" 
      data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden"
      data-parsley-trigger="keyup" data-parsley-validate id="profile-form">

    <!--- Output hidden fields for user ID and return page --->
    <cfoutput> 
        <input type="hidden" name="userid" value="#userid#" />
        <input type="hidden" name="pgrtn" value="#pgrtn#" />
    </cfoutput>

    <div class="row">
        <div class="form-group col-md-12">
            <div class="form-group col-md-12">
                <label for="new_pnTitle">Panel Name<span class="text-danger">*</span></label>
                <input class="form-control" type="text" id="new_sitetypename" name="new_sitetypename"
                       data-parsley-required="true"
                       data-parsley-trigger="focusout"
                       data-parsley-checksitetypename
                       data-parsley-checksitetypename-message="Panel already Exists"
                       placeholder="Enter Panel Name">
            </div>

            <div class="form-group text-center col-md-12">
                <button id="submit-btn" class="btn btn-primary editable-submit btn-sm waves-effect waves-light" 
                        type="submit" style="background-color: #406e8e; border: #406e8e;">
                    <span id="btn-text">Add</span>
                    <span id="spinner" class="spinner-border spinner-border-sm" role="status" 

style="display:none;"></span>
                </button>
            </div>
        </div>
    </div>
</form>

<script>
    //--- Event listener for form submission to handle button state and spinner display ---
    document.getElementById('profile-form').addEventListener('submit', function() {
        var submitButton = document.getElementById('submit-btn');
        var buttonText = document.getElementById('btn-text');
        var spinner = document.getElementById('spinner');

        // Change button text to "Adding..."
        buttonText.textContent = 'Adding...';

        // Show the spinner
        spinner.style.display = 'inline-block';

        // Disable the button to prevent multiple submissions
        submitButton.disabled = true;
    });
</script>

<script>
    //--- Initialize Parsley validation on document ready ---
    $(document).ready(function() {
        $(".parsley-examples").parsley();
    });
</script>

<script>
    //--- Custom validator for checking if the site type name already exists ---
    $(document).ready(function() {
        $('#new_sitetypename').parsley();

        window.Parsley.addValidator('checksitetypename', {
            validateString: function(value) {
                return $.ajax({
                    url: '/include/fetch_sitetypename.cfm?userID=<cfoutput>#userID#</cfoutput>',
                    method: "POST",
                    data: { sitetypename: value },
                    dataType: "json",
                    success: function(data) {
                        return true;
                    }
                });
            }
        });
    });
</script>
