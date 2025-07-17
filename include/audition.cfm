<!--- 
===========================================================================================
AUDITION PROJECT DETAILS INTERFACE
===========================================================================================

Purpose: 
- Individual audition project detail view and management interface
- Handles audition status updates and appointment management
- Provides comprehensive project information display with tabbed interface
- Manages audition workflow progression (Audition → Callback → Redirect → Pin/Avail → Booking)

Part of TAO Relationship System:
- Audition Project Management Module
- Status tracking and workflow management
- Appointment scheduling and tracking
- Project details and notes management
- Relationship and materials management

Database Tables/Components:
- audprojects (main project data)
- audroles (role and status information)
- audsteps (workflow steps and status definitions)
- events_tbl (audition appointments and events)
- auditiondetails (appointment details)
- audunions (union information)
- audnetworks (network information)
- audtones (tone/style information)
- audcontracttypes (contract types)
- contactdetails (casting director information)
- AuditionProjectService (project data management)
- AuditionStepService (workflow management)
- EventService (appointment management)

Key Features:
- Dynamic status management with modal confirmations
- Appointment creation and management
- Tabbed interface for different data views
- Project details editing
- Category and location management
- Notes and materials tracking
- Relationship management
- Booking information when applicable

Status Workflow:
- Audition → Callback → Redirect → Pin/Avail → Booking
- Direct booking support for bypassing initial audition

===========================================================================================
--->

<!--- Core includes and parameter definitions --->
<cfinclude template="/include/audition_check.cfm" />

<!--- Page parameters --->
<cfparam name="istab" default="Y" />
<cfparam name="pgaction" default="View" />
<cfparam name="new_iscallback" default="0" />
<cfparam name="new_isredirect" default="0" />
<cfparam name="new_ispin" default="0" />
<cfparam name="new_isbooked" default="0" />

<!--- Query includes --->
<cfinclude template="/include/qry/steps_29_1.cfm" />

<!--- Status confirmation modals --->
<!--- Generate status confirmation and cancellation modals for each step --->
<cfloop query="steps">
    <cfoutput>
        <cfset statusfield="is#steps.stepcss#" />

        <!--- Status confirmation modal --->
        <div id="StatusConfirm#steps.audstepid#" class="modal fade" tabindex="-1" role="dialog">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title">#steps.audstep#</h4>
                        <a href="/include/removestatus.cfm?audprojectid=#audprojectid#&STATUSFIELD=#STATUSFIELD#&new_audroleid=#audroleid#&new_audstepid=#steps.audstepid#">
                            <button type="button" class="close">
                                <i class="mdi mdi-close-thick"></i>
                            </button>
                        </a>
                    </div>
                    <div class="modal-body">
                        <h4>#steps.stepinfo1#</h4>
                        <br>
                        <p>#steps.stepinfo2#</p>

                        <cfif #steps.stepinfo4# is not ""> 
                            <p>#steps.stepinfo4#</p>
                            <center>
                                <p><img src="#application.imagesUrl#/#steps.audstepid#.png" /></p>
                            </center>
                        </cfif>
                        <p>#steps.stepinfo3#</p>

                        <form action="/include/changestatus.cfm">
                            <input type="hidden" value="#audprojectid#" name="audprojectid" />
                            <input type="hidden" value="changestatus" name="pgaction" />
                            <input type="hidden" name="NEW_AUDROLEID" value="#audroleid#" />
                            <input type="hidden" name="new_audstepid" value="#steps.audstepid#" />
                            <input type="submit" class="btn btn-xs btn-primary waves-effect waves-light" value="#steps.stepinfobutton#" />
                            <input type="hidden" name="statusfield" value="#statusfield#" />
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!--- Status cancellation modal --->
        <div id="StatusCancel#steps.audstepid#" class="modal fade" tabindex="-1" role="dialog">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header" style="background-color: red;color:white;">
                        <h4 class="modal-title">Cancel #steps.audstep#</h4>
                        <a href="">
                            <button type="button" value="Cancel" class="close">
                                <i class="mdi mdi-close-thick"></i>
                            </button>
                        </a>
                    </div>
                    <div class="modal-body">
                        <h4>Do you need to cancel your #steps.audstep# status?</h4><br>
                        <form action="/include/changestatus.cfm">
                            <input type="hidden" value="#audprojectid#" name="audprojectid" />
                            <input type="hidden" value="cancel" name="pgaction" />
                            <input type="hidden" name="NEW_AUDROLEID" value="#audroleid#" />
                            <input type="hidden" name="new_audstepid" value="#steps.audstepid#" />
                            <input type="submit" class="btn btn-xs waves-effect waves-light" style="background-color:red;color:white;" value="Yes" />
                            <input type="hidden" name="statusfield" value="#statusfield#" />
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
</cfloop>

<cfinclude template="/include/qry/rolecheck_29_2.cfm" />

<cfparam name="NEW_ISREDIRECT" default="0" />
<cfparam name="NEW_ispin" default="0" />
<cfparam name="NEW_Iscallback" default="0" />
<cfparam name="NEW_ISbooked" default="0" />

