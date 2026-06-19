<!--- This ColdFusion page handles the upload of a headshot file with validation and media type selection. --->

<script>
    $(document).keypress(function (e) {
        <!--- Prevent form submission on Enter key press if not in a textarea. --->
        if (e.which == 13 && e.target.nodeName != "TEXTAREA") {
            event.preventDefault();
            return false;
        }
    });
</script>

<script>
    <!--- 20 MB matches the ColdFusion post-size limit. Catching it here gives
          the user a clear message instead of the generic "Post Size exceeds
          the maximum limit 20 MB" exception (4 such errors in the log). The
          server-side guard in Application.cfc onError is the backstop. --->
    var TAO_MAX_UPLOAD_BYTES = 20 * 1024 * 1024;

    function unlock(inputEl) {
        var btn = document.getElementById('buttonSubmit');
        var file = inputEl && inputEl.files && inputEl.files.length ? inputEl.files[0] : null;
        if (file && file.size > TAO_MAX_UPLOAD_BYTES) {
            alert('That file is too large (' + (file.size / 1048576).toFixed(1) +
                  ' MB). The maximum upload size is 20 MB. Please choose a smaller file.');
            inputEl.value = '';                 // clear the oversized selection
            btn.setAttribute('disabled', 'disabled');
            return;
        }
        <!--- Enable the submit button only for a valid selection. --->
        btn.removeAttribute("disabled");
    }
</script>

<cfparam name="placeholder" default="" />
<cfparam name="eventid" default="" />

<cfinclude template="/include/qry/getAuditionMediaTypes.cfm" /> 

<form action="/include/remoteaddHeadshot2.cfm" method="post" class="parsley-examples" enctype="multipart/form-data" id="upload" 
      data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden"
      data-parsley-trigger="keyup" data-parsley-validate>
    <input type="hidden" name="new_mediatypeid" value="1" />

    <div class="row" />

    <cfset placeholder="https://" />
    <cfset minlength="3" />

    <cfif isdefined('gfdgf')>
        <!--- Check if 'gfdgf' is defined and display media type selection. --->
        <div class="form-group col-md-6 col-sm-12">
            <label for="new_mediatypeid">Media Type<span class="text-danger">*</span></label>
            <select id="new_mediatypeid" name="new_mediatypeid" class="form-control" data-parsley-required data-parsley-error-message="Media Type is required">
                <cfoutput query="type">
                    <option value="#type.mediatypeid#">#type.mediatype#</option>
                </cfoutput>
            </select>
        </div>
    </cfif> 

    <div class="form-group col-md-12">
        <label for="attachmenturl">Upload File <span class="text-danger">*</span></label>
        <p>
            <input name="file" onchange="unlock(this);" type="file" />
        </p>
    </div>

    <div class="form-group text-center col-md-12">
        <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit" id="buttonSubmit" disabled style="background-color: #406e8e; border: #406e8e;">Upload</button>
    </div>

    <div class="form-group col-md-12">
        <label for="new_medianame">Name<span class="text-danger">*</span></label>
        <input class="form-control" type="text" id="new_medianame" data-parsley-required="true" data-parsley-error-message="Valid Name is required" name="new_medianame" data-parsley-maxlength="800" data-parsley-maxlength-message="Max length 800 characters" placeholder="Add a name/brief description" />
    </div>
</form>

<script>      
    $(document).ready(function() {
        <!--- Initialize Parsley validation on the form. --->
        $(".parsley-examples").parsley();
    });
</script>

