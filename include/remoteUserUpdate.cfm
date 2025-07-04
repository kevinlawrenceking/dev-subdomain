<cfinclude template="/include/qry/details_1693_1.cfm"/>

<cfinclude template="/include/qry/countries_457_1.cfm"/>

<cfinclude template="/include/qry/regions_518_1.cfm"/>



<script src="/app/assets/js/jquery.chained.js?ver=13.4.0.580339357529"></script>

<cfparam name="t1" default="0" />

<cfparam name="t2" default="0" />

<cfparam name="t3" default="0" />

<cfparam name="t4" default="0" />

<cfparam name="t5" default="0" />

<cfparam name="t6" default="0" />



 
 
 <form action="/include/remoteUserUpdated.cfm" method="post" class="parsley-examples" id="update" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate="data-parsley-validate">

        <cfoutput>
          <input type="hidden" name="t3" value="1"/>

          <div class="row">
            <div class="form-group col-md-6">
              <label for="userFirstName">First Name<span class="text-danger">*</span>
              </label>
            </label>

            <input class="form-control" type="text" id="new_userFirstName" name="new_userFirstName" value="#details.userFirstName#" data-parsley-required="data-parsley-required" data-parsley-error-message="First Name is required" placeholder="Enter your first name" /></div>

            <div class="form-group col-md-6">
              <label for="userLastName">Last Name<span class="text-danger">*</span>
              </label>
            </label>

            <input class="form-control" type="text" id="new_userLastName" name="new_userLastName" value="#details.userLastName#" data-parsley-required="data-parsley-required" data-parsley-error-message="Last Name is required" placeholder="Enter your last name" /></div>

          </div>

          <div class="row">

            <div class="form-group col-md-6">
              <label for="new_AvatarName">Avatar Name<span class="text-danger">*</span>
              </label>
            </label>

            <input class="form-control" type="text" id="new_AvatarName" name="new_AvatarName" value="#details.avatarname#" data-parsley-required="data-parsley-required" data-parsley-error-message="Avatar Name is required" placeholder="Enter your Avatar name" /></div>

            <div class="form-group col-md-6">
              <label for="useremail">Email<span class="text-danger">*</span>
              </label>

              <input class="form-control" name="new_useremail" value="#details.useremail#" data-parsley-type="email" id="email_address" data-parsley-required="data-parsley-required" data-parsley-trigger="focusout" data-parsley-checkemail="data-parsley-checkemail" data-parsley-checkemail-message="Email Address already Exists" placeholder="Enter your email" /></div>

            </div>

            <div class="row">
              <div class="form-group col-md-12">
                <label for="add1">Address<span class="text-danger">*</span>
                </label>
                <input class="form-control" type="text" id="add1" value="#details.add1#" name="add1" data-parsley-minlength="2" data-parsley-minlength-message="Min length 3 characters" data-parsley-maxlength="100" data-parsley-maxlength-message="Max length 100 characters" data-parsley-required="data-parsley-required" data-parsley-error-message="Street is required" placeholder="Enter Street" /></div>

              </div>

              <div class="row">
                <div class="form-group col-md-12">
                  <label for="add2">Extended Address</label>
                  <input class="form-control" type="text" id="add2" value="#details.add2#" name="add2" placeholder="Enter Street" /></div>

                </div>

                <div class="row">

                  <div class="form-group col-md-6">
                    <label for="city">Town/City</label>
                    <input class="form-control" type="text" id="city" value="#details.city#" name="city" placeholder="Enter City" /></div>

                    <div class="form-group col-md-6">
                      <label for="zip">Postal Code</label>
                      <input class="form-control" type="text" id="zip" value="#details.zip#" name="zip" placeholder="Enter Postal Code" /></div>

                    </div>

                  </cfoutput>

               <div class="row">
    <div class="form-group col-md-6">
        <label for="countryid">Country<span class="text-danger">*</span></label>
        <select id="countryid" class="form-control" name="countryid" data-parsley-required="data-parsley-required" data-parsley-error-message="Country is required">
            <option value="">--</option>
            <cfoutput query="countries">
                <option value="#countries.countryid#" 
                    <cfif countries.countryid EQ details.new_countryid>selected</cfif>>
                    #countries.countryname#
                </option>
            </cfoutput>
        </select>
    </div>

    <div class="form-group col-md-6">
        <label for="region_id">State/Region<span class="text-danger">*</span></label>
        <select id="region_id" name="region_id" class="form-control" style="position: relative; z-index: 1050;">
            <option value="">--</option>
            <cfoutput query="regions">
                <option value="#regions.region_id#" data-chained="#regions.countryid#" 
                    <cfif regions.region_id EQ details.new_region_id>selected</cfif>>
                    #regions.regionname#
                </option>
            </cfoutput>
        </select>
    </div>

    
                      <div class="form-group text-center col-md-12">

                        <button class=" btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit" style="background-color: ##406e8e; border: ##406e8e;">Update</button>

                      </div>

</div>

<!--- Initialize Parsley Validation --->
<script>
    $(document).ready(function() {
        $(".parsley-examples").parsley();
    });
</script>
<script>
    $("#region_id").chained("#countryid");
</script>

<!--- JavaScript to dynamically update the selected attribute --->
<script>
    document.getElementById('countryid').addEventListener('change', function() {
        updateSelectedAttribute(this);
    });

    document.getElementById('region_id').addEventListener('change', function() {
        updateSelectedAttribute(this);
    });

    function updateSelectedAttribute(selectElement) {

        Array.from(selectElement.options).forEach(option => option.removeAttribute('selected'));

        selectElement.options[selectElement.selectedIndex].setAttribute('selected', 'selected');
    }
</script>

            <script>
                  $(document).ready(function () {

                    $('#email_address').parsley();

                    window
                      .ParsleyValidator
                      .addValidator('checkemail', {
                        validateString: function (value) {
                          return $.ajax({
                            url: '/include/fetch.cfm?userID=<Cfoutput>#userid#</cfoutput>',
                            method: "POST",
                            data: {
                              email: value
                            },
                            dataType: "json",
                            success: function (data) {
                              return true;
                            }
                          });
                        }
                      });

                  });
                </script>