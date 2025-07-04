<!--- This ColdFusion page handles the display and management of event details, including attendees, notes, links, and attachments. --->

<cfinclude template="/include/qry/notesevent.cfm" />

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
    <!--- Initialize selectize for relationship selection --->
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

<cfset session.new_eventid = eventdetails.eventid />

<div class="row">
    <div class="card mb-3 w-100" >
        <div class="card-body">
            <form method="post" action="/include/appoint-update2.cfm" class="parsley-examples" name="event-form" id="form-event" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate>
                <cfoutput>
                    <input type="hidden" name="returnurl" value="#returnurl#" />
                    <input type="hidden" name="rcontactid" value="#rcontactid#" />
                    <input type="hidden" name="eventid" value="#eventdetails.eventid#" />
                    <div class="row">
                        <div class="col-md-12">
                            <a href="/app/appoint-update/?eventid=#session.new_eventid#&returnurl=appoint">
                                <h4>#eventdetails.eventtitle# <i class="mdi mdi-square-edit-outline"></i></h4>
                            </a>
                        </div>

                        <div class="col-md-12">
                            <div class="media-body">
                                <cfoutput>
                                    <cfif #eventdetails.eventstart# is not "">
                                        <i class="fe-calendar"></i> #this.formatDate(eventdetails.eventStart)#<br>
                                    </cfif>
                                    <cfif #eventdetails.eventStartTime# is not "">
                                        <i class="fe-clock"></i> #timeformat(eventdetails.eventStartTime,'short')# 
                                    </cfif>
                                    <cfif #eventdetails.eventStopTime# is not ""> - #timeformat(eventdetails.eventStopTime,'short')# </cfif>
                                    <cfif #eventdetails.eventlocation# is not ""> <br><i class="fe-map-pin"></i> #eventdetails.eventlocation# </cfif>
                          
                                <h4 class="mt-0 mb-0">
                                    <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteUpdateName" data-bs-placement="top" title="Update Contact" data-bs-original-title="Update Contact"></a>
                                </h4>
                                <p class="mt-1 mb-0 text-muted font-16">
                              
                                        <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteUpdateTag" data-bs-placement="top" title="Update Tag" data-bs-original-title="Update Tag">
                                            <span class="badge badge-blue" style="font-size: 12px; font-weight: 500;">#eventdetails.eventtypename#</span>
                                        </a>
                                    </cfoutput>
                                </p>
                            </div>
                        </div>
                        <cfoutput>
                            <cfif #eventdetails.eventDescription# is not "">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <h5>Description</h5>
                                        <p>#eventdetails.eventDescription#</p>
                                    </div>
                                </div>
                            </cfif>
                        </cfoutput>
                    </div>
                </cfoutput>
                <div style="height:12px;">&nbsp;</div>
                <ul class="nav nav-tabs">
                    <cfoutput>
                        <li class="nav-item">
                            <a href="##attendees" data-bs-toggle="tab" aria-expanded="#tab1_expand#" class="nav-link<cfif #tab1_expand# is 'true'> active</cfif>">
                                Attendees
                                <cfif #Attendees.recordcount# is not "0">
                                    <span class="badge badge-primary badge-pill">#Attendees.recordcount#</span>
                                </cfif>
                            </a>
                        </li>
                        <li class="nav-item">
                            <a href="##notes" data-bs-toggle="tab" aria-expanded="#tab2_expand#" class="nav-link<cfif #tab2_expand# is 'true'> active</cfif>">
                                Notes
                                <cfif #NotesEvent.recordcount# is not "0">
                                    <span class="badge badge-primary badge-pill">#NotesEvent.recordcount#</span>
                                </cfif>
                            </a>
                        </li>
               
                    </cfoutput>
                </ul>

                <div class="tab-content">
                    <div class="tab-pane<cfif #tab1_expand# is 'true'> show active</cfif>" id="attendees">
                        <h4>Attendees</h4>
                        <cfset contacts_table = "contacts_attendees" />
                        <cfoutput>
                            <cfset eventid = "#eventdetails.eventid#" />
                        </cfoutput>
                        <cfinclude template="/include/contacts_table_attendees.cfm" />
                    </div>

                    <div class="tab-pane<cfif #tab2_expand# is 'true'> show active</cfif>" id="notes">
                        <h4>Notes</h4>
                        <cfinclude template="/include/notes_event_pane.cfm" />
                    </div>
                    <div class="tab-pane<cfif #tab3_expand# is 'true'> show active</cfif>" id="links">
                        <h4>Links</h4>
                    </div>
                    <div class="tab-pane<cfif #tab4_expand# is 'true'> show active</cfif>" id="attachments">
                        <h4>Attachments</h4>
                    </div>
                </div>

                <cfset script_name_include = "/include/#ListLast(GetCurrentTemplatePath(), " \")#" />
            </form>
        </div>
    </div>
</div>
