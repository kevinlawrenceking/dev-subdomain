<!--- This ColdFusion page allows users to update audition project details by selecting categories and subcategories. --->

<cfset dbug = "N" />

<cfinclude template="/include/qry/audcategories_sel.cfm" />
<cfinclude template="/include/qry/audsubcategories_sel.cfm" />
<cfinclude template="/include/qry/auditionprojectDetails_66_1.cfm" />

<cfset dbug = "N" />
<script src="/app/assets/js/jquery.chained.js"></script>

<p>Enter the information below and press the update button to continue.</p>

<form action="/include/catupdateform2.cfm" method="post" class="parsley-examples" name="event-form" id="form-event" 
      data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden"
      data-parsley-trigger="keyup" data-parsley-validate>
    
    <cfoutput> 
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
        <input type="hidden" name="new_userid" value="#userid#" />
        <input type="hidden" name="new_audprojectid" value="#audprojectid#" />
        <input type="hidden" name="secid" value="#secid#" />
    </cfoutput>

    <div class="row" />

    <!--- Category Selection --->
    <div class="form-group col-md-6 col-sm-12">
        <label for="audcatid">Category<span class="text-danger">*</span></label>
        <select id="audcatid" class="form-control" name="new_audcatid" data-parsley-required data-parsley-error-message="Category is required">
            <option value="">--</option>
            <cfoutput query="audcategories_sel">
                <cfif #auditionprojectDetails.audcatid# is "#audcategories_sel.id#">
                    <option value="#audcategories_sel.id#" Selected>#audcategories_sel.name#</option>
                <cfelse>
                    <option value="#audcategories_sel.id#">#audcategories_sel.name#</option>
                </cfif>
            </cfoutput>
        </select>
    </div>

    <!--- Subcategory Selection --->
    <div class="form-group col-md-6 col-sm-12">
        <label for="new_audsubcatid">Subcategory<span class="text-danger">*</span></label>
        <select id="new_audsubcatid" name="new_audsubcatid" class="form-control" data-parsley-required data-parsley-error-message="Subcategory is required">
            <option value="">--</option>
            <cfoutput query="audsubcategories_sel">
                <cfif #auditionprojectDetails.audsubcatid# is "#audsubcategories_sel.id#">
                    <option value="#audsubcategories_sel.id#" Selected data-chained="#audsubcategories_sel.audcatid#">#audsubcategories_sel.name#</option>
                <cfelse>
                    <option value="#audsubcategories_sel.id#" data-chained="#audsubcategories_sel.audcatid#">#audsubcategories_sel.name#</option>
                </cfif>
            </cfoutput>
        </select>
    </div>

    <!--- Submit Button --->
    <div class="form-group text-center col-md-12">
        <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: #406e8e; border: #406e8e;" type="submit">Update</button>
    </div>

</form>

<script src="/app/assets/js/libs/parsleyjs/parsley.min.js"></script>
<script>$("#new_audsubcatid").chained("#audcatid");</script>
