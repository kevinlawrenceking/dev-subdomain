<!--- This ColdFusion page handles the submission of audition site updates, including category selection and deletion options. --->

<cfinclude template="/include/qry/details_259_1.cfm" />
<cfset old_catlist = details.catlist />

<form method="post" action="/include/remoteupdateaudsubmitsite2.cfm" class="parsley-examples" name="version-form" id="form-version" 
      data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden"
      data-parsley-trigger="keyup" data-parsley-validate>
                  
    <!--- Hidden inputs for user ID and submission site ID --->
    <cfoutput>  
        <input type="hidden" name="userid" value="#userid#"  />
        <input type="hidden" name="submitsiteid" value="#submitsiteid#"  />
    </cfoutput>

    <div class="row">
        <!--- Input field for Submission Site name --->
        <cfoutput>  
            <div class="form-group col-md-12">
                <label class="control-label">Submission Site</label>
                <input class="form-control" required type="text" value="#details.submitsitename#" name="new_submitsitename" id="new_submitsitename" />  
            </div>
            <div class="invalid-feedback">
                Please enter a Submission Site.
            </div>
        </cfoutput>

        <!--- Include categories for selection --->
        <cfinclude template="/include/qry/getCategories_196_1.cfm" />

        <div class="form-group col-md-12">
            <label class="control-label">Valid Audition Categories:</label>
            <div class="custom-group custom-checkbox">
                <!--- Loop through categories and create checkboxes --->
                <cfloop query="getCategories">
                    <div class="form-check" style="margin-left:25px;">
                        <cfoutput>
                            <input class="form-check-input" type="checkbox" value="#audcatid#" id="catlist#audcatid#" name="catlist" 
                            <cfif listFind(old_catlist, audcatid)>checked</cfif>>
                            <label class="form-check-label" for="catlist#audcatid#">
                                #audcatname#
                            </label>
                        </cfoutput>
                    </div>
                </cfloop>
            </div>
        </div>

        <!--- Include logic to find existing submissions --->
        <cfinclude template="/include/qry/findsubs_259_3.cfm" />

        <!--- Check if there are any existing submissions --->
        <cfif findsubs.recordcount is "0">
            <cfset disable_tag = "" />
        <cfelse>
            <cfset disable_tag = "disabled" />
        </cfif>

        <div class="custom-group custom-checkbox">
            <div style="margin-left:25px;">    
                <cfoutput>   
                    <label class="custom-control-label">
                        <input type="checkbox" #disable_tag# class="custom-control-input" id="IsDeleted" value="1" name="IsDeleted" />
                        <span class="custom-control-label" style="color:#disable_tag#red;" for="deleteitem">Delete<cfif disable_tag is "disabled">*</cfif></span>
                    </label>
                </cfoutput>  
                <cfif disable_tag is "disabled">
                    <p style="margin-left:25px;"><i>*Submission sites in use cannot be deleted.</i></p>
                </cfif>
            </div>   
        </div>
    </div>

    <div class="row mt-2">
        <div class="col-6">
            <!--- Placeholder for additional content if needed --->
        </div>
        <div class="col-6 text-right">
            <button type="button" class="btn btn-light mr-1 btn-sm" data-bs-dismiss="modal">Cancel</button> 
            <button type="submit" class="btn btn-primary btn-sm waves-effect waves-light" id="btn-save-event">Update</button>
        </div>
    </div>
</form>