<cfset NEW_AUDSUBCATID=projectdetails.AUDSUBCATID />

<cfif #isdefined('recid')#>
    <cfset audprojectid=recid />
</cfif>

<cfif #pgaction# is "change">
    <cfoutput>
        <cfset cookie.istab="#new_istab#" />
    </cfoutput>
    <cfset pgaction="view">
</cfif>

<cfif #isdefined('cookie.istab')#>
    <cfoutput>
        <cfset istab="#cookie.istab#" />
    </cfoutput>
</cfif>

<!--- removing mobile for now <Cfif #detect.ismobile()# is "true"> 
    <cfset istab="Y" />
</Cfif> --->

<cfset new_audcatid=numberformat(projectDetails.audcatid) />
<cfset audcatid=numberformat(projectDetails.audcatid) />
<cfinclude template="/include/qry/audunions_sel.cfm" />
<cfinclude template="/include/qry/audnetworks_user_sel.cfm" />
<cfinclude template="/include/qry/audtones_sel.cfm" />
<cfinclude template="/include/qry/audcontracttypes_sel.cfm" />
<cfinclude template="/include/qry/notesaud.cfm" />

<!--- Loop through events to generate audition details modals. --->
<cfloop query="events">
    <cfinclude template="/include/qry/auditionDetails_29_3.cfm" />
    <cfoutput>
        <div id="auditionDetails_#events.eventid#" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header" >
                        <h4 class="modal-title" id="standard-modalLabel">Appointment Details</h4>
                        <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                    </div>
                    <div class="modal-body">
                        <div class="row" style="margin: auto;">
                            <!--- Open cfif for eventStart --->
                            <cfif auditiondetails.eventStart is not "">
                                <h4 class="px-1 d-flex text-nowrap">
                                    <img src="#application.datesUrl#/#DateFormat(auditiondetails.eventStart, 'mm-dd')#.png" style="max-width:75px;" alt="..." />
                                </h4>
                            </cfif>
                            <div class="col-md-12 p-1"><strong>Time: </strong>#timeformat(auditiondetails.eventStartTime)# 
                                <!--- Open cfif for eventStopTime --->
                                <cfif auditiondetails.eventStopTime is not "">- #timeformat(auditiondetails.eventStopTime)#</cfif>
                            </div>
                            <div class="col-md-12 p-1"><strong> Stage: </strong>#auditiondetails.audstep#</div>
                            <!--- Callback Type --->
                            <cfif auditionDetails.audstepid is "2">
                                <div class="col-md-12 p-1"><strong>Callback Type: </strong>#auditionDetails.callbacktype#</div>
                            </cfif>
                            <!--- Booking Type --->
                            <div class="col-md-12 p-1"><strong> Type: </strong>
                                <button type="button" class="btn btn-xs btn-soft-secondary rounded-pill waves-effect">#auditiondetails.audtype#</button>
                            </div>
                            <cfif auditiondetails.audstepid is "5">
                                <div class="col-md-12 p-1"><strong>Booking Type: </strong>#auditiondetails.audbooktype#</div>
                            </cfif>
                            <!--- Platform --->
                            <cfif auditiondetails.audtype is "online">
                                <div class="col-md-12 p-1"><strong> Platform: </strong>#auditiondetails.audplatform#</div>
                            </cfif>
                            <!--- Coach --->
                            <div class="col-md-12 p-1"><strong> Worked with Coach: </strong>
                                <cfif auditiondetails.workwithcoach is "1">Yes<cfelse>No</cfif>
                            </div>
                            <!--- In-Person Details --->
                            <cfif auditiondetails.audtype is "In Person">
                                <div class="col-md-12 p-1"><strong>Parking Details: </strong>#auditiondetails.parkingdetails#</div>
                                <div class="col-md-12 p-1"><strong> Track Mileage: </strong>
                                    <cfif auditiondetails.trackmileage is "1">Yes<cfelse>No</cfif>
                                </div>
                            </cfif>
                            <!--- Location --->
                            <cfif auditiondetails.islocation is "true">
                                <div class="col-md-12 p-1"><strong>Location: </strong>#auditionDetails.eventLocation# 
                                    <cfif auditionDetails.eventLocation is not "" and auditionDetails.audlocadd1 is not "">, #auditionDetails.audlocadd1#</cfif>
                                    <cfif auditionDetails.audlocadd2 is not "">, #auditionDetails.audlocadd2#</cfif>
                                    <cfif auditionDetails.audcity is not "">, #auditionDetails.audcity#</cfif>
                                    <cfif auditionDetails.regionname is not ""> , #auditionDetails.regionname#</cfif>
                                    <cfif auditionDetails.audzip is not ""> , #auditionDetails.audzip#</cfif>
                                    <cfif auditionDetails.countryname is not "" and auditiondetails.countryname is not "United States">
                                        #auditionDetails.countryname#
                                    </cfif>
                                </div>
                            <cfelse>
                                <!--- Online Zoom --->
                                <cfif auditiondetails.audtype is "online">
                                    <div class="col-md-12 p-1"><strong>Zoom Link: </strong>#auditiondetails.audLocation# </div>
                                </cfif>
                            </cfif>
                        </div>
                    </div>
                </div>
            </div>
        </div>

