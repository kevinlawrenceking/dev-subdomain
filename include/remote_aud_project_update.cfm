<!--- This ColdFusion page handles the audition project update form, including various selections and inputs related to the project details. --->

<cfset dbug="N" />

<!--- Include necessary query templates for project details and selections --->
<cfinclude template="/include/qry/auditionprojectDetails.cfm" />
<cfinclude template="/include/qry/audcategories_sel.cfm" />
<cfinclude template="/include/qry/audsubcategories_sel.cfm" />
<cfinclude template="/include/qry/audunions_sel.cfm" />
<cfinclude template="/include/qry/audnetworks_user_sel.cfm" />
<cfinclude template="/include/qry/audtones_user_sel.cfm" />
<cfinclude template="/include/qry/audcontracttypes_sel.cfm" />
<cfinclude template="/include/qry/castingdirectors_sel.cfm" />

<cfset dbug="N" />
<script src="/app/assets/js/jquery.chained.js"></script>

<!--- Form for updating audition project details --->
<form action="/include/remote_aud_project_update2.cfm" method="post" class="parsley-examples" name="event-form" id="form-event" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate>
    <cfoutput>
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
        <input type="hidden" name="new_userid" value="#userid#" />
        <input type="hidden" name="new_audprojectid" value="#audprojectid#" />
        <input type="hidden" name="secid" value="#secid#" />
        <input type="hidden" name="old_toneid" value="#auditionprojectdetails.toneid#" /> 
        <input type="hidden" name="audsubcatid" value="#auditionprojectDetails.audsubcatid#" />
        <input type="hidden" name="old_networkid" value="#auditionprojectDetails.networkID#" />
        <input type="hidden" name="audcatid" value="#auditionprojectDetails.audcatid#" />
        <input type="hidden" name="userid" value="#userid#" />
    </cfoutput>

    <div class="row">
        <div class="form-group col-md-12">
        <cfoutput>
            <h4>Category: #auditionprojectDetails.audCatName# - #auditionprojectDetails.audSubCatName#</h4>
        </cfoutput>
        </div>

        <cfoutput query="auditionprojectdetails">
            <div class="form-group col-md-12">
                <label for="projName">Project Name (Title)<span class="text-danger">*</span></label>
                <input class="form-control" type="text" id="projName" name="new_projName" value="#auditionprojectdetails.projName#" placeholder="Project Name (Title)" required data-parsley-required data-parsley-error-message="Project Name is required" />
                <div class="invalid-feedback">
                    Please enter a Project Name (Title).
                </div>
            </div>

            <div class="form-group col-md-12">
                <label for="projDescription">Project Description / Logline</label>
                <textarea class="form-control" type="text" style="min-height:160px;" id="projDescription" name="new_projDescription" rows="4" placeholder="Project Description  ">#auditionprojectdetails.projdescription#</textarea>
                <div class="invalid-feedback">
                    Please enter a Project Description or logline.
                </div>
            </div>

            <input type="hidden" name="old_contactid" value="#auditionprojectDetails.contactid#" />
        </cfoutput>

        <div class="form-group col-sm-12">
            <label for="new_contactid">Casting Director </label>
            <select id="new_contactid" class="form-control" name="new_contactid">
                <option value="0">--</option>
                <cfoutput query="castingdirectors_sel">
                    <option value="#castingdirectors_sel.id#" <cfif #castingdirectors_sel.id# is "#auditionprojectDetails.contactid#"> Selected </cfif> >#castingdirectors_sel.name#</option>
                </cfoutput>
            </select>
        </div>

     <cfif #audnetworks_user_sel.recordcount# is "0">
    <cfoutput>
        <input type="hidden" name="new_networkID" value="#auditionprojectdetails.networkid#" />
    </cfoutput>
<cfelse>
    <div class="form-group col-md-6">
        <label for="new_networkID">Network/Studio/Platform</label>
        <select class="form-control" name="new_networkID" id="new_networkID" onchange="toggleCustomNetwork(this);">
            <option value="">--</option>
            <option value="CustomNetwork">***ADD CUSTOM</option>
            <cfoutput query="audnetworks_user_sel">
                <cfif #auditionprojectDetails.networkID# is "#audnetworks_user_sel.id#">
                    <option value="#audnetworks_user_sel.id#" Selected data-chained="#audnetworks_user_sel.audcatid#">#audnetworks_user_sel.name#</option>
                <cfelse>
                    <option value="#audnetworks_user_sel.id#" data-chained="#audnetworks_user_sel.audcatid#">#audnetworks_user_sel.name#</option>
                </cfif>
            </cfoutput>
        </select>
        <div class="invalid-feedback">
            Please select a Network/Studio/Platform.
        </div>
    </div>

    <cfoutput>
        <div class="form-group col-md-6" id="CustomNetworks" style="display:none;">
            <label for="CustomTone">Custom Network/Studio/Platform</label>
            <input class="form-control" type="text" id="CustomNetwork" name="CustomNetwork" value="" placeholder="Enter a Custom Network/Studio/Platform" />
        </div>
    </cfoutput>
</cfif>

