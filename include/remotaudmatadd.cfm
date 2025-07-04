<!--- This ColdFusion page handles the upload of media files with associated metadata. --->

<script>
    function unlock() {
        document.getElementById('buttonSubmit').removeAttribute("disabled");
    }
</script>

<cfparam name="placeholder" default="" />

<!--- Include the query for media types --->
<cfinclude template="/include/qry/types_45_1.cfm" />

<form action="/include/remoteaudmatadd2.cfm" method="post" class="parsley-examples" enctype="multipart/form-data" id="upload">
    <cfoutput>
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
    </cfoutput>

    <div class="row" />

    <cfset placeholder="https://" />
    <cfset minlength="3" />

    <div class="form-group col-md-6 col-sm-12">
        <label for="new_mediatypeid">Media Type<span class="text-danger">*</span></label>
        <select id="new_mediatypeid" name="new_mediatypeid" class="form-control" data-parsley-required data-parsley-error-message="Media Type is required">
            <cfoutput query="type">
                <option value="#type.mediatypeid#">#type.mediatype#</option>
            </cfoutput>
        </select>
    </div>

    <div class="form-group col-md-12">
        <label for="attachmenturl">Upload File <span class="text-danger">*</span></label>
        <p>
            <input name="file" onchange="unlock();" type="file" />
        </p>
    </div>

    <div class="form-group text-center col-md-12">
        <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit" style="background-color: #406e8e; border: #406e8e;" id="buttonSubmit" disabled>Upload</button>
    </div>

    <div class="form-group col-md-12">
        <label for="attachname">Name (Optional)</label>
        <input class="form-control" type="text" id="new_medianame" name="new_medianame" data-parsley-maxlength="800" data-parsley-maxlength-message="Max length 800 characters" placeholder="Add a name/brief description" />
    </div>

</form>

<script>
    $(document).ready(function() {
        $(".parsley-examples").parsley();
    });
</script>