<script>
            $(document).ready(function() {
                $("##auditionupdate_#events.eventid#").on("show.bs.modal", function(event) {
                    $(this).find(".modal-body").load("/include/remoteaudupdateform.cfm?secid=#secid#&eventid=#events.eventid#&audcatid=#audcatid#&audprojectid=#audprojectid#&rpgid=175&details_pgid=176&pgdir=audition&userid=#userid#&new_userid=#userid#");
                });
            });
        </script>
        <div id="auditionupdate_#events.eventid#" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header" >
                        <h4 class="modal-title" id="standard-modalLabel">Appointment Update</h4>
                        <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                    </div>
                    <div class="modal-body"></div>
                </div>
            </div>
        </div>
    </cfoutput>
</cfloop>

<cfoutput query="projectdetails">
    <script>
        $(document).ready(function() {
            $("##remoteDeleteFormAudproject#projectdetails.audprojectid#").on("show.bs.modal", function(event) {
                
                $(this).find(".modal-body").load("/include/remoteDeleteFormAudproject.cfm?audprojectid=#projectdetails.audprojectid#");
            });
        });
    </script>

    <div id="remoteDeleteFormAudproject#projectdetails.audprojectid#" class="modal fade" tabindex="-1" role="dialog" >

        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header" style="background-color: red;">
                    <h4 class="modal-title">Delete Audition Project</h4>
                    <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                </div>
                <div class="modal-body"></div>
            </div>
        </div>
    </div>
</cfoutput>

<cfloop list="2,3,5" index="new_audstepid" delimiters=",">
    <Cfoutput>
        <cfinclude template="/include/qry/findstep_29_4.cfm" />
        <script>
            $(document).ready(function() {
                $("##auditionadd_#findstep.audstep#").on("show.bs.modal", function(event) {
                    
                    $(this).find(".modal-body").load("/include/remoteaudupdateform.cfm?NEW_AUDSUBCATID=#new_audsubcatid#&audcatid=#audcatid#&pgaction=add&audstepid=#new_audstepid#&secid=#secid#&audprojectid=#audprojectid#&rpgid=184&details_pgid=176&pgdir=audition&userid=#userid#");
                });
            });
        </script>

        <script>
            $(document).ready(function() {
                $("##auditionadd_#findstep.audstep#_cancel").on("show.bs.modal", function(event) {
                    
                    $(this).find(".modal-body").load("/include/remoteaudupdateform_cancel.cfm?NEW_AUDSUBCATID=#new_audsubcatid#&audcatid=#audcatid#&pgaction=add&audstepid=#new_audstepid#&secid=#secid#&audprojectid=#audprojectid#&rpgid=184&details_pgid=176&pgdir=audition&userid=#userid#");
                });
            });
        </script>

        <div id="auditionadd_#findstep.audstep#" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header" >
                        <h4 class="modal-title" id="standard-modalLabel">Appointment Add</h4>
                        <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                    </div>
                    <div class="modal-body"></div>
                </div>
            </div>
        </div>
    </Cfoutput>
</cfloop>

<script>
    $(document).ready(function() {
        $("#catupdate").on("show.bs.modal", function(event) {
            
            $(this).find(".modal-body").load("/include/catupdateform.cfm?AUDPROJECTID=<cfoutput>#audprojectid#</cfoutput>&audcatid=<cfoutput>#projectdetails.audcatid#</cfoutput>&rpgid=184&secid=176&details_pgid=176&pgdir=audition");
        });
    });
</script>

<div id="catupdate" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header" >
                <h4 class="modal-title" id="standard-modalLabel">Category Update</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
            </div>
            <div class="modal-body"></div>
        </div>
    </div>
</div>

<script>
    $(document).ready(function() {
        $("#projectupdate").on("show.bs.modal", function(event) {
            
            $(this).find(".modal-body").load("/include/remote_aud_project_update.cfm?<cfoutput>secid=#secid#</cfoutput>&audprojectid=<cfoutput>#projectdetails.audprojectid#</cfoutput>&rpgid=148&pgdir=audition");
        });
    });
</script>

<div id="projectupdate" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header" >
                <h4 class="modal-title" id="standard-modalLabel">Project Update</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
            </div>
            <div class="modal-body"></div>
        </div>
    </div>
</div>

<script>
    $(document).ready(function() {
        $("#audlocupdate").on("show.bs.modal", function(event) {
            
            $(this).find(".modal-body").load("/include/audlocupdate.cfm?secid=<cfoutput>#secid#</cfoutput>&userid=<cfoutput>#userid#</cfoutput>&audprojectid=<cfoutput>#audprojectid#</cfoutput>");
        });
    });
