<!--- This ColdFusion page handles the event form for creating or updating appointments. --->

<cfparam name="reventid" default="0" />
<cfparam name="rcontactid" default="0" />
<cfinclude template="/include/qry/eventdetails_334_3.cfm" />
<cfinclude template="/include/qry/durations.cfm" />
<cfinclude template="/include/qry/relationships_13_1.cfm" />
<cfinclude template="/include/qry/eventtypes_user_443_2.cfm" />
<cfset current_dur_id = eventdetails.durid />
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const hiddenDiv = document.getElementById("hidden_div");
        const dowValue = "<cfoutput>#eventdetails.dow#</cfoutput>";

        if (dowValue === "") {
            hiddenDiv.style.display = "none";
        } else {
            hiddenDiv.style.display = "block";
        }
    });
</script>

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



<div class="row">
    <div class="col-xl-6 col-lg-8 col-md-12">
        <div class="card mb-3">
            <div class="card-body">
                <form method="post" action="/include/appoint-update2.cfm" class="parsley-examples" name="event-form" id="form-event" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate>
                    <cfoutput>
                        <input type="hidden" name="reventid" value="#reventid#"  />
                        <input type="hidden" name="returnurl" value="#returnurl#"  />
                        <input type="hidden" name="rcontactid" value="#rcontactid#"  />
                        <input type="hidden" name="eventid" value="#eventdetails.eventid#"  />
                        <div class="row">
                            <div class="col-12">
                                <div class="form-group">
                                    <label class="control-label">Title<span class="text-danger">*</span></label>
                                    <input class="form-control" placeholder="Insert Appointment Title" value="#eventdetails.eventtitle#" type="text" name="eventTitle" id="eventTitle" data-parsley-minlength="3" data-parsley-minlength-message="Min length 3 characters" data-parsley-maxlength="200" data-parsley-maxlength-message="Max length 200 characters" data-parsley-required data-parsley-error-message="Title is required" />
                                </div>
                            </div>
                        </cfoutput>

                        <div class="col-lg-12">
                            <div class="form-group mb-3">
                                <label for="select-relationship">Relationships:</label>
                                <select id="select-relationship" name="relationships" multiple required class="demo-default selectize-close-btn w-100" placeholder="Select a Relationship..." value="">
                                    <option value="">Select a Relationship...</option>
                                    <cfloop query="relationships">
                                        <cfinclude template="/include/qry/finde_17_1.cfm" />
                                        <cfif #finde.recordcount# is "1">
                                            <cfset new_select = "selected" />
                                        <cfelse>
                                            <cfset new_select = "" />
                                        </cfif>
                                        <cfoutput>
                                            <option value="#contactid#" #new_select#>#recordname#</option>
                                        </cfoutput>
                                    </cfloop>
                                </select>
                            </div>
                        </div>

                        <cfoutput>
                            <div class="form-group col-md-12">
                                <label for="eventDescription">Description</label>
                                <textarea class="form-control" type="text" autocomplete="off" id="eventDescription" name="eventDescription" placeholder="Description" rows="4">#eventdetails.eventDescription#</textarea>
                                <div class="invalid-feedback">
                                    Please enter a Description.
                                </div>
                            </div>
                            <div class="form-group col-md-12">
                                <label for="eventLocation">Location</label>
                                <input class="form-control" type="text" autocomplete="off" id="eventLocation" value="#eventdetails.eventlocation#" name="eventLocation" placeholder="Location" />
                                <div class="invalid-feedback">
                                    Please enter a Location.
                                </div>
                            </div>
                            <div class="form-group col-md-6">
                                <label for="eventStart">Start Date</label> 

                                <input class="form-control" id="eventStart" autocomplete="off" value="#dateformat(eventdetails.eventstart,'yyyy-MM-dd')#" name="eventStart" type="date" />
                                <div class="invalid-feedback">
                                    Please choose a Start Date.
                                </div>
                            </div>
                        </cfoutput>

                        <div class="form-group col-md-6">
                            <label for="eventTypeName">Type</label>
                            <select class="form-control" name="eventTypeName" autocomplete="off" id="eventTypeName">
                                <cfoutput query="eventtypes_user">
                                    <option value="#eventtypes_user.eventtypename#" <cfif #eventtypes_user.eventtypename# is "#eventdetails.eventtypename#"> selected</cfif> >#eventtypes_user.eventtypename#</option>
                                </cfoutput>
                            </select>
                            <div class="invalid-feedback">
                                Please select a Type.
                            </div>
                        </div>

                        <cfoutput>
                            <div class="form-group col-md-6">
                                <label for="eventStartTime">Start Time</label>
                                <select class="form-control" name="eventStartTime" id="eventStartTime" autocomplete="off" data-parsley-required data-parsley-error-message="Start Time is required">
                                    <option value="">Select a Start Time</option>
                                    <cfloop from="0" to="23" index="hour">
                                        <cfset hourFormatted = right("0" & hour, 2)>
                                        <cfloop from="0" to="3" index="quarter">
                                            <cfset minuteFormatted = right("0" & (quarter * 15), 2)>
                                            <option value="#hourFormatted#:#minuteFormatted#" <cfif #timeformat(eventdetails.eventStartTime,'HH:MM')# is "#hourFormatted#:#minuteFormatted#"> selected </cfif> >#hourFormatted#:#minuteFormatted#</option>
                                        </cfloop>
                                    </cfloop>
                                </select>
                            </div>
                        </cfoutput>

                        <div class="form-group col-md-6">
                            <label for="new_eventStopTime">Duration</label>
                            <select class="form-control" name="new_durid" autocomplete="off" id="new_durid">
                                <cfoutput query="durations">
                                    <option value="#durations.durid#" <cfif #durations.durid# is "#current_dur_id#"> selected </cfif> >#durations.durname#</option>
                                </cfoutput>
                            </select>
                        </div>

                        <cfoutput>
                            <div class="form-group col-md-12">
                                <label for="eventStopTime">Recurring every:</label>
                                <div id="checkboxes">
                                    <input type="checkbox" name="dow" value="1" <cfif #eventdetails.dow# contains "1" >
