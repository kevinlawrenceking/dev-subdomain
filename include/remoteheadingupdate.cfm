<!--- This ColdFusion page handles the update of panel information including visibility and name. --->

<CFINCLUDE template="remote_load.cfm" /> 
<cfinclude template="/include/qry/updates_239_1.cfm" />

<form action="/include/remoteheadingupdate2.cfm" method="post" class="parsley-examples" 
      data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden"
      data-parsley-trigger="keyup" data-parsley-validate id="profile-form">

    <!--- Hidden inputs for form submission --->
    <cfoutput> 
        <input type="hidden" name="pnid" value="#updates.pnid#"  />
        <input type="hidden" name="new_sitetypeid" value="#new_sitetypeid#"  />
        <input type="hidden" name="userid" value="#userid#"  />
        <input type="hidden" name="pgrtn" value="P"  />
    </cfoutput>

    <div class="row">
        <div class="form-group col-md-12">

            <!--- Panel Name input field --->
            <cfoutput>
                <div class="form-group col-md-12">
                    <label for="new_pnTitle">Panel Name<span class="text-danger">*</span></label>
                    <input class="form-control" type="text" id="new_sitetypename" name="new_sitetypename"  
                           value="#updates.sitetypename#"
                           data-parsley-required="true"
                           placeholder="Update Panel Name">
                </div>

                <!--- Checkbox for visibility --->
                <div class="custom-group custom-checkbox">
                    <div style="margin-left:25px;">
                        <label class="custom-control-label">
                            <cfif #updates.isvisible# is "1">
                                <input type="checkbox" checked class="custom-control-input" id="isVisible" value="1" name="new_isVisible" data-parsley-multiple="isVisible" />
                            <cfelse>
                                <input type="checkbox" class="custom-control-input" id="isVisible" value="1" name="new_isVisible" data-parsley-multiple="isVisible" />   
                            </cfif>
                            <span class="custom-control-label" for="isVisible">Show on Dashboard</span>
                        </label>
                    </div>
                </div>
            </cfoutput>

            <!--- Submit button --->
            <div class="form-group text-center col-md-12">
                <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit" 
                        style="background-color: #406e8e; border: #406e8e;">Update</button>
            </div>
        </div>
    </div>
</form>

<!--- Initialize Parsley validation --->
<script>      
    $(document).ready(function() {
        $(".parsley-examples").parsley();
    });
</script> 

<!--- Custom validator for site type name --->
<script>
    $(document).ready(function(){
        $('#new_sitetypename').parsley();

        window.Parsley.addValidator('checksitetypename', {
            validateString: function(value) {
                return $.ajax({
                    url:'/include/fetch_sitetypename.cfm?userID=<cfoutput>#userID#</cfoutput>',
                    method:"POST",
                    data:{sitetypename:value},
                    dataType:"json",
                    success:function(data) {
                        return true;
                    }
                });
            }
        });
    });
</script>
