<!--- This ColdFusion page displays event details, including attendees and notes, and manages tab expansion for better user experience. --->

<cfparam name="eventid" default="0" /> <!--- Set default value for event ID --->
<cfparam name="updatenoteid" default="0" /> <!--- Set default value for update note ID --->

<cfinclude template="/include/qry/eventdetails_334_3.cfm" />
<cfinclude template="/include/qry/notesEvent_508_1.cfm" /> <!--- Include template for event notes --->

<cfinclude template="/include/qry/attendees_336_5.cfm" />
<cfinclude template="/include/qry/notesContactDetails_180_2.cfm" /> <!--- Include template for contact details --->

<cfparam name="rcontactid" default="0" />
<cfparam name="returnurl" default="0" />
<cfparam name="tab1_expand" default="false" />
<cfparam name="tab2_expand" default="false" />
<cfparam name="tab3_expand" default="false" />
<cfparam name="tab4_expand" default="false" />
<cfparam name="tab5_expand" default="false" />
<cfparam name="tab6_expand" default="false" />
<cfparam name="tab7_expand" default="false" />
<cfset returnurl = "appoint" />

<!--- Check if all tabs are collapsed and expand the first tab if true --->
<cfif #tab1_expand# is "false" and
      #tab2_expand# is "false" and
      #tab3_expand# is "false" and
      #tab4_expand# is "false" and
      #tab5_expand# is "false" and
      #tab6_expand# is "false" and
      #tab7_expand# is "false">
    <cfset tab1_expand = "true" />
</cfif>

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

<cfset session.new_eventid = eventdetails.eventid />

<div class="row">
    <div class="col-md-3 col-sm-6 col-xs-12">
        <div class="card h-100 mb-3">
            <center>
                <h4 class="text-center text-white text-nowrap py-0" style="color:white;background-color: #406E8E;margin:0!important;padding:15px!important;">
                    <cfoutput>
                        <cfif #eventdetails.eventstart# is not "">
                            <a href="/app/appoint-update/?eventid=#session.new_eventid#&returnurl=appoint" style="color:white;">
                                <i class="fe-calendar"></i> #this.formatDate(eventdetails.eventStart)#
                            </a>
                        </cfif>
                    </cfoutput>
                </h4>
            </center>
            <div class="card-body">
                <cfoutput>
                    <div class="py-0 px-2 flex text-center font-18">
                        <a href="/app/appoint-update/?eventid=#session.new_eventid#&returnurl=appoint" title="Edit Appointment" data-bs-original-title="Edit Appointment">
                            <i class="mdi mdi-square-edit-outline"></i>
                        </a>
                    </div>
                </cfoutput>
                <p class="card-text">
                    <cfoutput>
                        <cfif #eventdetails.eventStartTime# is not "">
                            <i class="fe-clock"></i> #timeformat(eventdetails.eventStartTime,'short')#
                        </cfif>
                        <cfif #eventdetails.eventStopTime# is not "">
                            - #timeformat(eventdetails.eventStopTime,'short')#
                        </cfif>
                        <cfif #eventdetails.eventlocation# is not "">
                            <br><i class="fe-map-pin"></i> #eventdetails.eventlocation#
                        </cfif>
               
                </p>
                <p class="mt-1 mb-0 text-muted font-16">
                    <a href="/app/appoint-update/?eventid=#session.new_eventid#&returnurl=appoint" title="Update Tag" data-bs-original-title="Edit Appointment">
                        <span class="badge badge-blue" style="font-size: 12px; font-weight: 500;">#eventdetails.eventtypename#</span>
                    </a>
                </p>
            </div>
        </div>
    </div>

    <cfset h5style = "font-size:0.875rem;font-weight: 500;text-align:left;margin-bottom:0;" />
 
    <div class="col-md-9 col-sm-6 col-xs-12">
        <div class="card h-100 mb-3">
            <div class="card-body">
                <h4 class="text-nowrap"> 
                    #eventdetails.eventtitle#
                </h4>
                <p>#eventdetails.eventDescription#</p>
            </div>
        </div>
    </div>
</div>
</cfoutput>
<p>&nbsp;</p>
<p>&nbsp;</p>

<div class="card mb-3">
    <cfoutput>
        <div class="card mb-3" class="p-3">
            <ul class="nav nav-pills navtab-bg nav-justified p-1" role="tablist">
                <li class="nav-item" role="presentation">
                    <a href="##role" data-bs-toggle="tab" aria-expanded="#tab1_expand#" class="nav-link <cfif #tab1_expand# is 'true'> active</cfif>" role="tab">
                        Attendees <cfif #attendeesCount# is not "0"> (#attendeesCount#)</cfif> 
                    </a>
                </li>
                <li class="nav-item" role="presentation">
                    <a href="##rel" data-bs-toggle="tab" aria-expanded="#tab2_expand#" class="nav-link <cfif #tab2_expand# is 'true'> active</cfif>" role="tab" tabindex="-1">
                        Notes <cfif #NotesEvent.recordcount# is not "0"> (#NotesEvent.recordcount#)</cfif>
                    </a>
                </li>
            </ul>
        </div>
    </cfoutput>
    <div class="tab-content p-0">
        <div class="tab-pane <cfif #tab1_expand# is 'true'> active</cfif>" id="role" role="tabpanel">
            <div class="p-3">
                <cfinclude template="/include/eventcontacts_pane.cfm" />
            </div>
        </div>
        <div class="tab-pane <cfif #tab2_expand# is 'true'> active</cfif>" id="rel" role="tabpanel">
            <div class="p-3">
                <cfinclude template="/include/eventnotes_pane.cfm" />
            </div>
        </div>
    </div>
</div>

<cfset script_name_include = "/include/#ListLast(GetCurrentTemplatePath(), " \")#" />