</script>

<div id="audlocupdate" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header" >
                <h4 class="modal-title" id="standard-modalLabel">Audition Location Update</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
            </div>
            <div class="modal-body"></div>
        </div>
    </div>
</div>

<!--- Status workflow controls --->
<cfparam name="secid" default="176" />

<form action="/include/rolecheck.cfm">
    <cfoutput>
        <input type="hidden" name="audroleid" value="#audroleid#" />
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
        <input type="hidden" name="pgaction" value="switchit" />
    </cfoutput>

    <div class="card h-100 ribbon-box p-1 pb-0 mb-1" style="background-color: #FFFAE8;border-width:thin;border-color:#406E8E;">
        <center>
            <div class="container">
                <div class="row">
                    <cfoutput>
                        <!--- Callback Status --->
                        <div class="form-switch col-md-3 col-sm-6 col-xs-6">
                            <cfif #projectdetails.isdirect# is "0">
                                <cfinclude template="/include/qry/callback_check_29_5.cfm" />
                                <cfif #rolecheck.iscallback# is "1">
                                    <input class="form-check-input form-check-input-callback" type="checkbox" id="new_iscallback" name="new_iscallback" value="1" <cfif #rolecheck.iscallback# is "1"> checked </cfif>
                                    <cfif #callback_check.recordcount# is not "0"> onclick="return false;" <cfelse> data-bs-toggle="modal" data-bs-target="##StatusCancel2" </cfif> />
                                <cfelse>
                                    <input class="form-check-input form-check-input-callback" type="checkbox" data-bs-toggle="modal" data-bs-target="##StatusConfirm2" id="new_iscallback" name="new_iscallback" value="1" <cfif #rolecheck.iscallback# is "1"> checked </cfif>
                                    <cfif #callback_check.recordcount# is not "0"> onclick="return false;" </cfif> />
                                </cfif>
                                <label class="form-check-label" for="new_iscallback">Callback </label>
                                <cfif #rolecheck.iscallback# is "1">
                                    <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##auditionadd_Callback" data-bs-placement="top" title="Add Callback appointment" data-bs-original-title="Add Callback"><i class="fe-plus-circle"></i></a>
                                </cfif>
                            </cfif>
                        </div>

                        <!--- Redirect Status --->
                        <div class="form-switch col-md-3 col-sm-6 col-xs-6">
                            <cfif #projectdetails.isdirect# is "0">
                                <cfinclude template="/include/qry/Redirect_check_29_6.cfm" />
                                <cfif #rolecheck.isRedirect# is "1">
                                    <input class="form-check-input form-check-input-Redirect" type="checkbox" id="new_isRedirect" name="new_isRedirect" value="1" <cfif #rolecheck.isRedirect# is "1"> checked </cfif>
                                    <cfif #Redirect_check.recordcount# is not "0"> onclick="return false;" <cfelse> data-bs-toggle="modal" data-bs-target="##StatusCancel3" </cfif> />
                                <cfelse>
                                    <input class="form-check-input form-check-input-Redirect" type="checkbox" data-bs-toggle="modal" data-bs-target="##StatusConfirm3" id="new_isRedirect" name="new_isRedirect" value="1" <cfif #rolecheck.isRedirect# is "1"> checked </cfif>
                                    <cfif #Redirect_check.recordcount# is not "0"> onclick="return false;" </cfif> />
                                </cfif>
                                <label class="form-check-label" for="new_isRedirect">Redirect </label>
                                <cfif #rolecheck.isRedirect# is "1">
                                    <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##auditionadd_Redirect" data-bs-placement="top" title="Add Redirect appointment" data-bs-original-title="Add Redirect"><i class="fe-plus-circle"></i></a>
                                </cfif>
                            </cfif>
                        </div>

                        <!--- Pin/Avail Status --->
                        <div class="form-switch col-md-3 col-sm-6 col-xs-6">
                            <cfif #projectdetails.isdirect# is "0">
                                <cfinclude template="/include/qry/Pin_check_29_7.cfm" />
                                <cfif #rolecheck.isPin# is "1">
                                    <input class="form-check-input form-check-input-Pin" type="checkbox" id="new_isPin" name="new_isPin" value="1" <cfif #rolecheck.isPin# is "1"> checked </cfif>
                                    <cfif #Pin_check.recordcount# is not "0"> onclick="return false;" <cfelse> data-bs-toggle="modal" data-bs-target="##StatusCancel4" </cfif> />
                                <cfelse>
                                    <input class="form-check-input form-check-input-Pin" type="checkbox" data-bs-toggle="modal" data-bs-target="##StatusConfirm4" id="new_isPin" name="new_isPin" value="1" <cfif #rolecheck.isPin# is "1"> checked </cfif>
                                    <cfif #Pin_check.recordcount# is not "0"> onclick="return false;" </cfif> />
                                </cfif>
                                <label class="form-check-label" for="new_isPin">Pin/Avail </label>
                            </cfif>
                        </div>

                        <!--- Booked Status --->
                        <div class="form-switch col-md-3 col-sm-6 col-xs-6">
                            <cfinclude template="/include/qry/Booked_check_29_8.cfm" />
                            <cfif #Booked_check.recordcount# is not "0"> 
                                <a href="" data-bs-target="##RemoveBook" data-bs-toggle="modal">
                            </cfif>
                            
                            <cfif #rolecheck.isBooked# is "1">
                                <input class="form-check-input form-check-input-Booked" type="checkbox" id="new_isBooked" name="new_isBooked" value="1" <cfif #rolecheck.isBooked# is "1"> checked </cfif>
                                <cfif #Booked_check.recordcount# is not "0"> disabled="disabled" <cfelse> data-bs-toggle="modal" data-bs-target="##StatusCancel5" </cfif> />
                            <cfelse>
                                <input class="form-check-input form-check-input-Booked" type="checkbox" data-bs-toggle="modal" data-bs-target="##StatusConfirm5" id="new_isBooked" name="new_isBooked" value="1" <cfif #rolecheck.isBooked# is "1"> checked </cfif>
                                <cfif #Booked_check.recordcount# is not "0"> onclick="return false;" </cfif> />
                            </cfif>
                            
                            <label class="form-check-label" for="new_isBooked">Booked </label>
                            <cfif #rolecheck.isBooked# is "1">
                                <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##auditionadd_Booking" data-bs-placement="top" title="Add Booked appointment" data-bs-original-title="Add Booked"><i class="fe-plus-circle"></i></a>
                            </cfif>
                            
                            <cfif #Booked_check.recordcount# is not "0"> </a></cfif>
                        </div>
                    </cfoutput>
                </div>
            </div>
        </center>
    </div>
