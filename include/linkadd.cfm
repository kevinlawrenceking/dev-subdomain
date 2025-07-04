<!--- This ColdFusion page handles the submission of a link associated with a contact and an event. --->

<cfparam name="placeholder" default="" />
<cfparam name="contactid" default="0" />

<!--- Include notes query template --->
<cfinclude template="/include/qry/notes_21_1.cfm" /> 

<cfset new_eventid = notes.eventid />

<!--- Form for adding a link --->
<form action="/include/linkadd2.cfm" method="post" class="parsley-examples" id="linkadd" 
      data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden"
      data-parsley-trigger="keyup" data-parsley-validate>
    
    <cfoutput>
        <input type="hidden" name="rcontactid" value="#contactid#" />
        <input type="hidden" name="reventid" value="#new_eventid#" />
        <input type="hidden" name="contactid" value="#contactid#" />
        <input type="hidden" name="eventid" value="#new_eventid#" />
        <input type="hidden" name="returnurl" value="#returnurl#" />
        <input type="hidden" name="noteid" value="#noteid#" />

        <!--- Check if audprojectid is defined and include it as a hidden input --->
        <cfif isdefined('audprojectid')>
            <input type="hidden" name="audprojectid" value="#audprojectid#" />
        </cfif>
    </cfoutput>

    <div class="row" />

    <cfset placeholder="https://" />
    <cfset minlength="3" />

    <!--- Form group for link name --->
    <div class="form-group col-md-12">
        <label for="linkname">Name <span class="text-danger">*</span></label>
        <input class="form-control" type="text" id="linkname" name="linkname" 
               data-parsley-maxlength="800" 
               data-parsley-maxlength-message="Max length 800 characters"  
               data-parsley-required="true" 
               placeholder="Enter Name or Title">
    </div>

    <!--- Form group for link URL --->
    <div class="form-group col-md-12">
        <label for="linkurl">URL <span class="text-danger">*</span></label>
        <input class="form-control" type="text" id="linkurl" name="linkurl" 
               data-parsley-maxlength="800" 
               data-parsley-maxlength-message="Max length 800 characters" 
               data-parsley-required="true" 
               placeholder="Enter URL">
    </div>

    <!--- Submit button for the form --->
    <div class="form-group text-center col-md-12">
        <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" 
                type="submit" 
                style="background-color: #406e8e; border: #406e8e;">Add</button>
    </div>

</form>

<!--- Initialize Parsley validation on document ready --->
<script>      
    $(document).ready(function() {
        $(".parsley-examples").parsley()
    });
</script>

