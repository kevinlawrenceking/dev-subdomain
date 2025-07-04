<!--- This ColdFusion page handles the audition submission form, including various fields and dynamic visibility of elements based on user input. --->

<cfparam name="rcontactid" default="0"/>
<!--- Set default value for rcontactid --->
<cfparam name="isdirect" default="0"/>
<!--- Set default value for isdirect --->
<cfparam name="userCalStarttime" default=""/>
<cfparam name="new_region_id" default="CA">
<cfparam name="new_countryid" default="US">
<cfparam name="valueCountry" default="">
<cfparam name="valuestate" default="">
<cfparam name="valuetext" default="">

<cfset dbug="N"/>

<!--- Initialize debug variable --->

<cfinclude template="/include/qry/fetchLocationService.cfm"/>
<!--- Include location service --->
<cfinclude template="/include/qry/audplatforms_user_sel.cfm"/>
<!--- Include user selected audition platforms --->

<cfinclude template="/include/qry/cities_448_1.cfm"/>
<!--- Include cities query --->
<cfinclude template="/include/qry/cat_27_1.cfm"/>

<cfset new_audcatid=cat.audcatid/>
<!--- Set new_audcatid from query result --->

<cfinclude template="/include/qry/audroletypes_sel_27_2.cfm"/>
<cfinclude template="/include/qry/audtypes_sel_27_3.cfm"/>
<cfinclude template="/include/qry/casting_types_27_4.cfm"/>
<cfinclude template="/include/qry/castingdirectors_sel.cfm">
<!--- Include casting directors selection --->

<div class="row">
  <div class="col-xl-6 col-lg-8 col-md-12">
    <div class="card mb-3">
      <div class="card-body">
        <form method="post" action="/include/audition-add2.cfm" class="parsley-examples" name="event-form" id="form-event" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate="data-parsley-validate">
          <cfoutput>
            <input type="hidden" name="new_audStepID" value="1"/>
            <input type="hidden" name="new_audcatid" value="#cat.audcatid#"/>
            <input type="hidden" name="new_audsubcatid" value="#new_audsubcatid#"/>
            <input type="hidden" name="new_userid" value="#userid#"/>
            <input type="hidden" name="isdirect" value="#isdirect#"/>
          </cfoutput>

          <cfif #isdirect# is "1">
            <!--- Display Direct Booking header if isdirect is 1 --->
            <h4 class="col-md-12">Direct Booking</h4>
          </cfif>

          <h4 class="col-md-12">
            <cfoutput>Category: #cat.audcatname# - #cat.audsubcatname#</cfoutput>
          </h4>

          <div class="row">
            <div class="form-group col-md-12">
              <label for="new_projname">Project Name (Title)<span class="text-danger">*</span>
              </label>
              <input class="form-control" type="text" id="new_projname" autocomplete="off" required="required" data-parsley-required="data-parsley-required" data-parsley-error-message="Project Name is required" name="new_projname" placeholder="Project Name" /></div>

              <div class="form-group col-md-12">
                <label for="new_projDescription">Project Description/Logline<span class="text-danger">*</span>
                </label>
                <input class="form-control" type="text" id="new_projDescription" data-parsley-required="data-parsley-required" data-parsley-="data-parsley-" name="new_projDescription" error-message="Project Description is required" placeholder="Project Description" /></div>

                <script>
                  function handleSelectChange(element) {
                    const hiddenSelfTape = document.getElementById('hiddenSelfTape');
                    const hiddenLocation = document.getElementById('hiddenLocation');
                    const locationInput = document.getElementById('eventLocation');
                    const hideDirectBooking = document.getElementById('hidedirectbooking');

                    // Show or hide the "Self Tape" div
                    if (hiddenSelfTape) {
                      hiddenSelfTape.style.display = element.value == 2
                        ? 'block'
                        : 'none';
                    }

                    // Show or hide the "Location" div and toggle "required" for Location input
                    if (hiddenLocation) {
                      hiddenLocation.style.display = element.value == 1
                        ? 'block'
                        : 'none';
                    }
                    if (locationInput) {
                      if (element.value == 1) {
                        locationInput.setAttribute('required', 'required');
                        locationInput.setAttribute('data-parsley-required', 'true');
                      } else {
                        locationInput.removeAttribute('required');
                        locationInput.removeAttribute('data-parsley-required');
                      }
                    }

                    // Show or hide the "Direct Booking" div
                    if (hideDirectBooking) {
                      hideDirectBooking.style.display = element.value == 23
                        ? 'none'
                        : 'block';
                    }

                    console.log("Value: ", element.value, "Type: ", typeof element.value);
                  }
                </script>

                <script>
                  function handleSelectChangeCasting(element) {

                    document
                      .getElementById('hiddenCasting')
                      .style
                      .display = element.value == 0
                        ? 'block'
                        : 'none';
                    console.log("Value: ", element.value, "Type: ", typeof element.value);
                  }
                </script>

                <script>
    document.addEventListener("DOMContentLoaded", function () {
        const isDirect = "<cfoutput>#isdirect#</cfoutput>";
        const hideDirectBooking = document.getElementById("hidedirectbooking");

        if (isDirect === "1") {
            // Hide the #hidedirectbooking element
            hideDirectBooking.style.display = "none";

            // Add margin styling to all elements with the 'input' class
            document.querySelectorAll(".input").forEach(function (inputElement) {
                inputElement.style.margin = "0 auto";
            });
        }
    });