</form>

<div class="row">

<div class="col-md-6 col-xs-6 col-xs-12">

        <div class="card h-100 ribbon-box">

            <cfif #roledetails.isbooked# is "1">

                <div class="ribbon-two ribbon-two-success"><span>Booked</span></div>
            </cfif>

            <Center>

                <h4 class="card-header text-nowrap " style="color:white;background-color: #406E8E;margin:0!important;padding:15px!important;">
                    <cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

Appointments

</cfoutput>

</h4>

</Center>

<div class="card-body">
                
                <cfif #projectdetails.isdirect# is "1">
                    
                           <p>Direct Booking</p> 
                                
                                 <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#auditionadd_Booking" data-bs-placement="top" title="Add Booking  appointment" data-bs-original-title="Add Booking appointment"><i class="fe-plus-circle"></i> Add booking appointment</a>
                </cfif>

<cfif #events.recordcount# is "0">
                        
                        <cfoutput>
                                <script>
            $(document).ready(function() {
                $("##auditionadd_audition").on("show.bs.modal", function(event) {
                    // Place the returned HTML into the selected element
                    $(this).find(".modal-body").load("/include/remoteaudupdateform.cfm?NEW_AUDSUBCATID=#new_audsubcatid#&new_userid=#userid#&audcatid=#audcatid#&pgaction=add&audstepid=1&secid=#secid#&audprojectid=#audprojectid#&rpgid=184&details_pgid=176&pgdir=audition&userid=#userid#");
                });
            });

        </script>

<div id="auditionadd_audition" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header" >
                        <h4 class="modal-title" id="standard-modalLabel">Appointment Add</h4>
                        <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                    </div>
                    <div class="modal-body">

</div>
                </div>

            </div>

        </div>

</cfoutput>        
                        
                        <cfif #projectDetails.isdirect# is "0">
                    
                     <P>You currently have no appointments for this project.</P>   
                        
                        <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#auditionadd_audition" data-bs-placement="top" title="Add Audition  appointment" data-bs-original-title="Add Audition"><i class="fe-plus-circle"></i> Add appointment</a>
                 
                    </cfif>
                   
 <cfelse>
               
                    <table id="basic-datatable" class="table dt-responsive w-100 table-striped" role="grid">

                        <thead>

                            <cfif (events.CurrentRow MOD 2)>

                                <Cfset rowtype="Odd" />

                            </cfif>

                            <cfif NOT (events.CurrentRow MOD 2)>

                                <Cfset rowtype="Even" />

                            </cfif>

                            <tr class="#rowtype#">
                                <th >Action</th>
                                <th>Time</th>

                                <th>Stage</th>
                                <th class="show-xs show-sm hide-md hide-lg show-xl">Type</th>
                  
 
                            </tr>

                        </thead>

                        <tbody>

                            <cfloop query="events">

                                <cfoutput>
        <script>
    $(document).ready(function() {
        $("##remoteUpdateAnswer_#events.eventid#").on("show.bs.modal", function(event) {
            // Place the returned HTML into the selected element
            $(this).find(".modal-body").load("/include/remoteassform.cfm?eventid=#events.eventid#&audprojectid=#audprojectid#");
        });
    });

</script>

