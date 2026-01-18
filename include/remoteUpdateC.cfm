<!--- This ColdFusion page handles the display and submission of a form for updating item details based on various categories. --->

<cfinclude template="/include/qry/fetchLocationService.cfm" />
<cfinclude template="/include/qry/details_261_1.cfm" />

<cfparam name="new_countryid" default="" />
<cfparam name="new_region_id" default="" />
<cfparam name="MINLENGTH " default="1" />
<cfinclude template="/include/qry/findcountry_261_2.cfm" />

<!--- Check if a country is found and set the new_countryid accordingly --->
<cfif findcountry.recordcount is 1>
    <cfset new_countryid = findcountry.countryid />
</cfif>

<cfinclude template="/include/qry/findregion_261_3.cfm" />

<!--- Check if a region is found and set the new_region_id accordingly --->
<cfif findregion.recordcount is 1>
    <cfset new_region_id = findregion.region_id />
</cfif>

<cfset new_catid = details.catid />

<!--- Include different query templates based on the category id --->

<cfinclude template="/include/qry/types.cfm" />
<cfoutput>
    <cfset formid = "remoteupdate#itemid#" />
</cfoutput>

<form action="/include/remoteUpdateCUpdate.cfm" method="post" class="parsley-examples" id="<cfoutput>#formid#</cfoutput>" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate>
    <cfoutput>
        <input type="hidden" name="catid" value="#new_catid#" />
        <input type="hidden" name="itemid" value="#details.itemid#" />
        <input type="hidden" name="contactid" value="#details.contactid#" />
        <input type="hidden" name="userid" value="#userid#" />
    </cfoutput>

    <div class="row">
        <!--- Check if there is only one type and set the valuetype accordingly --->
<cfif typesResult.types.recordcount eq 1>
    <cfoutput><input type="hidden" name="valuetype" value="#typesResult.types.valuetype#" /></cfoutput>
<cfelse>
    <div class="form-group col-md-6">
        <label for="valueType">Type <span class="text-danger">*</span></label>
    <select id="valueType" name="valueType" class="form-control" data-parsley-required="true" 
            data-parsley-error-message="Type is required" onchange="showDiv('hidden_div', this); handleCustomTypeValidation(this);">
             <option value="Custom" >***ADD NEW***</option>
   
            <cfoutput query="typesResult.types">
            <Cfif #typesResult.types.valuetype# is not "Custom">
                <option value="#typesResult.types.valuetype#" <cfif typesResult.types.valuetype eq details.valueType>selected</cfif>>#typesResult.types.valuetype#</option>
           </cfif>
            </cfoutput>
        </select>
    </div>
    </div>
</cfif>

<div id="hidden_div" class="form-group col-md-6">
            <label for="customtype">Custom Type</label>
            <input class="form-control" type="text" id="customtype" name="customtype" placeholder="Add a custom type"   data-parsley-required="false" />
        </div>

        <cfset valuefieldtype = "text">
        
        <!--- Determine the field type based on the category id --->
        <cfif new_catid is "10">
            <cfset valuefieldtype = "email">
        </cfif>
        <cfif new_catid is "13">
            <cfset valuefieldtype = "date">
        </cfif>

        <!--- Check if the category id is not one of the specified values and render the input field accordingly --->
        <cfif new_catid neq "9" and new_catid neq "2" and new_catid neq "13" and new_catid neq "1">
            <cfoutput>
                <cfset minlength = "3">
                <cfif new_catid is "4">
                    <cfset minlength = "3">
                </cfif>
                <cfif new_catid is "5">
                    <cfset minlength = "8">
                </cfif>

      <div class="form-group col-md-12">
    <label for="valuefieldtype">#details.recordname#<span class="text-danger">*</span></label>
    <input 
        class="form-control" 
        type="<cfif details.catid eq '4' or details.catid eq '5'>url<cfelse>#valuefieldtype#</cfif>" 
        id="valuetext" 
        name="valuetext" 
        value="#details.valuetext#" 
        data-parsley-maxlength="800" 
        data-parsley-required="true" 
        data-parsley-minlength="#minlength#"
        data-parsley-minlength-message="Min length #minlength# characters"
        data-parsley-maxlength-message="Max length 800 characters" 
        data-parsley-error-message="Valid #details.recordname# is required"
        placeholder="Enter #details.recordname#"
        <cfif details.catid eq "4" or details.catid eq "5">
            data-parsley-type="url"
            data-parsley-pattern="^(?!.*@).*$"
            data-parsley-pattern-message="Please enter a valid URL"
            data-parsley-type-message="Please enter a valid URL starting with http or https"
        </cfif>>

