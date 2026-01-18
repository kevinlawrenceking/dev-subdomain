<!--- This ColdFusion page handles the creation of an appointment with various input fields and validation. --->

<cfparam name="rcontactid" default="0" />

<!--- Include necessary queries --->
<cfinclude template="/include/qry/relationships_13_1.cfm" />
<cfinclude template="/include/qry/durations.cfm" />
<cfinclude template="/include/qry/eventtypes_user_443_2.cfm" />



<script>
    $(document).ready(function() {
        $("#select-relationship").selectize({
            persist: !1,
            createOnBlur: !0,
            create: !0,
            plugins: ["remove-button"],
            delimiter: ",",
            persist: false,
            create: function(input) {
                return {
                    value: input,
                    text: input,
                };
            },
        });
    });
</script>


<div class="col-xl-6 col-lg-8 col-md-12">
  <div class="card mb-3">
    <div class="card-body">
      <form
        method="post"
        action="/include/appoint-add2.cfm"
        class="parsley-examples"
        name="event-form"
        id="form-event"
        data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden"
        data-parsley-trigger="keyup"
        data-parsley-validate="data-parsley-validate"
      >
        <!--- Hidden fields to pass necessary data --->
        <cfoutput>
          <input type="hidden" name="returnurl" value="#returnurl#" />
          <input type="hidden" name="rcontactid" value="#rcontactid#" />
          <input type="hidden" name="userid" value="#userid#" />
        </cfoutput>

        <div class="row">
          <!--- Title Input --->
          <div class="col-12">
            <div class="form-group">
              <label class="control-label">
                Title <span class="text-danger">*</span>
              </label>
              <input
                class="form-control"
                autocomplete="off"
                placeholder="Insert Appointment Title"
                type="text"
                name="eventTitle"
                id="eventTitle"
                data-parsley-minlength="3"
                data-parsley-minlength-message="Min length 3 characters"
                data-parsley-maxlength="200"
                data-parsley-maxlength-message="Max length 200 characters"
                data-parsley-required="data-parsley-required"
                data-parsley-error-message="Title is required"
              />
            </div>
          </div>

          <!--- Relationships Input --->
          <div class="col-lg-12">
            <div class="form-group mb-3">
              <label for="select-relationship" class="form-label">
                Relationships <span class="text-danger" aria-hidden="true">*</span>
                <span class="visually-hidden">(required)</span>
              </label>
              <select
                id="select-relationship"
                name="relationships"
                autocomplete="off"
                multiple
                data-parsley-required="true"
                data-parsley-error-message="Relationship is required"
                class="demo-default selectize-close-btn"
                style="width: 100%"
                placeholder="Select one or more existing relationships or type to add new one"
              >
                <option value="">Select one or more Relationships...</option>
                <cfloop query="relationships">
                  <cfoutput>
                    <option
                      value="#relationships.contactid#"
                      <cfif "#relationships.contactid#" is "#rcontactid#">selected</cfif>
                    >
                      #recordname#
                    </option>
                  </cfoutput>
                </cfloop>
              </select>
            </div>
          </div>

          <!--- Description Input --->
          <div class="form-group col-md-12">
            <label for="eventDescription">Description</label>
            <textarea
              class="form-control"
              id="eventDescription"
              name="eventDescription"
              placeholder="Description"
              rows="4"
            ></textarea>
          </div>

          <!--- Location Input --->
          <div class="form-group col-md-12">
            <label for="eventLocation">Location</label>
            <input
              class="form-control"
              id="eventLocation"
              autocomplete="off"
              name="eventLocation"
              placeholder="Location"
              type="text"
            />
          </div>

          <!--- Start Date Input --->
          <div class="form-group col-md-6 col-sm-12">
            <label for="eventStart">
              Start Date <span class="text-danger">*</span>
            </label>
            <input
              id="eventStart"
              class="form-control"
              autocomplete="off"
              name="eventStart"
              type="date"
              data-parsley-required="data-parsley-required"
              data-parsley-error-message="Start Date is required"
            />
          </div>

          <!--- Event Type Input --->
          <div class="form-group col-md-6 col-sm-12">
            <label for="eventTypeName">
              Type <span class="text-danger">*</span>
            </label>
            <select
              class="form-control"
              name="eventTypeName"
              id="eventTypeName"
              data-parsley-required="data-parsley-required"
              data-parsley-error-message="Type is required"
            >
              <option value=""></option>
              <cfoutput query="eventtypes_user">
                <cfif eventtypes_user.eventtypename neq "audition">
                  <option value="#eventtypes_user.eventtypename#">
                    #eventtypes_user.eventtypename#
                  </option>
                </cfif>
              </cfoutput>
            </select>
          </div>
          <!--- Start Time Input --->
          <div class="form-group col-md-6 col-sm-12">
            <label for="eventStartTime">
              Start Time <span class="text-danger">*</span>
            </label>
            <select
              class="form-control"
              name="eventStartTime"
              autocomplete="off"
              id="eventStartTime"
              data-parsley-required="data-parsley-required"
              data-parsley-error-message="Start Time is required"
            >
              <option value="">Select a Start Time</option>

              <!--- Ensure `calstarttime` and `calendtime` are set --->
              <cfparam name="calstarttime" default="09:00:00" />
              <cfparam name="calendtime" default="17:00:00" />

              <!--- Convert DB time columns into strings: "HH:mm:ss" --->
              <cfset new_calstarttime = timeFormat(calstarttime, "HH:mm:ss") />
              <cfset new_calendtime = timeFormat(calendtime, "HH:mm:ss") />

              <!--- Build date-time objects --->
              <cfset startTime = createODBCDateTime(dateFormat(now(), "yyyy-mm-dd") & " " & new_calstarttime) />
              <cfset endTime = createODBCDateTime(dateFormat(now(), "yyyy-mm-dd") & " " & new_calendtime) />

              <!--- Ensure `startTime` and `endTime` are valid --->
              <cfif NOT IsDate(startTime) OR NOT IsDate(endTime)>
                <cfthrow message="Start Time or End Time is invalid." />
              </cfif>

              <!--- Loop from startTime to endTime in 15-minute increments --->
              <cfloop condition="startTime LTE endTime">
                <cfset timeString = timeFormat(startTime, "HH:mm:ss") />
                <cfset displayTime = timeFormat(startTime, "h:mm tt") />
                <cfoutput>
                  <option value="#timeString#" <cfif timeString EQ new_calstarttime>selected</cfif>>
                    #displayTime#
                  </option>
                </cfoutput>

                <!--- Add 15 minutes --->
                <cfset startTime = dateAdd("n", 15, startTime) />
              </cfloop>
            </select>
          </div>

          <!--- Duration Input --->
          <div class="form-group col-md-6 col-sm-12">
            <label for="new_durid">Duration</label>
            <select class="form-control" name="new_durid" autocomplete="off" id="new_durid">
              <cfoutput query="durations">
                <option value="#durations.durid#" <cfif #durations.durid# is "4">selected</cfif>>
                  #durations.durname#
                </option>
              </cfoutput>
            </select>
          </div>

          <!--- Note Input --->
          <div class="form-group col-md-12">
            <label for="noteDetails">Note</label>
            <textarea
              class="form-control"
              id="noteDetails"
              name="noteDetails"
              placeholder="Note to be added to Notes Log"
              rows="4"
            ></textarea>
          </div>

          <!--- Recurring Days Selection --->
          <div class="form-group col-md-12">
            <label for="eventStopTime" class="mb-3 d-block">Recurring every:</label>
            <div id="checkboxes" class="row">
              <cfoutput>
                <cfloop list="Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday" index="day" delimiters=",">
                  <cfset dowValue = ListFind("Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday", day) - 1 />
                  <div class="col-12 col-sm-6 col-lg-5 col-xl-4 mb-2">
                    <input
                      type="checkbox"
                      id="dow#dowValue#"
                      name="dow"
                      value="#dowValue#"
                      autocomplete="off"
                      onchange="showDiv('hidden_div', this)"
                    />
                    <label for="dow#dowValue#">#day#</label>
                  </div>
                </cfloop>
              </cfoutput>
            </div>
          </div>

          <!--- Recurring Until Input --->
          <div class="form-group col-md-6 col-sm-12" id="hidden_div">
            <label for="endRecur">Recurring Until:</label>
            <input class="form-control" id="endRecur" name="endRecur" type="date" />
          </div>
        </div>

        <!--- Submit and Back Buttons --->
        <div class="row mt-4">
          <div class="col-12 d-flex flex-wrap justify-content-between align-items-center gap-2">
            <a href="javascript:history.go(-1)" class="btn btn-secondary btn-sm waves-effect waves-light">
              Back
            </a>
            <button type="submit" class="btn btn-primary btn-sm waves-effect waves-light" id="btn-save-event">
              Add
            </button>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>

<script>
  $(document).ready(function () {
    $(".parsley-examples").parsley();
  });

  function showDiv(divId, element) {
    var checked = document.querySelectorAll('input[name="dow"]:checked');
    var hiddenDiv = document.getElementById(divId);

    if (checked.length === 0) {
      hiddenDiv.style.display = "none";
      document.getElementById("endRecur").value = "";
      $("#endRecur").prop("required", false);
    } else {
      hiddenDiv.style.display = "block";
      $("#endRecur").prop("required", true);
    }
  }

  $('select[name=eventStartTime]').on("change", function () {
    var theSelectedIndex = $(this)[0].selectedIndex;
    $.each($('select[name=eventStopTime] option'), function () {
      var endOptionIndex = $(this).index();
      if (endOptionIndex < theSelectedIndex) {
        $(this).attr("disabled", "disabled");
      } else {
        $(this).removeAttr("disabled").prop("selected", true);
        return false;
      }
    });
  });
</script>

<!--- Include Big Brother Template --->
<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), '\')#" />
<cfinclude template="/include/bigbrotherinclude.cfm" />