<div id="remoteUpdateAnswer_#events.eventid#" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >


            <div class="modal-dialog">

                <div class="modal-content">

                    <div class="modal-header" >

                        <h4 class="modal-title" id="standard-modalLabel"><strong>#events.audstep#: </strong>#this.formatDate(events.eventStart)#: Personal Assessment</h4>

                        <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i>

                        </button>

                    </div>

                    <div class="modal-body">

                    </div>

                </div>

            </div>

        </div>

<script>
                                        $(document).ready(function() {
                                            $("##remoteDeleteAud#events.eventid#").on("show.bs.modal", function(event) {
                                                // Place the returned HTML into the selected element
                                                $(this).find(".modal-body").load("/include/remoteDeleteFormAud.cfm?eventid=#events.eventid#&audprojectid=#audprojectid#&audroleid=#audroleid#&rpgid=175&pgaction=update");
                                            });
                                        });

                                    </script>

                                    <div id="remoteDeleteAud#events.eventid#" class="modal fade" tabindex="-1" role="dialog" >


                                        <div class="modal-dialog">

                                            <div class="modal-content">

                                                <div class="modal-header" style="background-color: red;">

                                                    <h4 class="modal-title">Delete Audition</h4>

                                                    <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>

                                                </div>

                                                <div class="modal-body"></div>

                                            </div>

                                        </div>

                                    </div>

<tr>

                                        <td  class="dt-nowrap">

<a title="Edit" href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##auditionupdate_#events.eventid#">

                                                <i class="mdi mdi-square-edit-outline mr-1 me-2"></i>
                                            </a>

<a title="Delete Audition" href="DeleteModal.cfm?rpgid=175" data-bs-toggle="modal" data-bs-target="##remoteDeleteAud#events.eventid#">

                                                <i class="fe-trash-2 me-2"></i>

                                            </a>
                                            

                                            <cfif events.eventstart lte now()>
 <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteUpdateAnswer_#events.eventid#" toggle="tooltip" data-bs-placement="top" title="Update Assessment" data-bs-original-title="Update Answer">

                                                      <i class="mdi mdi-clipboard-check-outline"></i> 

                                                  </a> 
</cfif>
</td>

<td class="dt-nowrap">
                                            <a title="View Details" href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##auditionDetails_#events.eventid#"> #this.formatDate(events.eventStart)#<BR>#timeformat(events.eventStartTime,'short')#</a>
                                        </td>
                           

                                        <td class="dt-nowrap">   <a title="View Details" href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##auditionDetails_#events.eventid#">#events.audstep#</a></td>

                                        <td  class="dt-nowrap show-xs show-sm hide-md hide-lg show-xl">   <a title="View Details" href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##auditionDetails_#events.eventid#">#events.audtype#</a> <cfif #events.workwithcoach# is "1"><BR>(coached)</cfif>    </td>
                                        


</tr>

</cfoutput>

                            </cfloop>

                        </tbody>

                    </table>

     </cfif>

<cfoutput>

<script>
                                    $(document).ready(function() {
                                        $("##remoteDeleteFormAudproject#audprojectid#").on("show.bs.modal", function(event) {
                                            // Place the returned HTML into the selected element
                                            $(this).find(".modal-body").load("/include/remoteDeleteFormAudproject.cfm?audprojectid=#audprojectid#");
                                        });
                                    });

                                </script>

                                <div id="remoteDeleteFormAudproject#audprojectid#" class="modal fade" tabindex="-1" role="dialog" >


                                    <div class="modal-dialog">

                                        <div class="modal-content">

                                            <div class="modal-header" style="background-color: red;">

                                                <h4 class="modal-title">Delete Audition Project</h4>

                                                <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>

                                            </div>

                                            <div class="modal-body"></div>

                                        </div>

                                    </div>

                                </div>

</cfoutput>
                        </div>

</div>
        </div>

<cfoutput>

        <cfset h5style="font-size:0.875rem;font-weight: 500;text-align:left;margin-bottom:0;" />

    </cfoutput>

    <div class="col-md-6 col-xs-6 col-xs-12">

        <div class="card h-100 mb-3">

<Center>

                <h4 class="card-header text-nowrap" style="color:white;background-color: #406E8E;margin:0!important;padding:15px!important;">
                    <cfoutput>Project Details</cfoutput>
                </h4>

</Center>
            <Cfoutput>
                <div class="card-body">

                    <div class="row" style="margin: auto;">
                        
                       <h4 class="px-1 d-flex text-nowrap">   

<span class="ms-auto"> 
                               
                          <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##projectupdate" data-bs-placement="top" title="Update Project" data-bs-original-title="Update Project">   <i class="mdi mdi-square-edit-outline"></i> </a>

</span>

</h4>

<div class="p-1 d-flex text-nowrap"><strong>Project: </strong> #projectdetails.projName# </div>

