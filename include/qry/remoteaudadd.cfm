<!--- This ColdFusion page handles the audition submission form, including category and subcategory selection. --->

<cfset dbug = "N" />

<cfparam name="isdirect" default="0" />

<script src="/app/assets/js/jquery.chained.js"></script>

<cfparam name="rcontactid" default="0" />

<!--- Include the query for audition categories --->
<cfinclude template="/include/qry/audcategories_sel.cfm">

<!--- Include the query for audition subcategories --->
<cfinclude template="/include/qry/audsubcategories_sel.cfm">

<!--- Form for audition submission --->
<form method="post" action="/app/audition-add/index.cfm" class="parsley-examples" name="event-form" id="form-event" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate>
    
    <cfoutput>
        <input type="hidden" name="new_audStepID" value="1" />     
        <input type="hidden" name="new_userid" value="#userid#" />   
        <input type="hidden" name="isdirect" value="#isdirect#" />   
    </cfoutput>
 
    <div class="row">     
        <div class="form-group col-md-6">
            <label for="audcatid">Category<span class="text-danger">*</span></label>
            <select id="audcatid" class="form-control" name="new_audcatid" data-parsley-required data-parsley-error-message="Category is required">
                <option value="">--</option>
                <cfoutput query="audcategories_sel">
                    <option value="#audcategories_sel.id#">#audcategories_sel.name#</option>
                </cfoutput>
            </select>
        </div>
      
        <div class="form-group col-md-6 col-sm-12">
            <label for="audtypeid">Subcategory<span class="text-danger">*</span></label>
            <select id="new_audsubcatid" name="new_audsubcatid" class="form-control" data-parsley-required data-parsley-error-message="Subcategory is required">
                <option value="">--</option>
                <cfoutput query="audsubcategories_sel">
                    <option value="#audsubcategories_sel.id#" data-chained="#audsubcategories_sel.audcatid#">#audsubcategories_sel.name#</option>
                </cfoutput>
            </select>
        </div>

        <div class="form-group text-center col-md-12">
            <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: #406e8e; border: #406e8e;" type="submit">Add</button>
        </div>
    </div> 
</form>

<script src="/app/assets/js/libs/parsleyjs/parsley.min.js"></script>

<script>
    $("#new_audsubcatid").chained("#audcatid");
</script>
