<!--- 
================================================================================
CALENDAR SECTION CALENDAR - Calendar Interface and Event Management
================================================================================

Purpose:
This file provides the main calendar interface for the TAO Relationship System.
It handles the display and interaction of appointment and audition functionalities,
including Google Calendar integration and a legend for event types.

TAO System Integration:
- Part of the Calendar/Appointment Management module
- Provides interface for managing appointments and auditions
- Integrates with Google Calendar for external calendar synchronization
- Supports event type customization and legend display

Database Tables:
- eventtypes_user: User's custom event types with colors and names
- events_tbl: Appointment and audition events
- actionusers_tbl: User account information for calendar access

Key Features:
- Add new appointments and auditions
- Google Calendar integration and OAuth authentication
- Event type legend with color coding
- Collapsible legend display
- Modal-based event type management
- Calendar subscription functionality

Dependencies:
- jQuery for modal management and event handling
- Bootstrap for UI components and modal functionality
- FullCalendar for calendar display
- Google OAuth for calendar integration

Modal Components:
- Add Audition modal
- Update Event Type modals (dynamic per event type)
- Add Event Type modal
- Subscription modal

Author: TAO Development Team
Last Updated: 2025
================================================================================
--->

<!--- ============================================================================ --->
<!--- SECTION 1: INITIALIZATION AND PARAMETERS --->
<!--- ============================================================================ --->

<!--- Default parameter values --->
<cfparam name="legendstatus" default="" />
<cfparam name="access_token" default="" />

<!--- ============================================================================ --->
<!--- SECTION 2: JAVASCRIPT INITIALIZATION --->
<!--- ============================================================================ --->

<!--- Initialize audition modal functionality --->
<script>
    $(document).ready(function() {
        <!--- Load the audition modal when triggered --->
        $("#remoteaudadd").on("show.bs.modal", function(event) {
            <!--- Place the returned HTML into the selected element --->
            $(this).find(".modal-body").load("/include/remoteaudadd.cfm?userid=<cfoutput>#userid#</cfoutput>");
        });
    });
</script>

<!--- ============================================================================ --->
<!--- SECTION 3: MODAL DEFINITIONS --->
<!--- ============================================================================ --->

<!--- Add Audition Modal --->
<div id="remoteaudadd" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="standard-modalLabel">Audition Type</h4>
                <button type="button" class="close" data-bs-dismiss="modal">
                    <i class="mdi mdi-close-thick"></i>
                </button>
            </div>
            <div class="modal-body"></div>
        </div>
    </div>
</div>

<!--- ============================================================================ --->
<!--- SECTION 4: MAIN ACTION BUTTONS --->
<!--- ============================================================================ --->

