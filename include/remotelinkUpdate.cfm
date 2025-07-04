<!--- This ColdFusion page handles the update of remote link details, including custom and non-custom links. --->

<cfset siteLinksService = createObject("component", "services.SiteLinksService")>
<cfset linkDetails = siteLinksService.getLinkDetailsById(linkid=new_id)> 
<cfparam name="target" default="myaccount" />

<form action="/include/remotelinkUpdateUpdate.cfm" method="post" class="parsley-examples" 
      data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" 
      data-parsley-trigger="keyup" data-parsley-validate id="actinglinks_update">
    
    <!--- Hidden Inputs --->
    <cfoutput>
        <input type="hidden" name="new_id" value="#linkDetails.id#" />
        <input type="hidden" name="target_id" value="#linkDetails.sitetypeid#" />
        <input type="hidden" name="new_iscustom" value="#linkDetails.iscustom#" />
        <input type="hidden" name="userid" value="#userid#" />
        <input type="hidden" name="target" value="#target#" />
    
<cfif linkDetails.iscustom is "0">
          <input type="hidden" name="new_siteName" value="#linkDetails.sitename#" />
          </cfif>
    </cfoutput>

    <div class="row">
        
        <!--- Custom or Non-Custom Link Details --->
        <cfif linkDetails.iscustom is "0">
            <!--- Non-Custom: Static site name and icon --->
            <div class="form-group col-md-6">
                <h5>
                    <cfoutput>
                        <img src="#application.retinaIcons14Url#/#linkDetails.siteicon#" width="14px" alt="#linkDetails.sitename#" /> 
                        #linkDetails.sitename#
                    </cfoutput>
                </h5>
            </div>
        <cfelse>
            <!--- Custom: Editable site name --->
            <div class="form-group col-md-12">
                <label for="new_siteName">Site Name<span class="text-danger">*</span></label>
                <cfoutput>
                    <input class="form-control" type="text" id="new_siteName" name="new_siteName" 
                           value="#linkDetails.sitename#" placeholder="Enter Site Name"
                           data-parsley-minlength="3" data-parsley-minlength-message="Min length 3 characters"
                           data-parsley-maxlength="200" data-parsley-maxlength-message="Max length 200 characters"
                           data-parsley-required data-parsley-error-message="Site Name is required">
                </cfoutput>
            </div>
        </cfif>

        <!--- URL Input Field --->
        <div class="form-group col-md-12">
            <label for="new_siteurl">URL<span class="text-danger">*</span></label>
            <cfoutput>
                <input class="form-control" type="text" id="new_siteurl" name="new_siteurl" 
                       value="#linkDetails.siteurl#" placeholder="Enter your URL"
                       data-parsley-minlength="5" data-parsley-minlength-message="Min length 5 characters"
                       data-parsley-maxlength="200" data-parsley-maxlength-message="Max length 200 characters">
            </cfoutput>
        </div>

        <!--- Submit Button --->
        <div class="form-group text-center col-md-12">
            <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" 
                    type="submit" style="background-color: #406e8e; border-color: #406e8e;">
                Update
            </button>
        </div>

    </div>
</form>

<!--- Initialize Parsley Validation --->
<script>
    $(document).ready(function() {
        $(".parsley-examples").parsley();
    });
</script>
