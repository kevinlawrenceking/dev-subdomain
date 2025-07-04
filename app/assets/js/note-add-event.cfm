<cfparam name="reventid" default="0" />
<cfset eventid = reventid />

<cfquery result="result"  name="relationships">
    select * from contactdetails d where recordname <> '' and userid = #userid# order by d.contactfullname
</cfquery>

<div class="row">

<div class="col-xl-6 col-lg-8 col-md-12">
        <div class="card mb-3">

<div class="card-body">
                
               <cfoutput><h4>#details.fullName#</h4></cfoutput> 

<cfform method="post" action="/include/note-add-event2.cfm" class="parsley-examples" name="event-form" id="form-event" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate>
                    
                    <cfoutput>
                        
                        <input type="hidden" name="returnurl" value="#returnurl#" />
                        <input type="hidden" name="rcontactid" value="#contactid#" />
                        <input type="hidden" name="reventid" value="#reventid#" />
                        
                        <input type="hidden" name="userid" value="#userid#" />

</cfoutput>

<div class="row">

<Cfif #isdefined('seleeectzi')#>
                        <script>
                            $(document).ready(function() {
                                $("#select-relationship").selectize({

                                    persist: !1,
                                    createOnBlur: !0,
                                    create: !0,

plugins: ["remove-button"],
                                    delimiter: ",",
                                    persist: false,
                                    create: function(input) {
                                        return {
                                            value: input,
                                            text: input,
                                        };
                                    },

});

                            });
                        </script>
</Cfif>

<div class="form-group col-md-12">
             
                 <div id="snow-editor" style="height: 300px;">

       </div>

<cfif #isdefined('adssfds')#>

                        <div class="form-group col-md-12">
                            <label for="eventDescription">Note Details<span class="text-danger">*</span></label>
                            <textarea class="form-control" type="text" id="noteDetails" name="noteDetails" placeholder="Write a note..." rows="8" required data-parsley-required data-parsley-error-message="Details are required"></textarea>

                        </div>

</cfif>

                        <div class="form-group col-md-6">
                            <label for="eventTypeName">Who can see your note?<span class="text-danger">*</span></label>
                            <select class="form-control" name="isPublic" id="isPublic" data-parsley-required data-parsley-error-message="Note type is required">
                                <option value="1" selected>Team</option>
                                <option value="0">Only me</option>
                            </select>

</div><Cfoutput>
 <input type="hidden" name="eventid"     value="#reventid#" />           
                </Cfoutput>

</div>

<div class="row mt-2">
                        <div class="col-6">

                        </div>
                        <div class="col-6 text-right">

<textarea name="text" name="noteDetails" style="display:none" id="noteDetails"></textarea>
  <input type="submit" value="Save" />

<a href="javascript:history.go(-1)"><button type="button" class="btn btn-light mr-1" data-dismiss="modal">Back</button></a>
                            <button type="submit" class="btn btn-success" id="btn-save-event">Add</button>
                        </div>
                    </div>
                </cfform>
            </div>
        </div>

    </div>

</div>

<script>
    $(document).ready(function() {
        $(".parsley-examples").parsley()
    });
</script>

<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), " \")#" />
 
