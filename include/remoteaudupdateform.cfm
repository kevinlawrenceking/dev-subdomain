<!--- Ensure the required CF parameters are declared --->
<cfparam name="isdirect" default="0" />
<cfparam name="pgaction" default="view" />
<cfparam name="old_callbacktypeid" default="0" />
<cfparam name="isdirect" default="0" />
<cfparam name="valuetext" default="" />
<cfparam name="new_durseconds" default="0" />

<!--- Include necessary queries and data lookups --->
<cfinclude template="/include/qry/durations.cfm" />
<cfinclude template="/include/qry/fetchLocationService.cfm" />
<cfinclude template="/include/qry/fetchusers.cfm" />
<cfinclude template="/include/qry/audplatforms_user_sel.cfm" />
<cfinclude template="/include/qry/projectDetails_221_1.cfm" />
<cfset audroleid = projectDetails.audroleid />
<Cfset new_audroleid = audroleid />
<cfinclude template="/include/qry/roleDetails_221_2.cfm" />
<cfinclude template="/include/qry/locationDetails_492_1.cfm" />
    <cfset NEW_AUDSUBCATID = projectDetails.audsubcatid />
<cfinclude template="/include/qry/cat_221_3.cfm" />
<cfinclude template="/include/qry/cat_221_4.cfm" />
<cfinclude template="/include/qry/audroletypes_sel_27_2.cfm" />
<cfinclude template="/include/qry/audtypes_sel_221_6.cfm" />
<cfinclude template="/include/qry/casting_types_221_7.cfm" />
<cfinclude template="/include/qry/castingdirectors_sel.cfm" />

<!--- If adding a new audition --->
<cfif #pgaction# eq "add">
    <!--- Initialize new audition variables --->
    <cfparam name="new_durid" default="0" />
    <cfparam name="new_userid" default="" />
    <cfparam name="new_audRoleID" default="" />
    <cfparam name="new_audTypeID" default="" />
    <cfparam name="new_audLocation" default="" />
    <cfparam name="new_audlocid" default="" />
    <cfparam name="new_eventStart" default="" />
    <cfparam name="new_eventStartTime" default="" />
    <cfparam name="new_eventStopTime" default="" />
    <cfparam name="new_audplatformid" default="4" />
    <cfparam name="new_audStepID" default="1" />
    <cfparam name="new_parkingDetails" default="" />
    <cfparam name="new_workwithcoach" default="0" />
    <cfparam name="new_isDeleted" default="0" />
    <cfparam name="new_trackmileage" default="0" />
    <Cfif #isdefined('audstepid')#>
<cfset new_audstepid = audstepid />
</cfif>

    <cfinclude template="/include/qry/auditions_ins_221_8.cfm" />
    <cfset eventid = result />
    <cfset new_eventid = result />
    <Cfelse>
    <Cfset new_eventid = eventid />
</cfif>



<!--- Fetch audition details --->
<cfinclude template="/include/qry/aud_det_221_9.cfm" />
<cfset new_audcatid = aud_det.audcatid />
<cfinclude template="/include/qry/audtypes_sel_221_11.cfm" />
<cfinclude template="/include/qry/audsteps_sel_217_3.cfm" />
<cfinclude template="/include/qry/audplatforms_sel.cfm" />

<!--- Example of setting region/country defaults if empty --->
<cfset new_region_id = locationDetails.same_region_id />
<cfset new_countryid = locationDetails.same_countryid />
<cfif new_countryid eq ""><cfset new_countryid = "US" /></cfif>
<cfif new_region_id eq ""><cfset new_region_id = "3911" /></cfif>

<!--- If the user provided duration hours, use them; otherwise default to 1 hour --->
<cfif aud_det.new_durhours eq "">
    <cfset new_durhours = 1 />
<cfelse>
    <cfset new_durhours = aud_det.new_durhours />
</cfif>

<!--- Include a query to find durations --->
<cfinclude template="/include/qry/findd_221_10.cfm" />
<cfif findd.recordcount eq 1>
    <cfset new_durid = findd.new_durid />
<cfelse>
    <cfset new_durid = 0 />
</cfif>




<h4>
    <cfoutput>#aud_det.audstep# appointment</cfoutput>
</h4>