<div class="col-md-12 col-lg-12  col-xl-6 p-1 text-nowrap"><strong>Category: </strong><a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##catupdate" data-bs-placement="top" title="Update Category" data-bs-original-title="Update Category">#projectdetails.audCatName# - #projectdetails.audSubCatName#</a></div>

                        <div class="col-md-12 col-lg-12 p-1 text-nowrap"><strong>Casting Director: </strong>#projectdetails.castingfullname#</div>

                        <cfif #audunions_sel.recordcount# is not "0">
                            <div class="col-md-12 col-lg-12 p-1 text-nowrap"><strong>Union Status: </strong>#projectdetails.unionName#</div>
                        </cfif>
                        <cfif #audcontracttypes_sel.recordcount# is not "0">
                            <div class="col-md-12 col-lg-12 p-1 text-nowrap"><strong>Contract Type: </strong>#projectdetails.contracttype#</div>
                        </cfif>

<cfif #audnetworks_user_sel.recordcount# is not "0">
                            <div class="col-md-12 col-lg-12 p-1 text-nowrap"><strong>Network: </strong>#projectdetails.network#</div>
                        </cfif>

<cfif #audtones_user_sel.recordcount# is not "0">
                            <div class="col-md-12 col-lg-12 p-1 text-nowrap"><strong>Style / Format: </strong>#projectdetails.tone#</div>
                        </cfif>

                        <cfif #projectdetails.payrate# is not "">
                            <div class="col-md-12 col-lg-12 p-1 text-nowrap"><strong>Payrate / Session Fee: </strong>#projectdetails.payrate#</div>
                        </cfif>

                        <div class="col-md-12 p-1"><strong>Project Description / Logline: </strong>#projectdetails.projDescription#</div>

</div>

</div>
            </Cfoutput>
        </div>

    </div>

</div>
<!--- Section navigation and content --->
<p>&nbsp;</p>

<cfif #istab# is "N">
    <div class="card mb-3">
        <div class="btn-group col-md-12">
            <button type="button" class="btn btn-primary btn-lg dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                <cfoutput>#sec_det.pgtitle#</cfoutput>
                <i class="fe-menu"></i>
            </button>
            <div class="dropdown-menu">
                <cfloop query="options">
                    <cfoutput>
                        <a class="dropdown-item" href="/app/audition/?audprojectid=#audprojectid#&secid=#options.pgid#">#options.pgtitle#</a>
                    </cfoutput>
                </cfloop>
            </div>
        </div>
        
        <div class="card-body">
            <cfset includeTemplates = {
                "176": "/include/aud_role_pane.cfm",
                "175": "/include/aud_rel_pane.cfm",
                "196": "/include/aud_head_pane.cfm",
                "177": "/include/aud_mat_pane.cfm",
                "178": "/include/aud_notes_pane.cfm",
                "179": "/include/aud_ques_pane.cfm",
                "180": "/include/aud_call_pane.cfm",
                "181": roledetails.isbooked eq "1" ? "/include/aud_book_pane.cfm" : ""
            } />
            
            <cfif structKeyExists(includeTemplates, secid) and len(includeTemplates[secid])>
                <cfinclude template="#includeTemplates[secid]#" />
            </cfif>
        </div>
    </div>
</cfif>

<cfif istab is "Y">
    <!--- Define mappings for active and show active states --->
    <cfset activeStates = {
        "176": {active: "active", showactive: "show active"},
        "175": {active: "active", showactive: "show active"},
        "196": {active: "active", showactive: "show active"},
        "177": {active: "active", showactive: "show active"},
        "178": {active: "active", showactive: "show active"},
        "179": {active: "active", showactive: "show active"},
        "180": {active: "active", showactive: "show active"},
        "181": {active: "active", showactive: "show active"}
    } />

    <!--- Initialize all variables to blank --->
    <cfset role_active = "" />
    <cfset rel_active = "" />
    <cfset head_active = "" />
    <cfset mat_active = "" />
    <cfset notes_active = "" />
    <cfset ques_active = "" />
    <cfset call_active = "" />
    <cfset book_active = "" />

    <cfset role_showactive = "" />
    <cfset rel_showactive = "" />
    <cfset head_showactive = "" />
    <cfset mat_showactive = "" />
    <cfset notes_showactive = "" />
    <cfset ques_showactive = "" />
    <cfset call_showactive = "" />
    <cfset book_showactive = "" />

    <!--- Dynamically assign values based on secid --->
    <cfif structKeyExists(activeStates, secid)>
        <cfset activeKey = activeStates[secid] />
        <cfif secid eq "176">
            <cfset role_active = activeKey.active />
            <cfset role_showactive = activeKey.showactive />
        <cfelseif secid eq "175">
            <cfset rel_active = activeKey.active />
            <cfset rel_showactive = activeKey.showactive />
        <cfelseif secid eq "196">
            <cfset head_active = activeKey.active />
            <cfset head_showactive = activeKey.showactive />
        <cfelseif secid eq "177">
            <cfset mat_active = activeKey.active />
            <cfset mat_showactive = activeKey.showactive />
        <cfelseif secid eq "178">
            <cfset notes_active = activeKey.active />
            <cfset notes_showactive = activeKey.showactive />
        <cfelseif secid eq "179">
            <cfset ques_active = activeKey.active />
            <cfset ques_showactive = activeKey.showactive />
        <cfelseif secid eq "180">
            <cfset call_active = activeKey.active />
            <cfset call_showactive = activeKey.showactive />
        <cfelseif secid eq "181">
            <cfset book_active = activeKey.active />
            <cfset book_showactive = activeKey.showactive />
        </cfif>
    </cfif>