</div>

            </cfoutput>
        </cfif>

        <!--- Handle specific category id for additional input fields --->
        <cfif new_catid is "1">
            <cfoutput>
                <div class="form-group col-md-12">
                    <label for="valuetext">#details.recordname#<span class="text-danger">*</span></label>
                    <input class="form-control" type="text" id="valuetext" name="valuetext" value="#details.valuetext#" data-parsley-minlength="#minlength#"  data-parsley-phone data-parsley-required="true" data-parsley-minlength-message="Min length #minlength# characters" data-parsley-maxlength="800" data-parsley-maxlength-message="Max length 800 characters" data-parsley-required data-parsley-error-message="Valid #details.recordname# is required" placeholder="Enter #details.recordname#" />
                </div>
            </cfoutput>
        </cfif>

        <cfif new_catid is "2">
            <cfoutput>
                <div class="form-group col-md-12">
                    <label for="valueStreetAddress">Address<span class="text-danger">*</span></label>
                    <input class="form-control" type="text" id="valueStreetAddress" value="#details.valueStreetAddress#" name="valueStreetAddress" data-parsley-minlength="2" data-parsley-minlength-message="Min length 3 characters" data-parsley-maxlength="100" data-parsley-maxlength-message="Max length 100 characters" data-parsley-required data-parsley-error-message="Street is required" placeholder="Enter Street" />
                </div>

                <div class="form-group col-md-12">
                    <label for="valueExtendedAddress">Extended Address</label>
                    <input class="form-control" type="text" id="valueExtendedAddress" value="#details.valueExtendedAddress#" name="valueExtendedAddress" placeholder="Enter Street" />
                </div>

                <div class="form-group col-md-6">
                    <label for="valuetvalueCityext">Town/City</label>
                    <input class="form-control" type="text" id="valueCity" value="#details.valueCity#" name="valueCity" placeholder="Enter City" />
                </div>

                <div class="form-group col-md-6">
                    <label for="valuePostalCode">Postal Code</label>
                    <input class="form-control" type="text" id="valuePostalCode" value="#details.valuePostalCode#" name="valuePostalCode" placeholder="Enter Postal Code" />
                </div>
            </cfoutput>

            <div class="form-group col-md-6">
                <label for="countryid">Country<span class="text-danger">*</span></label>
                <select id="countryid" class="form-control" name="countryid" data-parsley-required data-parsley-error-message="Country is required">
                    <option value="">--</option>
                    <cfoutput query="countries">
                        <option value="#countries.countryid#" <cfif countries.countryid eq new_countryid>selected</cfif>>#countries.countryname#</option>
                    </cfoutput>
                </select>
            </div>

            <div class="form-group col-md-6">
                <label for="region_id">State/Region<span class="text-danger">*</span></label>
                <select id="region_id" name="region_id" class="form-control" style="position: relative; z-index: 1050;">
                    <option value="">--</option>
                    <cfoutput query="regions">
                        <option value="#regions.region_id#" data-chained="#regions.countryid#" <cfif regions.region_id eq new_region_id>selected</cfif>>#regions.regionname#</option>
                    </cfoutput>
                </select>
            </div>
        </cfif>

        <cfif new_catid is "13">
            <cfoutput>
                <div class="form-group col-md-12">
                    <label for="itemDate">Important Date<span class="text-danger">*</span></label>
                    <input class="form-control" id="itemDate" data-parsley-required data-parsley-error-message="Date is required" type="date" value="#details.itemdate#" name="itemDate" />
                </div>
            </cfoutput>
        </cfif>

        <cfif new_catid is "9">
            <cfinclude template="/include/qry/companies_198_4.cfm" />

            <cfoutput>
                <div class="form-group col-md-12">
                    <label for="valueCompany">#details.recordname# Name<span class="text-danger">*</span></label>
                    <select id="valueCompany" name="valueCompany" class="form-control" data-parsley-required data-parsley-error-message="Name is required." onchange="toggleCustomField(this)">
                        <option value=""></option>

                        </cfoutput>
                        <option value="custom">***ADD NEW***</option>
                        <cfloop query="companies">
                        <cfoutput>
                            <option value="#companies.new_valuecompany#" <cfif companies.new_valuecompany eq details.valueCompany>selected</cfif>>#companies.new_valuecompany#</option>
                        </cfoutput>
                        </cfloop>
                    </select>
                </div>
                <Cfoutput>
                <div class="form-group col-md-12" id="special" style="display: none;">
                    <label for="custom">Custom Name</label>
                    <input class="form-control" type="text" id="custom" name="custom" value="" placeholder="Enter Custom #details.recordname#"   data-parsley-required="false" />
                </div>

                <div class="form-group col-md-12">
                    <label for="valuetext">Department</label>
                    <input class="form-control" type="text" id="valueDepartment" name="valueDepartment" value="#details.valueDepartment#" placeholder="Enter Department" />
                </div>

                <div class="form-group col-md-12">
                    <label for="valuetext">Title</label>
                    <input class="form-control" type="text" id="valuetitle" name="valuetitle" value="#details.valueTitle#" placeholder="Enter Title" />
                </div>
            </cfoutput>
        </cfif>

        <div class="custom-group custom-checkbox">
            <div style="margin-left:25px;">
                <label class="custom-control-label">
                    <input type="checkbox" class="custom-control-input" id="deleteitem" value="1" name="deleteitem" />
                    <span class="custom-control-label" for="deleteitem">Delete</span>
                </label>
            </div>
        </div>

        <div class="form-group text-center col-md-12">
            <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit" style="background-color: #406e8e; border: #406e8e;">Update</button>
        </div>
    </div>