<!--- Form to update existing audition data --->
<form method="post"
      action="/include/remoteaudupdateform2.cfm"
      class="parsley-examples"
      name="event-form"
      id="form-event"
      data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden"
      data-parsley-trigger="keyup"
      data-parsley-validate>

    <cfoutput>
        <!--- Hidden fields carrying IDs & references --->
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
        <input type="hidden" name="new_eventid" value="#new_eventid#" />
        <input type="hidden" name="eventid" value="#new_eventid#" />
        <input type="hidden" name="new_audStepID" value="#aud_det.audstepid#" />
        <input type="hidden" name="new_audcatid" value="#aud_det.audcatid#" />
        <input type="hidden" name="new_audsubcatid" value="#aud_det.audsubcatid#" />
        <input type="hidden" name="new_userid" value="#userid#" />
        <input type="hidden" name="secid" value="#secid#" />
        <input type="hidden" name="new_audRoleID" value="#aud_det.audroleid#" />
    </cfoutput>

    <!--- Display the category/subcategory info --->
    <div class="row">
      <div class="form-group col-md-12">
          <label>
              <cfoutput>Category: #cat.audcatname# - #cat.audsubcatname#</cfoutput>
          </label>
      </div>
    </div>

    <!--- Start/Due Date --->
    <div class="row">
        <cfoutput>
            <div class="form-group col-md-6">
                <label for="new_eventStart">Start Date / Due Date <span class="text-danger">*</span></label>
                <input id="new_eventStart"
                       class="form-control"
                       name="new_eventStart"
                       type="date"
                       autocomplete="off"
                       data-parsley-required
                       data-parsley-error-message="Start Date is required"
                       value="#aud_det.eventStart#" />
            </div>
        </cfoutput>

        <!--- Start/Due Time (uses the time loop from calstarttime to calendtime) --->
        <div class="form-group col-md-6">
            <label for="new_eventStartTime">Start Time / Due Time <span class="text-danger">*</span></label>
            <select class="form-control"
                    name="new_eventStartTime"
                    autocomplete="off"
                    id="new_eventStartTime"
                    data-parsley-required
                    data-parsley-error-message="Start Time is required">

                <option value="">Select a Start/Due Time</option>
                
                <!--- Convert MySQL TIME columns to strings (e.g. "05:00:00") --->
                <cfset new_calstarttime = timeFormat(calstarttime, "HH:mm:ss") />
                <cfset new_calendtime   = timeFormat(calendtime,   "HH:mm:ss") />

                <!--- Build date/time objects for "today’s date + calstarttime/calendtime" --->
                <cfset startTime = createODBCDateTime(dateFormat(now(), "yyyy-mm-dd") & " " & new_calstarttime) />
                <cfset endTime   = createODBCDateTime(dateFormat(now(), "yyyy-mm-dd") & " " & new_calendtime) />

                <!--- Convert existing eventStartTime to "HH:mm:ss" for comparison --->
                <cfset selectedEventTime = timeFormat(aud_det.eventStartTime, "HH:mm:ss") />

                <!--- Loop from 'startTime' to 'endTime' in 15-min increments --->
                <cfloop condition="startTime LTE endTime">
                  <cfset timeString  = timeFormat(startTime, "HH:mm:ss") />
                  <cfset displayTime = timeFormat(startTime, "h:mm tt") />

                  <cfoutput>
                    <option value="#timeString#"
                      <cfif timeString eq selectedEventTime>selected</cfif>>
                      #displayTime#
                    </option>
                  </cfoutput>

                  <cfset startTime = dateAdd("n", 15, startTime) />
                </cfloop>
            </select>
        </div>
    </div>

    <!--- Duration --->
    <div class="row">
      <div class="form-group col-md-6">
          <label for="new_durid">Duration</label>
          <select class="form-control" name="new_durid" id="new_durid">
              <cfoutput query="durations">
                  <option value="#durations.durid#"
                    <cfif durations.durid eq new_durid> selected </cfif>>
                    #durations.durname#
                  </option>
              </cfoutput>
          </select>
      </div>

      <!--- If audition step is 2 (Callback) => add callback type dropdown --->
      <cfif aud_det.audstepid eq "2">
          <div class="form-group col-md-6">
              <cfinclude template="/include/qry/audcallbacktypes_sel.cfm" />
              <label for="NEW_CALLBACKTYPEID">Callback Type <span class="text-danger">*</span></label>
              <select id="NEW_CALLBACKTYPEID"
                      name="NEW_CALLBACKTYPEID"
                      class="form-control"
                      data-parsley-required
                      data-parsley-error-message="Callback Type is required">
                  <!--- Default "blank" or placeholder option --->
                  <cfoutput query="audcallbacktypes_sel_def">
                      <option value="#audcallbacktypes_sel_def.id#">
                        #audcallbacktypes_sel_def.name#
                      </option>
                  </cfoutput>

                  <!--- Options from callback query --->
                  <cfoutput query="audcallbacktypes_sel">
                      <cfif audcallbacktypes_sel.id eq old_callbacktypeid>
                          <option value="#audcallbacktypes_sel.id#" selected>
                            #audcallbacktypes_sel.name#
                          </option>
                      <cfelse>
                          <option value="#audcallbacktypes_sel.id#">
                            #audcallbacktypes_sel.name#
                          </option>
                      </cfif>
                  </cfoutput>
              </select>
          </div>
      <cfelse>
          <!--- If not step 2, store old_callbacktypeid silently --->
          <input type="hidden" name="new_callbacktypeid" value="#old_callbacktypeid#" />
      </cfif>
    </div>

    <div class="row">
      <!--- Audition Type (in-person, self-tape, etc.) --->
      <div class="form-group col-md-6">
          <label for="audtypeid">Type <span class="text-danger">*</span></label>
          <select id="audtypeid"
                  name="new_audtypeid"
                  class="form-control"
                  data-parsley-required
                  data-parsley-error-message="Type is required"
                  onchange="handleSelectChange(this, '<cfoutput>#new_eventid#</cfoutput>')">
              <option value="">--</option>
              <cfoutput query="audtypes_sel">
                  <option value="#audtypes_sel.id#"
                    <cfif audtypes_sel.id eq aud_det.audtypeid> selected </cfif>>
                    #audtypes_sel.name#
                  </option>
              </cfoutput>
          </select>
      </div>

      <!--- If audition step is 5 => show "Booking Type" --->
      <cfif aud_det.audstepid eq "5">
          <div class="form-group col-md-6 col-sm-12">
              <cfinclude template="/include/qry/audbooktypes_sel_221_13.cfm" />
              <label for="audbooktypeid">Booking Type <span class="text-danger">*</span></label>
              <select id="audbooktypeid"
                      name="new_audbooktypeid"
                      class="form-control"
                      data-parsley-required
                      data-parsley-error-message="Booking Type is required">
                  <option value="0">--</option>
                  <cfoutput query="audbooktypes_sel">
                      <option value="#audbooktypes_sel.id#"
                        <cfif audbooktypes_sel.id eq aud_det.audbooktypeid> selected </cfif>>
                        #audbooktypes_sel.name#
                      </option>
                  </cfoutput>
              </select>
          </div>
      </cfif>
    </div>

      <cfif aud_det.audtypeid eq 1>
    <Cfset hiddenlocdisplay = "block">
    <Cfelse>
    <cfset hiddenlocdisplay = "none">
    </cfif>


    <cfoutput>
    <!--- Location Container (only if 'In Person' is selected [=1]) --->
    <div class="row" id="hiddenLocation#new_eventid#" style="display:#hiddenlocdisplay#;">

        <div class="form-group col-md-12">
            <label for="new_parkingDetails">Parking Details</label>
            <input class="form-control"
                   type="text"
                   id="new_parkingDetails"
                   name="new_parkingDetails"
                   placeholder="Parking details"
                   value="#aud_det.parkingDetails#" />
        </div>

        <div class="form-group col-md-12">
          <div class="form-check">
            <input type="checkbox"
                   class="form-check-input"
                   id="trackmileage"
                   value="1"
                   name="new_trackmileage"
                   <cfif aud_det.trackmileage eq "1">checked</cfif> />
            <label class="form-check-label" for="trackmileage">
              Track Mileage
            </label>
          </div>
        </div>

        <!--- Location Name + "Same" Button --->
        <div class="form-group col-md-12 d-flex align-items-center">
            <label for="eventLocation" class="mb-0 flex-grow-1">
                Location Name <span class="text-danger">*</span>
            </label>
            <cfif locationDetails.recordcount NEQ 0>
                <button type="button"
                        class="btn btn-primary btn-sm ml-auto"
                        id="populateFieldsButton">
                    Same
                </button>
            </cfif>
        </div>

        <div class="form-group col-md-12">
            <input class="form-control"
                   type="text"
                   id="eventLocation#new_eventid#"
                   name="new_eventLocation"
                   placeholder="Location Name"
                   data-parsley-required
                   data-parsley-error-message="Location Name is required"
                   value="#aud_det.eventLocation#" />
        </div>

        <div class="form-group col-md-12">
            <label for="audlocadd1">Address</label>
            <input class="form-control"
                   type="text"
                   id="audlocadd1"
                   name="new_audlocadd1"
                   placeholder="Address"
                   value="#aud_det.audlocadd1#" />
        </div>

        <div class="form-group col-md-12">
            <label for="audlocadd2">Extended Address</label>
            <input class="form-control"
                   type="text"
                   id="audlocadd2"
                   name="new_audlocadd2"
                   placeholder="APT 101"
                   value="#aud_det.audlocadd2#" />
        </div>

        <div class="form-group col-md-6">
            <label for="audcity">Town/City</label>
            <input class="form-control"
                   type="text"
                   id="audcity"
                   name="new_audcity"
                   placeholder="Enter City"
                   value="#aud_det.audcity#" />
        </div>

        <div class="form-group col-md-6">
            <label for="audzip">Postal Code</label>
            <input class="form-control"
                   type="text"
                   id="audzip"
                   name="new_audzip"
                   placeholder="Enter Postal Code"
                   value="#aud_det.audzip#" />
        </div>
