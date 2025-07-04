<!--- This ColdFusion page handles the submission of a form to add a new site with validation for site name and URL. --->

<cfparam name="target" default="myaccount" />

<form action="/include/remotelinkadd2.cfm" method="post" class="parsley-examples" 
      data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden"
      data-parsley-trigger="keyup" 
      data-parsley-validate id="profile-form">
  
    <!--- Output hidden fields for form submission --->
    <cfoutput>  
        <input type="hidden" name="new_sitetypeid" value="#New_sitetypeid#" />
        <input type="hidden" name="userid" value="#userid#" />
        <input type="hidden" name="target_id" value="#new_sitetypeid#" />
        <input type="hidden" name="target" value="#target#" />
        <input type="hidden" name="application.retinaIcons14Path" value="#application.retinaIcons14Path#" />
    </cfoutput>

    <div class="row">
        <div class="form-group col-md-12">
            <!--- Site Name input field with validation --->
            <div class="form-group col-md-12">
                <label for="new_siteName">Site Name<span class="text-danger">*</span></label>
                <input class="form-control" type="text" id="new_siteName" name="new_siteName"  
                       data-parsley-minlength="3" 
                       data-parsley-minlength-message="Min length 3 characters" 
                       data-parsley-maxlength="200" 
                       data-parsley-maxlength-message="Max length 200 characters" 
                       data-parsley-trigger="focusout" 
                       data-parsley-checksitename 
                       data-parsley-checksitename-message="Site Name already Exists"
                       placeholder="Enter Site Name">
            </div>

            <!--- Site URL input field with validation --->
            <div class="form-group col-md-12">
                <label for="new_siteurl">URL<span class="text-danger">*</span></label>
                <input class="form-control" type="text" id="new_siteurl" name="new_siteurl"  
                       data-parsley-minlength="4" 
                       data-parsley-trigger="focusout" 
                       data-parsley-checksiteurl 
                       data-parsley-checksiteurl-message="Site URL already Exists"
                       placeholder="Enter your URL">
            </div>

            <!--- Submit button for the form --->
            <div class="form-group text-center col-md-12">
                <button id="submit-btn" class="btn btn-primary editable-submit btn-sm waves-effect waves-light" 
                        type="submit" style="background-color: #406e8e; border: ##406e8e;">
                    <span id="btn-text">Add</span>
                    <span id="spinner" class="spinner-border spinner-border-sm" role="status" 

style="display:none;"></span>
                </button>
            </div>
        </div>
    </div>
</form>

<script>
    // Handle form submission to change button text and show spinner
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
    // Initialize Parsley validation on the form
    $(document).ready(function() {
        $(".parsley-examples").parsley();
    });
</script> 

<script>
    // Custom validator for checking site name
    $(document).ready(function() {
        $('#new_siteName').parsley();

        window.Parsley.addValidator('checksitename', {
            validateString: function(value) {
                return $.ajax({
                    url: '/include/fetch_sitename.cfm?userID=<Cfoutput>#userid#</cfoutput>',
                    method: "POST",
                    data: { sitename: value },
                    dataType: "json",
                    success: function(data) {
                        return true;
                    }
                });
            }
        });
    });
</script>

<script>
    // Custom validator for checking site URL
    $(document).ready(function() {
        $('#new_siteurl').parsley();

        window.Parsley.addValidator('checksiteurl', {
            validateString: function(value) {
                return $.ajax({
                    url: '/include/fetch_siteurl.cfm?userID=<Cfoutput>#userid#</cfoutput>',
                    method: "POST",
                    data: { siteurl: value },
                    dataType: "json",
                    success: function(data) {
                        return true;
                    }
                });
            }
        });
    });
</script>