</script>

<div class="form-group col-md-6 col-sm-12">
                  <label for="new_audrolename">Role Name<span class="text-danger">*</span>
                  </label>
                  <input class="form-control" type="text" id="new_audrolename" autocomplete="off" required="required" data-parsley-required="data-parsley-required" data-parsley-error-message="Role Name is required" name="new_audrolename" placeholder="Role Name" /></div>

                  <cfif #new_audcatid# IS "5">
                    <!--- Check if new_audcatid is 5 --->
                    <input type="hidden" name="new_audroletypeid" value="33"/>
                  <cfelse>
                    <div class="form-group col-md-6 col-sm-12">
                      <label for="new_audroletypeid">Role Type</label>
                      <select id="new_audroletypeid" name="new_audroletypeid" class="form-control" data-parsley-required="data-parsley-required" data-parsley-error-message="Role Type is required">
                        <option value="">--</option>
                        <cfoutput query="audroletypes_sel">
                          <option value="#audroletypes_sel.id#">#audroletypes_sel.name#</option>
                        </cfoutput>
                      </select>
                    </cfif>
                  </div>

                  <div class="form-group col-md-12">
                    <label for="new_contactid">Casting Director</label>
                    <select id="new_contactid" class="form-control" name="new_contactid" onChange="handleSelectChangeCasting(this);">
                      <option value="">--</option>
                      <option value="0">***ADD NEW***</option>
                      <cfoutput query="castingdirectors_sel">
                        <option value="#castingdirectors_sel.id#">#castingdirectors_sel.name#</option>
                      </cfoutput>
                    </select>
                  </div>

                  <div id="hiddenCasting">
                    <div class="row">
                      <fieldset>
                        <legend>Add New Casting</legend>
                        <div class="form-group col-md-10">
                          <div class="form-check">
                            <input class="form-check-input" type="radio" name="casting_info" id="casting_director_known" value="casting_director_known" checked="checked" />
                              <label class="form-check-label" for="casting_director_known">Casting Director known</label>
                            </div>
                            <div class="form-check">
                              <input class="form-check-input" type="radio" name="casting_info" id="only_company_known" value="only_company_known" />
                                <label class="form-check-label" for="only_company_known">Only company known</label>
                              </div>
                            </div>

                            <div id="CD">
                              <div class="form-group col-md-6">
                                <label for="cdfirstname">Casting Director</label>
                                <input class="form-control" type="text" id="cdfullname" name="cdfullname" autocomplete="off" placeholder="Casting Director" />
                                  <div id="nameResults"></div>
                                  <div class="invalid-feedback">Please enter a Casting Director.</div>
                                </div>

                                <div class="form-group col-md-6">
                                  <div id="cdrole">
                                    <label for="cdtype">Casting Director Role<span class="text-danger">*</span>
                                    </label>
                                    <select id="cdtype" name="cdtype" class="form-control" data-parsley-required="data-parsley-required" data-parsley-error-message="Casting Director Role is required">
                                      <option value="">--</option>
                                      <cfoutput query="casting_types">
                                        <option value="#casting_types.name#">#casting_types.name#</option>
                                      </cfoutput>
                                    </select>
                                  </div>
                                </div>
                              </div>

                              <div id="co_only">
                                <div class="form-group col-md-6">
                                  <label for="cdco">Casting Company</label>
                                  <input class="form-control" type="text" id="companySearch" name="cdco" autocomplete="off" placeholder="Casting Company" />
                                    <div id="results"></div>
                                    <div class="invalid-feedback">Please enter a Casting Company.</div>
                                  </div>
                                </div>
                              </fieldset>
                            </div>
                          </div>
                          
                          <fieldset class="answer" id="hidedirectbooking">
                            <legend>Appointment details</legend>
                            <div class="row">
                              <div class="form-group col-md-6">
                                <cfif #audtypes_sel.recordcount# is "1">
                                  <input type="hidden" name="" value=""/>
                                <cfelse>
                                  <label for="audtypeid">Type<span class="text-danger">*</span>
                                  </label>
                                  <select id="audtypeid" name="new_audtypeid" class="form-control" data-parsley-required="data-parsley-required" data-parsley-error-message="Type is required" onChange="handleSelectChange(this);">
                                    <option value="">--</option>
                                    <cfoutput query="audtypes_sel">
                                      <option value="#audtypes_sel.id#">#audtypes_sel.name#</option>
                                    </cfoutput>
                                  </select>

                                </cfif>
                              </div>

                              <div class="form-group col-md-6">
                                <label for="new_eventStart">Start Date / Due Date<span class="text-danger">*</span>
                                </label>
                                <input id="new_eventStart" class="form-control" autocomplete="off" name="new_eventStart" type="date" data-parsley-required="data-parsley-required" data-parsley-error-message="Start Date is required" /></div>

                                <div class="form-group col-md-6">
  <label for="new_eventStartTime">Start Time / Due Time<span class="text-danger">*</span></label>
  <select class="form-control"
          name="new_eventStartTime"
          autocomplete="off"
          id="new_eventStartTime"
          data-parsley-required="data-parsley-required"
          data-parsley-error-message="Start Time is required">
    <option value="">Select a Start Time</option>

    <!--- Convert the MySQL TIME columns to strings ("HH:mm:ss") --->
    <cfset new_calstarttime = timeFormat(calstarttime, "HH:mm:ss") />
    <cfset new_calendtime   = timeFormat(calendtime,   "HH:mm:ss") />

    <!--- Build date/time objects for today's date + the user's start/end times --->
    <cfset startTime = createODBCDateTime(
      dateFormat(now(), "yyyy-mm-dd") & " " & new_calstarttime
    ) />
    <cfset endTime = createODBCDateTime(
      dateFormat(now(), "yyyy-mm-dd") & " " & new_calendtime
    ) />

    <!--- Loop in 15-min increments from calstarttime to calendtime --->
    <cfloop condition="startTime LTE endTime">
      <cfset timeString  = timeFormat(startTime, "HH:mm:ss") />
      <cfset displayTime = timeFormat(startTime, "h:mm tt") />
      <cfoutput>
        <option value="#timeString#"
          <cfif timeString EQ new_calstarttime>selected</cfif>>
          #displayTime#
        </option>
      </cfoutput>
      <cfset startTime = dateAdd("n", 15, startTime) />
    </cfloop>
  </select>
