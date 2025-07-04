<!--- This ColdFusion page handles the audition submission form, including various fields and dynamic visibility of elements based on user input. --->

<cfparam name="new_audStepID" default="1"/>
<cfparam name="new_audcatid" default="1"/>
<cfparam name="new_audsubcatid" default="6"/>
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
        <form method="post" action="/include/audition-update2.cfm" class="parsley-examples" name="event-form" id="form-event" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate="data-parsley-validate">
          <cfoutput>
            <input type="hidden" name="new_audStepID" value="1"/>
            <input type="hidden" name="new_audcatid" value="#new_audcatid#"/>
            <input type="hidden" name="new_audsubcatid" value="#new_audsubcatid#"/>
            <input type="hidden" name="new_userid" value="#userid#"/>
            <input type="hidden" name="isdirect" value="#isdirect#"/>
          </cfoutput>

          <cfif #isdirect# is "1">
            <!--- Display Direct Booking header if isdirect is 1 --->
            <h4 class="col-md-12">Direct Booking</h4>
          </cfif>

       

               <h4 class="col-md-12">
            <cfoutput>Project Name (Title): </cfoutput>
          </h4>
   <p class="col-md-12">
            <cfoutput>Category: #cat.audcatname# - #cat.audsubcatname#</cfoutput>
          </p>

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



                

                              <div class="form-group col-md-6">
                                <label for="new_eventStart">Start Date / Due Date<span class="text-danger">*</span>
                                </label>
                                <input id="new_eventStart" class="form-control" autocomplete="off" name="new_eventStart" type="date" data-parsley-required="data-parsley-required" data-parsley-error-message="Start Date is required" /></div>

                                <div class="form-group col-md-6">
                                  <label for="new_eventStartTime">Start Time / Due Time<span class="text-danger">*</span>
                                  </label>
                                  <select class="form-control" name="new_eventStartTime" autocomplete="off" id="new_eventStartTime" data-parsley-required="data-parsley-required" data-parsley-error-message="Start Time is required">
    <option value="">Select a Start Time</option>
    <cfset selectedTime = timeformat(userCalStarttime, 'HH:mm')>
    <cfloop from="0" to="23" index="hour">
        <cfloop from="0" to="45" step="15" index="minute">
            <cfset hourStr = right("0" & hour, 2)>
            <cfset minuteStr = right("0" & minute, 2)>
            <cfset timeValue = hourStr & ":" & minuteStr>
            <cfset displayTime = timeformat(createDateTime(2000, 1, 1, hour, minute, 0), "hh:mm tt")>
            <cfoutput>
                <option value="#timeValue#" <cfif timeValue eq selectedTime>selected</cfif>>#displayTime#</option>
            </cfoutput>
        </cfloop>
    </cfloop>
</select>

                                </div>

                                <div class="form-group col-md-6">
                                  <label for="new_durid">
                                    Duration</label>
                                  <select class="form-control" name="new_durid" autocomplete="off" id="new_durid">
                                    <cfoutput query="durations">
                                      <option value="#durations.durid#" <cfif #durations.durid# is "4"> selected </cfif>>
                                        #durations.durname#</option>
                                    </cfoutput>
                                  </select>
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