</cfoutput>
        <!--- State/Region + Country --->
        <div class="form-group col-md-6">
            <label for="region_id">State/Region <span class="text-danger">*</span></label>
            <select id="region_id" name="new_region_id" class="form-control">
                <option value="">--</option>
                <cfloop query="regions"><cfoutput>
                    <option value="#regions.region_id#"
                            data-chained="#regions.countryid#"
                            <cfif regions.region_id eq new_region_id>selected</cfif>>
                        #regions.regionname#
                    </cfoutput></option>
                </cfloop>
            </select>
        </div>

        <div class="form-group col-md-6">
            <label for="countryid">Country <span class="text-danger">*</span></label>
            <select id="countryid"
                    class="form-control"
                    name="countryid"
                    data-parsley-required
                    data-parsley-error-message="Country is required"
                    onchange="filterRegions(this.value)">
                <option value="">--</option>
                <cfloop query="countries"><cfoutput>
                    <option value="#countries.countryid#"
                      <cfif countries.countryid eq new_countryid>selected</cfif>>
                      #countries.countryname#
                   </cfoutput> </option>
                </cfloop>
            </select>
        </div>
    </div> <!-- end #hiddenLocation -->

    <!--- Self Tape Container (only if 'Self Tape' is selected [=2]) --->

    <cfif aud_det.audtypeid eq 2>
    <Cfset hiddenselfdisplay = "block">
    <Cfelse>
    <cfset hiddenselfdisplay = "none">
    </cfif>
          <cfoutput>
    <div class="row" id="hiddenSelfTape#new_eventid#" style="display:#hiddenselfdisplay#;">
  
            <div class="form-group col-md-12">
                <label for="new_audLocation">Platform URL (optional)</label>
                <input class="form-control"
                       type="text"
                       id="new_audLocation"
                       name="new_audLocation"
                       placeholder="Zoom link"
                       value="#aud_det.audlocation#" />
            </div>
            <input type="hidden" name="old_audPlatformid" value="#aud_det.audplatformid#" />
        </cfoutput>

        <!--- Audition Platform Dropdown --->
        <div class="form-group col-md-6">
            <label for="audplatformid">Audition Platform</label>
            <select id="audplatformid"
                    name="new_audplatformid"
                    class="form-control"
                    onchange="
                      if (this.value=='CustomPlatform'){
                        document.getElementById('CustomPlatform').style.display='block';
                        document.getElementById('CustomPlatform').required=true;
                      } else {
                        document.getElementById('CustomPlatform').style.display='none';
                        document.getElementById('CustomPlatform').required=false;
                      }
                    ">
                <option value="">--</option>
                <option value="CustomPlatform">***ADD CUSTOM</option>
                <cfoutput query="audplatforms_user_sel">
                    <option value="#audplatforms_user_sel.id#"
                      <cfif audplatforms_user_sel.id eq aud_det.audplatformid> selected </cfif>>
                      #audplatforms_user_sel.name#
                    </option>
                </cfoutput>
            </select>
        </div>

        <!--- Custom Platform Text Field (hidden by default) --->
        <div class="form-group col-md-6" id="CustomPlatform" style="display:none;">
            <label for="CustomPlatform">Custom Platform</label>
            <input class="form-control"
                   type="text"
                   id="CustomPlatform"
                   name="CustomPlatform"
                   placeholder="Enter a Custom Platform" />
        </div>
    </div> <!-- end #hiddenSelfTape -->

    <!--- Worked with Coach? --->

    <cfif aud_det.audstepid neq 5>
    <div class="row">
      <cfoutput>
        <div class="form-group col-md-12">
          <div class="form-check">
            <input type="checkbox"
                   class="form-check-input"
                   id="workwithcoach"
                   value="1"
                   name="new_workwithcoach"
                   <cfif aud_det.workwithcoach eq "1">checked</cfif> />
            <label class="form-check-label" for="workwithcoach">
              Worked with Coach
            </label>
          </div>
        </div>
      </cfoutput>
    </div>