<!--- Main button container with appointment and audition actions --->
<div class="d-flex justify-content-between">
    <!--- Left side: Add appointment and audition buttons --->
    <div>
        <!--- Button to add a new appointment --->
        <a href="/app/appoint-add/?returnurl=calendar-appoint&rcontactid=0">
            <button class="btn btn-xs btn-primary" id="btn-new-event">
                <i class="mdi mdi-plus-circle-outline"></i> Add Appointment
            </button>
        </a>
        
        <!--- Button to add a new audition if the audition module is enabled --->
        <cfif isAuditionModule is "1">
            <a href="" class="btn btn-xs btn-primary" data-bs-remote="true" data-bs-toggle="modal" 
               data-bs-target="#remoteaudadd" data-bs-placement="top" title="Add Audition" 
               data-bs-original-title="Add Audition">
                Add Audition
            </a>
        </cfif>
    </div>
    
    <!--- ============================================================================ --->
    <!--- SECTION 5: CALENDAR INTEGRATION AND UTILITY BUTTONS --->
    <!--- ============================================================================ --->
    
    <!--- Right side: Google Calendar integration and utility buttons --->
    <div>
        <!--- Google Calendar integration (if not already linked) --->
        <cfif access_token is not "223">
            <cfoutput>
                <!--- Google OAuth configuration --->
                <cfset clientId = "764716537559-ncfiag8dl4p05v7c9kcoltss0ou3heki.apps.googleusercontent.com" />
                <cfset redirectUri = URLEncodedFormat("https://app.theactorsoffice.com/oauth/oauth_callback.cfm") />
                <cfset scope = URLEncodedFormat("https://www.googleapis.com/auth/calendar") />
                <cfset authUrl = "https://accounts.google.com/o/oauth2/v2/auth?response_type=code" &
                                "&client_id=#clientId#" &
                                "&redirect_uri=#redirectUri#" &
                                "&scope=#scope#" &
                                "&access_type=offline" &
                                "&include_granted_scopes=true" &
                                "&prompt=consent" /> <!--- prompt=consent forces refresh_token on repeat --->
                
                <!--- Button to link Google account for calendar access --->
                <a href="#authUrl#">
                    <button class="btn btn-xs btn-primary" type="button">
                        <i class="mdi mdi-link"></i> Link Google
                    </button>
                </a>
            </cfoutput>
        </cfif>

        <!--- Button to subscribe to events --->
        <button class="btn btn-xs btn-primary" type="button" data-bs-remote="true" data-bs-toggle="modal" 
                data-bs-target="#subscription" toggle="tooltip" data-bs-placement="top" title="View Link" 
                data-bs-original-title="View Link">
            <i class="mdi mdi-link"></i> Subscribe
        </button>

        <!--- Button to toggle the legend display --->
        <button class="btn btn-xs btn-primary" type="button" data-bs-toggle="collapse" 
                data-bs-target="#collapseExample" aria-expanded="false" aria-controls="collapseExample">
            <i class="mdi mdi-map-legend"></i> Legend
        </button>
    </div>
</div>

<!--- ============================================================================ --->
<!--- SECTION 6: COLLAPSIBLE LEGEND DISPLAY --->
<!--- ============================================================================ --->

<!--- Collapsible legend section for event types --->
<div class="collapse <cfoutput>#legendstatus#</cfoutput>" id="collapseExample" style="margin-top:5px;">
    <div class="card mb-3">
        <div class="card-body">
            <p><strong>Legend</strong></p>
            
            <!--- Event types display with color coding --->
            <div style="margin-left:20px;">
                <!--- Loop through event types for display in the legend --->
                <cfloop query="eventtypes_user">
                    <cfoutput>
                        <span class="fc-event-dot" style="background-color:#eventtypes_user.eventtypecolor#;font-size:14px;"></span> 
                        #eventtypes_user.eventtypename#
                        <span style="font-size:10px;padding-right:25px;min-width:200px;">
                            <!--- Link to update the event type --->
                            <a href="" data-bs-remote="true" data-bs-toggle="modal" 
                               data-bs-target="##updateeventtype_#eventtypes_user.id#" toggle="tooltip" 
                               data-bs-placement="top" title="Update Type" data-bs-original-title="Update Type">
                                <i class="mdi mdi-square-edit-outline"></i>
                            </a>
                        </span>
                    </cfoutput>
                </cfloop>
            </div>
            
            <!--- Add new event type button --->
            <cfoutput>
                <div style="font-size:14px;" class="p-2">
                    <a href="addeventtype.cfm" data-bs-remote="true" data-bs-toggle="modal" 
                       data-bs-target="##addeventtype" toggle="tooltip" data-bs-placement="top" 
                       title="Add Type" data-bs-original-title="Add Type">
                        <button class="btn btn-sm btn-primary" type="button">
                            <i class="mdi mdi-map-legend"></i> Add New
                        </button>
                    </a>
                </div>
            </cfoutput>
        </div>
    </div>
</div>

<!--- ============================================================================ --->
<!--- SECTION 7: CALENDAR CONTAINER --->
<!--- ============================================================================ --->

<!--- Spacing and calendar container --->
<div class="mt-3"></div> 
<div id="calendar"></div>
