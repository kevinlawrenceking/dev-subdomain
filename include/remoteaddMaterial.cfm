<!--- This ColdFusion page handles the submission of media materials, including file uploads and form validation. --->

<cfparam name="audprojectid" default="0" />

<script>
    $(document).keypress(function (e) {
        <!--- Prevent form submission on Enter key press if not in a textarea --->
        if (e.which == 13 && e.target.nodeName != "TEXTAREA") {
            event.preventDefault();
            return false;
        }
    });
</script>

<script>
    function unlock() {
        <!--- Enable the submit button when called --->
        document.getElementById('buttonSubmit').removeAttribute("disabled");
    }
</script>

<cfparam name="placeholder" default="" />
<cfparam name="eventid" default="" />

<cfinclude template="/include/qry/SEL_Media_types_material.cfm" />

<form action="/include/remoteaddMaterial2.cfm" method="post" class="parsley-examples" enctype="multipart/form-data" id="upload" 
      data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" 
      data-parsley-trigger="keyup" data-parsley-validate>
    
    <cfoutput>
        <input type="hidden" name="src" value="#src#" />
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
    </cfoutput>

    <div class="row" />

    <cfset placeholder="https://" />
    <cfset minlength="3" />

    <div class="form-group col-md-6 col-sm-12">
        <label for="new_mediatypeid">Media Type<span class="text-danger">*</span></label>
        <select id="new_mediatypeid" name="new_mediatypeid" class="form-control" data-parsley-required data-parsley-error-message="Media Type is required">
            <option value="">SELECT A TYPE</option>
            <cfoutput query="type">
                <option value="#type.mediatypeid#">#type.mediatype#</option>
            </cfoutput>
        </select>
    </div>

    <div class="form-group col-md-12">
        <label for="new_medianame">Name<span class="text-danger">*</span></label>
        <input class="form-control" type="text" id="new_medianame" name="new_medianame" 
               data-parsley-maxlength="800" 
               data-parsley-maxlength-message="Max length 800 characters"  
               data-parsley-required data-parsley-error-message="Media Name is required"  
               placeholder="Add a name/brief description">
    </div>

    <div class="form-group col-md-12">
        <label for="new_medialoc">URL</label>
        <input class="form-control" type="text" id="new_mediaurl" name="new_mediaurl" 
               data-parsley-maxlength="800" 
               data-parsley-maxlength-message="Max length 800 characters"    
               placeholder="Add a URL">
    </div>

    <cfif #src# is "account">
        <cfoutput>
            <input type="hidden" name="new_isshare" value="#new_isshare#" />
        </cfoutput>
    <cfelse>
        <div class="form-group col-md-6 col-sm-12">
            <label for="new_mediatypeid">Save to My Materials?<span class="text-danger">*</span></label>
            <select id="new_isShare" name="new_isShare" class="form-control" data-parsley-required data-parsley-error-message="Shareable is required">
                <option value="1">Yes</option>
                <option value="0" selected>No</option>
            </select>
        </div>
    </cfif>

    <div class="form-group col-md-12">
        <label for="attachmenturl">Upload File (optional)</label>
       
       <input name="file" type="file" id="fileUpload" style="display: none;">
        </p><label for="fileUpload" class="btn btn-primary btn-sm">Choose File</label>
    </div>

    <div class="form-group text-center col-md-12">
        <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit" id="buttonSubmit" 
                style="background-color: #406e8e; border: #406e8e;">Add</button>
    </div>
</form>

<script>
    $(document).ready(function() {
        <!--- Initialize Parsley for form validation --->
        $(".parsley-examples").parsley();
    });
</script>