</div>

                           

                                <div class="form-group col-md-6">
                                  <label for="new_eventStopTime">
                                    Duration</label>
                                  <select class="form-control" name="new_durid" autocomplete="off" id="new_durid">
                                    <cfoutput query="durations">
                                      <option value="#durations.durid#" <cfif #durations.durid# is "4"> selected </cfif>>
                                        #durations.durname#</option>
                                    </cfoutput>
                                  </select>
                                </div>
     </div>



                                <div id="hiddenSelfTape">
                                  <div class="form-group col-md-12">
                                    <label for="new_eventStart">
                                      Zoom Link (optional)</label>

                                    <input class="form-control" type="text" id="new_audLocation" autocomplete="off" name="new_audLocation" placeholder="Zoom link" /></div>

                                    <div class="form-group col-md-12">

                                      <label for="audplatformid">
                                        Audition Platform<span class="text-danger">
                                          *</span>
                                      </label>
                                      <select id="audplatformid" data-parsley-error-message="Platform is required" name="new_audplatformid" class="form-control" onchange="if (this.value=='CustomPlatform'){this.form['CustomPlatform'].style.display='block',this.form['CustomPlatform'].required=true} else {this.form['CustomPlatform'].style.display='none',this.form['CustomPlatform'].required=false};">

                                        <option value="">
                                          --</option>

                                        <option value="CustomPlatform">
                                          ***ADD CUSTOM</option>

                                        <cfoutput query="audplatforms_user_sel">

                                          <option value="#audplatforms_user_sel.id#">
                                            #audplatforms_user_sel.name#</option>

                                        </cfoutput>

                                      </select>

                                    </div>

                                    <div class="form-group col-md-6">
                                      <input class="form-control" required="false" type="text" id="CustomPlatform" name="CustomPlatform" value="" data-parsley-error-message="Platform is required" placeholder="Enter a Custom Platform" style="display:none;" /></div>

                                    </div>

                                    <div id="hiddenLocation">

                                      <div class="form-group col-md-12">
                                        <label for="projName">
                                          Location Name<span class="text-danger">
                                            *</span>
                                        </label>
                                        <input class="form-control" type="text" id="eventLocation" name="new_eventLocation" placeholder="Location Name"/>
                                        <div class="invalid-feedback">
                                          Please enter a Location Name.
                                        </div>
                                      </div>

                                      <div class="form-group col-md-12">
                                        <label for="projName">
                                          Address</label>
                                        <input class="form-control" type="text" id="audlocadd1" name="new_audlocadd1" placeholder="Address"/>

                                        <div class="invalid-feedback">
                                          Please enter an address.
                                        </div>
                                      </div>

                                      <div class="form-group col-md-12">
                                        <label for="projName">
                                          Extended Address</label>
                                        <input class="form-control" type="text" id="audlocadd2" name="new_audlocadd2" placeholder="APT 101"/>

                                        <div class="invalid-feedback">
                                          Please enter an extended address.
                                        </div>
                                      </div>

                                      <div class="row">

                                        <div class="form-group col-md-6">
                                          <label for="valuetext">
                                            Town/City</label>

                                          <input class="form-control" type="text" id="audcity" name="new_audcity" placeholder="Enter City" /></div>

                                          <div class="form-group col-md-6">
                                            <label for="valuetext">
                                              Postal Code</label>

                                            <input class="form-control" type="text" id="audzip" name="new_audzip" placeholder="Enter Postal Code" /></div>

                                          </div>

                                          <div class="row">
                                            <div class="form-group col-md-6">
                                              <label for="countryid">
                                                Country
                                              </label>

                                              <select id="countryid" class="form-control" name="countryid">
                                                <option value="">--</option>
                                                <cfoutput query="countries">
                                                  <option value="#countries.countryid#" <cfif #countries.countryid# is "US">selected </cfif>>
                                                    #countries.countryname#</option>
                                                </cfoutput>
                                              </select>
                                            </div>

                                            <script>
                                              $("#new_region_id").chained("#countryid");
                                            </script>

                                            <div class="form-group col-md-6">
                                              <label for="region_id">
                                                State/Region<span class="text-danger">
                                                  *</span>
                                              </label>

                                              <select id="region_id" name="new_region_id" class="form-control">
                                                <option value="">
                                                  --</option>

                                                <cfoutput query="regions">
                                                  <option value="#regions.region_id#" data-chained="#regions.countryid#">
                                                    #regions.regionname#</option>
                                                </cfoutput>

                                              </select>

                                            </div>

                                          </div>

                                        </div>

                                        <div id="hiddenAddLocation">
                                          <fieldset>
                                            <legend>
                                              Add New Location</legend>

                                            <div class="row">
                                            
                                              <cfinclude template="/include/qry/countries_457_1.cfm"/>
                                              <cfinclude template="/include/qry/regions.cfm"/>
                                              <cfinclude template="/include/qry/cities.cfm"/>

                                              <div class="form-group col-md-12">
                                                <label for="projName">
                                                  Location Name<span class="text-danger">
                                                    *</span>
                                                </label>
                                                <input class="form-control" type="text" id="eventLocation" name="new_eventLocation" placeholder="Location Name" required="required" data-parsley-required="data-parsley-required" data-parsley-error-message="Location Name is required" />

                                                  <div class="invalid-feedback">
                                                    Please enter a Location Name.
                                                  </div>
                                                </div>

                                                <div class="form-group col-md-12">
                                                  <label for="projName">
                                                    Address</label>
                                                  <input class="form-control" type="text" id="audlocadd1" name="new_audlocadd1" placeholder="Address"/>

                                                  <div class="invalid-feedback">
                                                    Please enter an address.
                                                  </div>
                                                </div>

                                                <div class="form-group col-md-12">
                                                  <label for="projName">
                                                    Extended Address</label>
                                                  <input class="form-control" type="text" id="audlocadd2" name="new_audlocadd2" placeholder="APT 101"/>

                                                  <div class="invalid-feedback">
                                                    Please enter an extended address.
                                                  </div>
                                                </div>

                                                <div class="form-group col-md-6">
                                                  <label for="valuetext">
                                                    Town/City</label>

                                                  <input class="form-control" type="text" id="audcity" name="new_audcity" placeholder="Enter City" /></div>

                                                  <div class="form-group col-md-6">
                                                    <label for="valuetext">
                                                      Postal Code</label>

                                                    <input class="form-control" type="text" id="audzip" name="new_audzip" placeholder="Enter Postal Code" /></div>

                                                    <div class="form-group col-md-6">
                                                      <label for="countryid">
                                                        Country<span class="text-danger">
                                                          *</span>
                                                      </label>

                                                      <select id="countryid" class="form-control" name="countryid" data-parsley-required="data-parsley-required" data-parsley-error-message="Country is required">
                                                        <option value="">
                                                          --</option>
                                                        <cfoutput query="countries">
                                                          <option value="#countries.countryid#">
                                                            #countries.countryname#</option>
                                                        </cfoutput>
                                                      </select>

                                                    </div>

                                                    <div class="form-group col-md-6">
                                                      <label for="region_id">
                                                        State/Region<span class="text-danger">
                                                          *</span>
                                                      </label>

                                                      <select id="region_id" name="new_region_id" class="form-control">
                                                        <option value="">
                                                          --</option>

                                                        <cfoutput query="regions">
                                                          <option value="#regions.region_id#" data-chained="#regions.countryid#">
                                                            #regions.regionname#</option>
                                                        </cfoutput>

                                                      </select>

                                                    </div>

                                                  </fieldset>

                                                </div>

                                              </fieldset>
                                            </div>

                                            <div class="row mt-2">

                                              <div class="">
                                                <a href="javascript:history.go(-1)">
                                                  <button type="button" class="btn btn-light mr-1 btn-sm" data-bs-dismiss="modal">
                                                    Back</button>
                                                </a>
                                                <button type="submit" class="btn btn-primary btn-sm waves-effect waves-light" id="btn-save-event">
                                                  Add</button>
                                              </div>
                                            </div>
                                          </form>

                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                  <script>
                                    $("#region_id").chained("#countryid");
                                  </script>
                                  <script>
                                    $("#audtypeid").chained("#audcatid");
                                  </script>
                                  <script>
                                    $("#new_audroletypeid").chained("#audcatid");
                                  </script>
                                  <script>
                                    $("#new_audsubcatid").chained("#audcatid");
                                  </script>