checked</cfif> onchange="showDiv('hidden_div', this)"> Monday
                                    &nbsp;<input type="checkbox" name="dow" value="2" <cfif #eventdetails.dow# contains "2" >
checked</cfif> onchange="showDiv('hidden_div', this)"> Tuesday
                                    &nbsp;<input type="checkbox" name="dow" value="3" <cfif #eventdetails.dow# contains "3" >
checked</cfif> onchange="showDiv('hidden_div', this)"> Wednesday
                                    &nbsp;<input type="checkbox" name="dow" value="4" <cfif #eventdetails.dow# contains "4" >
checked</cfif> onchange="showDiv('hidden_div', this)"> Thursday
                                    &nbsp;<input type="checkbox" name="dow" value="5" <cfif #eventdetails.dow# contains "5" >
checked</cfif> onchange="showDiv('hidden_div', this)"> Friday
                                    &nbsp;<input type="checkbox" name="dow" value="6" <cfif #eventdetails.dow# contains "6" >
checked</cfif> onchange="showDiv('hidden_div', this)"> Saturday
                                    &nbsp;<input type="checkbox" name="dow" value="0" <cfif #eventdetails.dow# contains "0" >
checked</cfif> onchange="showDiv('hidden_div', this)"> Sunday
                                </div>
                            </div>

                            <cfif #eventdetails.endRecur# is not "">
                                <cfset endRecurDisplay = dateAdd('d', -1, eventdetails.endRecur) />
                            <cfelse>
                                <cfset endRecurDisplay = "" />
                            </cfif>

                            <div class="form-group col-md-6" id="hidden_div">
                                <label for="eventStart">Recurring Until:</label>
                                <input class="form-control" id="endRecur" name="endRecur" value="#dateformat(endRecurDisplay,'YYYY-mm-dd')#" type="date" />
                            </div>
                        </cfoutput>
                    </div>

                    <div class="row mt-2">
                        <div class="col-6">
                            <a href="/include/appoint-delete.cfm?eventid=<cfoutput>#eventid#</cfoutput>">
                                <button type="button" class="btn btn-danger btn-sm" id="btn-delete-event">Delete</button>
                            </a>
                        </div>
                        <div class="col-6 text-right">
                            <a href="javascript:history.go(-1)">
                                <button type="button" class="btn btn-light mr-1 btn-sm" data-bs-dismiss="modal">Back</button>
                            </a>
                            <button type="submit" class="btn btn-primary btn-sm waves-effect waves-light" id="btn-save-event">Update</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    $(document).ready(function() {
        $(".parsley-examples").parsley();
    });
</script>

<script>
    function showDiv(divId, element) {
        // Check if any checkboxes are checked to determine visibility of div
        var checked = document.querySelectorAll('#checkboxes input[type="checkbox"]:checked');
        
        // Show or hide the div based on whether any checkboxes are checked
        if (checked.length === 0) {
            document.getElementById(divId).style.display = 'none';
            // Clear the endRecur field if no day is selected
            document.getElementById('endRecur').value = ""; 
        } else {
            document.getElementById(divId).style.display = 'block';
        }
    }

    // Ensure the hidden_div is displayed if event details already contain a recurring end date
    document.addEventListener("DOMContentLoaded", function() {
        var endRecur = "#endRecurDisplay#";
        if (endRecur !== "") {
            document.getElementById('hidden_div').style.display = 'block';
        }
    });
</script>

<script>
    $('select[name=eventStartTime]').on("change", function() {
        var theSelectedIndex = $(this)[0].selectedIndex;
        $.each($('select[name=eventStopTime] option'), function() {
            var endOptionIndex = $(this).index();
            if (endOptionIndex < theSelectedIndex) {
                $(this).attr('disabled', 'disabled');
            } else {
                $(this).removeAttr('disabled').prop('selected', true);
                return false;
            }
        });
    });
</script>
