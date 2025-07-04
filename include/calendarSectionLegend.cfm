<!--- This ColdFusion page displays appointment types and provides a link to subscribe to a calendar. --->
<div class="m-t-5">
    <br>
    <h5>Appointment Types</h5>
    <div class="p-2">
        <!--- Loop through the event types for the user --->
        <cfloop query="eventtypes_user">
            <cfoutput>
                <div style="font-size:14px;" class="p-1 text-nowrap"> 
                    <span class="fc-event-dot" style="background-color:#eventtypes_user.eventtypecolor#;font-size:14px;"> </span> 
                    #eventtypes_user.eventtypename# 
                    <span style="font-size:10px;">
                        <a href="updateeventtype_#eventtypes_user.id#.cfm" 
                           data-bs-remote="true" 
                           data-bs-toggle="modal" 
                           data-bs-target="##updateeventtype_#eventtypes_user.id#" 
                           toggle="tooltip" 
                           data-bs-placement="top" 
                           title="Update Type" 
                           data-bs-original-title="Update Type">
                            <i class="mdi mdi-square-edit-outline"></i>
                        </a> 
                    </span>
                </div>
            </cfoutput>
        </cfloop>
        <!--- Link to add a new event type --->
        <cfoutput>
            <div style="font-size:14px;" class="p-1">
                <a href="addeventtype.cfm" 
                   data-bs-remote="true" 
                   data-bs-toggle="modal" 
                   data-bs-target="##addeventtype" 
                   toggle="tooltip" 
                   data-bs-placement="top" 
                   title="Add Type" 
                   data-bs-original-title="Add Type">
                    <i class="mdi mdi-plus-circle-outline"></i> Add New
                </a>
            </div>
        </cfoutput>
    </div>
</div>
<h5 class="text">Calendar Link</h5>
<p class="text-muted mb-1 pl-2">
    You can use the link below to subscribe to your calendar from iCal, Google Calendar or Outlook.
</p>
<center>
    <p>
        <!--- Button to view the subscription link --->
        <a href="subscripotion" 
           data-bs-remote="true" 
           data-bs-toggle="modal" 
           data-bs-target="#subscription" 
           toggle="tooltip" 
           data-bs-placement="top" 
           title="View Link" 
           data-bs-original-title="View Link">
            <button class="btn btn-sm btn-primary"> 
                <i class="mdi mdi-file-link-outline"></i> View Link
            </button>
        </a>
    </p>
</center>