</cfif>

    <!--- Submit button --->
    <div class="row">
      <div class="form-group col-md-12">
          <button type="submit" class="btn btn-primary btn-sm waves-effect waves-light" id="btn-save-event">
              Update
          </button>
      </div>
    </div>
</form>

<!--- All scripts moved to bottom for clarity and performance --->
<script src="/app/assets/js/jquery.chained.js?ver=13.4.0.381214213207"></script>

<!--- Parsley.js init (if needed) --->
<script>
  $(document).ready(function() {
    $(".parsley-examples").parsley();
  });
</script>

<!--- Functions for toggling location/self-tape fields based on audtypeid (1,2, etc.) --->
<script>
function handleSelectChange(element, eventId) {
    const typeValue = parseInt(element.value, 10);

    // Location (type=1 => in-person)
    const hiddenLocation = document.getElementById('hiddenLocation' + eventId);
    const locationInput = document.getElementById('eventLocation' + eventId);
    if (typeValue === 1) {
        hiddenLocation.style.display = 'block';
        locationInput.setAttribute('required', 'required');
        locationInput.setAttribute('data-parsley-required', 'true');
    } else {
        hiddenLocation.style.display = 'none';
        locationInput.removeAttribute('required');
        locationInput.removeAttribute('data-parsley-required');
    }

    // Self Tape (type=2 => self-tape)
    const hiddenSelfTape = document.getElementById('hiddenSelfTape' + eventId);
    if (typeValue === 2) {
        hiddenSelfTape.style.display = 'block';
    } else {
        hiddenSelfTape.style.display = 'none';
    }
}