</cfif>

<div class="card mb-3" class="p-3">

        <ul class="nav nav-pills navtab-bg nav-justified p-1" role="tablist">

<li class="nav-item" role="presentation">
                <a href="#role" data-bs-toggle="tab" aria-expanded="true" class="nav-link <Cfoutput>#role_active#</Cfoutput>" role="tab">
                    Role
                </a>
            </li>

            <li class="nav-item" role="presentation">
                <a href="#rel" data-bs-toggle="tab" aria-expanded="false" class="nav-link <Cfoutput>#rel_active#</Cfoutput>" role="tab" tabindex="-1">
                    Relationships
                </a>
            </li>

<li class="nav-item" role="presentation">
                <a href="#head" data-bs-toggle="tab" aria-expanded="false" class="nav-link <Cfoutput>#head_active#</Cfoutput>" tabindex="-1" role="tab">
                    Headshots
                </a>
            </li>

<li class="nav-item" role="presentation">
                <a href="#mat" data-bs-toggle="tab" aria-expanded="false" class="nav-link <Cfoutput>#mat_active#</Cfoutput>" tabindex="-1" role="tab">
                    Materials
                </a>
            </li>

<li class="nav-item" role="presentation">
                <a href="#notes" data-bs-toggle="tab" aria-expanded="false" class="nav-link <Cfoutput>#notes_active#</Cfoutput>" tabindex="-1" role="tab">
                    Notes
                </a>
            </li>

<cfif #roledetails.isbooked# is "1">
                <li class="nav-item" role="presentation">
                    <a href="#book" data-bs-toggle="tab" aria-expanded="false" class="nav-link <Cfoutput>#book_active#</Cfoutput>" tabindex="-1" role="tab">
                        Booking
                    </a>
                </li>

            </cfif>

</ul>

<div class="tab-content p-0">

            <div class="tab-pane <cfoutput>#role_showactive#</cfoutput>" id="role" role="tabpanel">

                <div class="p-3">

                    <cfinclude template="/include/aud_role_pane.cfm" />

                </div>

            </div>

            <div class="tab-pane <cfoutput>#rel_showactive#</cfoutput>" id="rel" role="tabpanel">

                <div class="p-3">

                    <cfinclude template="/include/aud_rel_pane.cfm" />

                </div>

            </div>

<div class="tab-pane <cfoutput>#head_showactive#</cfoutput>" id="head" role="tabpanel">

                <div class="p-3">

                    <cfinclude template="/include/aud_head_pane.cfm" />

                </div>

            </div>

<div class="tab-pane <cfoutput>#mat_showactive#</cfoutput>" id="mat" role="tabpanel">

                <div class="p-3">

                    <cfinclude template="/include/aud_mat_pane.cfm" />

                </div>

            </div>

<div class="tab-pane <cfoutput>#notes_showactive#</cfoutput>" id="notes" role="tabpanel">

                <div class="p-3">

                    <cfinclude template="/include/aud_notes_pane.cfm" />

                </div>

            </div>

            <div class="tab-pane <cfoutput>#call_showactive#</cfoutput>" id="call" role="tabpanel">

                <div class="p-3">

                    <cfinclude template="/include/aud_call_pane.cfm" />

                </div>

            </div>

<div class="tab-pane <cfoutput>#book_showactive#</cfoutput>" id="book" role="tabpanel">

                <div class="p-3">

                    <cfinclude template="/include/aud_book_pane.cfm" />

                </div>

            </div>

</div>

                </div>

<!--- Warning modal for booked status --->
<div id="RemoveBook" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="standard-modalLabel">Warning</h4>
                <button type="button" class="close" data-bs-dismiss="modal">
                    <i class="mdi mdi-close-thick"></i>
                </button>
            </div>
            <div class="modal-body">
                <p>You have to remove any booked appointments you have before you can change the booked status of this audition</p>
            </div>
        </div>
    </div>
</div>

<!--- JavaScript for booked status validation --->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        var bookedCheckbox = document.getElementById('new_isBooked');
        
        bookedCheckbox.addEventListener('click', function(event) {
            var isBooked = <cfoutput>#rolecheck.isBooked#</cfoutput>;
            var bookedCheckRecordCount = <cfoutput>#Booked_check.recordcount#</cfoutput>;
            
            if (isBooked === "1" && bookedCheckRecordCount !== 0 && !this.checked) {
                event.preventDefault(); // Prevent unchecking
                $('#RemoveBook').modal('show'); // Show the modal
            }
        });
    });
</script>