</form>

    <cfif new_catid is "2">
<script src="/app/assets/js/jquery.chained.js?ver=13.4"></script>
<script>
    $("#region_id").chained("#countryid");
</script>

</cfif>


<script>
    function toggleCustomField(select) {
        var isCustomSelected = select.value === 'custom';  
        var customFieldDiv = document.getElementById('special'); 
        var customFieldInput = document.getElementById('custom');  

        // Show or hide the custom field
        customFieldDiv.style.display = isCustomSelected ? 'block' : 'none';

if (isCustomSelected) {
            customFieldInput.setAttribute('data-parsley-required', 'true');
        } else {
            customFieldInput.removeAttribute('data-parsley-required');
        }

if (window.Parsley) {
            customFieldInput
                .closest('form')  
                .parsley()
                .validate();  
        }
    }

    // Initialize on page load
    window.onload = function () {
        toggleCustomField(document.getElementById('valueCompany'));
    };
</script>

<script>
    // Function to make 'customtype' required if 'Custom' is selected
    function handleCustomTypeValidation(select) {
        var isCustomSelected = select.value === "Custom"; // Check if "Custom" is selected
        var customFieldInput = document.getElementById("customtype"); // The custom type input field

        // Dynamically add or remove the 'required' attribute
        if (isCustomSelected) {
            customFieldInput.setAttribute("data-parsley-required", "true");
            customFieldInput.setAttribute("data-parsley-error-message", "Custom Type is required");
        } else {
            customFieldInput.removeAttribute("data-parsley-required");
            customFieldInput.removeAttribute("data-parsley-error-message");

            // Clear validation state when hiding the field
            if (window.Parsley) {
                $(customFieldInput).parsley().reset();
            }
        }

        // Show or hide the input field
        document.getElementById("hidden_div").style.display = isCustomSelected ? "block" : "none";
    }

    // Attach event listener to the dropdown
    document.addEventListener("DOMContentLoaded", function () {
        var valueTypeDropdown = document.getElementById("valueType");
        if (valueTypeDropdown) {
            valueTypeDropdown.addEventListener("change", function () {
                handleCustomTypeValidation(this);
            });
        }
    });
</script>

<script>
    function showDiv(divId, element) {
        document.getElementById(divId).style.display = element.value == "Custom" ? 'block' : 'none';
    }
</script>

