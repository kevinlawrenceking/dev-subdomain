<!--- This ColdFusion page allows users to update project information including category, subcategory, project name, description, union, network, tone, and contract type. --->
<cfinclude template="/include/qry/audunions_sel.cfm" />
<cfinclude template="/include/qry/audnetworks_sel.cfm" />
<cfinclude template="/include/qry/auditionrojectDetails.cfm" />

<p>Enter the information below and press the update button to continue.</p>

<form action="/include/remote_aud_project_update2.cfm" method="post" class="needs-validation" novalidate>

    <input type="hidden" name="audprojectid" value="#audprojectid#" />

    <div class="row" />

    <!--- Category Selection --->
    <div class="form-group col-md-6 col-sm-12">
        <label for="audcatid">Category<span class="text-danger">*</span></label>
        <select id="audcatid" class="form-control" name="new_audcatid" data-parsley-required data-parsley-error-message="Category is required">
            <option value="">--</option>
            <cfoutput query="audcategories_sel">
                <option value="#audcategories_sel.id#">#audcategories_sel.name#</option>
            </cfoutput>
        </select>
    </div>

    <!--- Subcategory Selection --->
    <div class="form-group col-md-6 col-sm-12">
        <label for="audtypeid">Subcategory<span class="text-danger">*</span></label>
        <select id="new_audsubcatid" name="new_audsubcatid" class="form-control" data-parsley-required data-parsley-error-message="Subcategory is required">
            <option value="">--</option>
            <cfoutput query="audsubcategories_sel">
                <cfif #auditionrojectDetails.audsubcatid# is "#audsubcategories_sel.id#">
                    <option value="#audsubcategories_sel.id#" Selected data-chained="#audsubcategories_sel.audcatid#">#audsubcategories_sel.name#</option>
                <cfelse>
                    <option value="#audsubcategories_sel.id#" data-chained="#audsubcategories_sel.audcatid#">#audsubcategories_sel.name#</option>
                </cfif>
            </cfoutput>
        </select>
    </div>

    <!--- Project Name Input --->
    <div class="form-group col-md-12">
        <label for="projName">Project Name (Title)</label>
        <input class="form-control" type="text" id="projName" name="new_projName" value="#projName#" placeholder="Project Name (Title)" />
        <div class="invalid-feedback">
            Please enter a Project Name (Title).
        </div>
    </div>

    <!--- Project Description Input --->
    <div class="form-group col-md-12">
        <label for="projDescription">Project Description / Title</label>
        <textarea class="form-control" type="text" id="projDescription" name="new_projDescription" placeholder="Project Description / Title" rows="1">#projdescription#</textarea>
        <div class="invalid-feedback">
            Please enter a Project Description / Title.
        </div>
    </div>

    <!--- Union Selection --->
    <div class="form-group col-md-6">
        <label for="unionID">Union</label>
        <select class="form-control" name="new_unionID" id="unionID">
            <option value="">--</option>
            <cfoutput query="audunions_sel">
                <cfif #auditionrojectDetails.unionID# is "#audunions_sel.id#">
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

    <!--- Network Selection --->
    <div class="form-group col-md-6">
        <label for="networkID">Network/Studio/Platform</label>
        <select class="form-control" name="new_networkID" id="networkID">
            <option value="">--</option>
            <cfoutput query="audnetworks_sel">
                <cfif #auditionrojectDetails.networkID# is "#audnetworks_sel.id#">
                    <option value="#audnetworks_sel.id#" Selected data-chained="#audnetworks_sel.audcatid#">#audnetworks_sel.name#</option>
                <cfelse>
                    <option value="#audnetworks_sel.id#" data-chained="#audnetworks_sel.audcatid#">#audnetworks_sel.name#</option>
                </cfif>
            </cfoutput>
        </select>
        <div class="invalid-feedback">
            Please select a Network/Studio/Platform.
        </div>
    </div>

    <!--- Tone Selection --->
    <div class="form-group col-md-6">
        <label for="toneID">Tone</label>
        <select class="form-control" name="new_toneID" id="toneID">
        </select>
        <div class="invalid-feedback">
            Please select a Tone.
        </div>
    </div>

    <!--- Contract Type Selection --->
    <div class="form-group col-md-6">
        <label for="contractTypeID">Contract Type</label>
        <select class="form-control" name="new_contractTypeID" id="contractTypeID">
        </select>
        <div class="invalid-feedback">
            Please select a Contract Type.
        </div>
    </div>

    <!--- Delete Option --->
    <div class="custom-group custom-checkbox">
        <div style="margin-left:25px;">
            <label class="custom-control-label">
                <input type="checkbox" class="custom-control-input" id="deleteitem" value="1" name="new_isDeleted" />
                <span class="custom-control-label" for="deleteitem">Delete</span>
            </label>
        </div>
    </div>

    <!--- Submit Button --->
    <div class="form-group text-center col-md-12">
        <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: #406e8e; border: #406e8e;" type="submit">Update</button>
    </div>

    </div>
</form>