</script>

<!--- Filter Regions based on selected country (custom-chained logic) --->
<script>
  function filterRegions(selectedCountryId) {
    const regionSelect = document.getElementById('region_id');
    const options = regionSelect.options;

    for (let i = 0; i < options.length; i++) {
      const option = options[i];
      const countryId = option.getAttribute('data-chained');

      // Show if matching country or empty (the "--" option)
      if (countryId === selectedCountryId || option.value === "") {
        option.style.display = "block";
      } else {
        option.style.display = "none";
      }
    }

    // Reset selection if currently invalid
    if (
      regionSelect.value &&
      regionSelect.options[regionSelect.selectedIndex].getAttribute('data-chained') !== selectedCountryId
    ) {
      regionSelect.value = "";
    }
  }

  // Filter on page load if a country is already selected
  document.addEventListener("DOMContentLoaded", function () {
    const countrySelect = document.getElementById('countryid');
    if (countrySelect) {
      const selectedCountryId = countrySelect.value;
      if (selectedCountryId) {
        filterRegions(selectedCountryId);
      }
    }
  });
</script>

<!--- Populate "Same" location fields script --->
<script>
  document.getElementById('populateFieldsButton')?.addEventListener('click', function() {
    // Pull in data from your CF query
    var locationDetails = {
      same_eventLocation : "<cfoutput>#locationDetails.same_eventLocation#</cfoutput>",
      same_audlocadd1    : "<cfoutput>#locationDetails.same_audlocadd1#</cfoutput>",
      same_audlocadd2    : "<cfoutput>#locationDetails.same_audlocadd2#</cfoutput>",
      same_audcity       : "<cfoutput>#locationDetails.same_audcity#</cfoutput>",
      same_region_id     : "<cfoutput>#locationDetails.same_region_id#</cfoutput>",
      same_countryid     : "<cfoutput>#locationDetails.same_countryid#</cfoutput>",
      same_audzip        : "<cfoutput>#locationDetails.same_audzip#</cfoutput>"
    };

    // Populate the form fields
    document.getElementById('eventLocation').value = locationDetails.same_eventLocation;
    document.getElementById('audlocadd1').value   = locationDetails.same_audlocadd1;
    document.getElementById('audlocadd2').value   = locationDetails.same_audlocadd2;
    document.getElementById('audcity').value      = locationDetails.same_audcity;
    document.getElementById('region_id').value    = locationDetails.same_region_id;
    document.getElementById('countryid').value    = locationDetails.same_countryid;
    document.getElementById('audzip').value       = locationDetails.same_audzip;
  });
</script>

<!--- Hide direct booking if "isdirect" => 1 --->
<script>
  document.addEventListener("DOMContentLoaded", function () {
    const isDirect = "<cfoutput>#isdirect#</cfoutput>";
    const hideDirectBooking = document.getElementById("hidedirectbooking");
    if (isDirect === "1" && hideDirectBooking) {
      hideDirectBooking.style.display = "none";
    }
  });
</script>