<script>
    function toggleCustomNetwork(select) {
        var customDiv = document.getElementById('CustomNetworks');
        var customInput = document.getElementById('CustomNetwork');

        if (select.value === 'CustomNetwork') {
            customDiv.style.display = 'block';
            customInput.required = true;
        } else {
            customDiv.style.display = 'none';
            customInput.required = false;
        }
    }
</script>


        <!--- Check if there are any tones available --->
        <cfif #audtones_user_sel.recordcount# is "0">
            <cfoutput> <input type="hidden" name="new_toneID" value="#auditionprojectdetails.toneid#" /></cfoutput>
        <cfelse>
            <div class="form-group col-md-6">
                <label for="new_toneID">Style / Format</label>
                <select class="form-control" name="new_toneID" id="new_toneID" onchange="if (this.value=='Custom'){this.form['Custom'].style.display='block',this.form['Custom'].required=true} else {this.form['Custom'].style.display='none',this.form['Custom'].required=false};">
                    <option value="">--</option>
                    <option value="Custom">***ADD CUSTOM</option>
                    <cfoutput query="audtones_user_sel">
                        <cfif #auditionprojectDetails.toneID# is "#audtones_user_sel.id#">
                            <option value="#audtones_user_sel.id#" Selected>#audtones_user_sel.name#</option>
                        <cfelse>
                            <option value="#audtones_user_sel.id#">#audtones_user_sel.name#</option>
                        </cfif>
                    </cfoutput>
                </select>
                <div class="invalid-feedback">
                    Please select a Style / Format.
                </div>
            </div>

            <cfoutput>
                <div class="form-group col-md-6" id="Custom" style="display:none;">
                    <label for="new_custom">Custom Tone</label>
                    <input class="form-control" type="text" id="new_custom" name="Custom" value="" placeholder="Enter a Custom Tone" />
                </div>
            </cfoutput>
        </cfif>

        <!--- Check if there are any unions available --->
        <cfif #audunions_sel.recordcount# is "0">
            <cfoutput> <input type="hidden" name="new_unionID" value="#auditionprojectdetails.unionid#" /></cfoutput>
        <cfelse>
            <div class="form-group col-md-6">
                <label for="unionID">Union</label>
                <select class="form-control" name="new_unionID" id="new_unionID">
                    <option value="">--</option>
                    <cfoutput query="audunions_sel">
                        <cfif #auditionprojectDetails.unionID# is "#audunions_sel.id#">
                            <option value="#audunions_sel.id#" Selected data-chained="#audunions_sel.audcatid#">#audunions_sel.name#</option>
                        <cfelse>
                            <option value="#audunions_sel.id#" data-chained="#audunions_sel.audcatid#">#audunions_sel.name#</option>
                        </cfif>
                    </cfoutput>
                </select>
                <div class="invalid-feedback">
                    Please select a Union.
                </div>
            </div>
        </cfif>

        <!--- Check if there are any contract types available --->
        <cfif #audcontracttypes_sel.recordcount# is "0">
            <cfoutput> <input type="hidden" name="new_contracttypeid" value="#auditionprojectdetails.contracttypeid#" /></cfoutput>
        <cfelse>
            <div class="form-group col-md-6">
                <label for="new_contractTypeID">Contract Type</label>
                <select class="form-control" name="new_contractTypeID" id="new_contractTypeID">
                    <option value="">--</option>
                    <cfoutput query="audcontracttypes_sel">
                        <cfif #auditionprojectDetails.contracttypeID# is "#audcontracttypes_sel.id#">
                            <option value="#audcontracttypes_sel.id#" Selected data-chained="#audcontracttypes_sel.audcatid#">#audcontracttypes_sel.name#</option>
                        <cfelse>
                            <option value="#audcontracttypes_sel.id#" data-chained="#audcontracttypes_sel.audcatid#">#audcontracttypes_sel.name#</option>
                        </cfif>
                    </cfoutput>
                </select>
                <div class="invalid-feedback">
                    Please select a Contract Type.
                </div>
            </div>
        </cfif>
<!--- remove these two element below and add the elements exactly as is from bookupdatefornm.cfm --->
        <cfoutput query="auditionprojectdetails">
            <div class="form-group col-md-12">
                <label for="payrate">Payrate / Session Fee</label>
                <input class="form-control" type="text" id="payrate" name="new_payrate" value="#auditionprojectdetails.payrate#" placeholder="Enter payrate or session fee" />
                <div class="invalid-feedback">
                    Please enter a valid payrate or session fee.
                </div>
            </div>

            <div class="form-group col-md-12">
                <label for="buyout">Buyout</label>
                <input class="form-control" type="text" id="buyout" name="new_buyout" value="#auditionprojectdetails.buyout#" placeholder="Enter buyout terms or fee notes" />
                <div class="invalid-feedback">
                    Please enter valid buyout information.
                </div>
            </div>
        </cfoutput>

        <div class="form-group text-center col-md-12">
            <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: #406e8e; border: #406e8e;" type="submit">Update</button>
        </div>


    </div>


    <!--- remove above --->
</form>

<script src="/app/assets/js/libs/parsleyjs/parsley.min.js"></script>
