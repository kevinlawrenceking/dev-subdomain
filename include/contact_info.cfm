<!--- This ColdFusion page handles the contact details, including fetching related data, managing modals for updates, and displaying contact information. --->

<cfinclude template="/include/qry/fetchLocationService.cfm" />
<cfparam name="suID" default="7" />
<cfparam name="recid" default="0" />
<cfparam name="t2" default="0" />
<cfset dbugz = "N" />
<cfparam name="t1" default="1" />
<cfparam name="t2" default="0" />
<cfparam name="t3" default="0" />
<cfparam name="t4" default="0" />
<cfparam name="hide_completed" default="N" />
<!--- Check if t1 is not zero and adjust t1 accordingly --->
<cfif #t1# is not "0">
    <cfif t1 + t2 + t3 + t4 eq 2>
        <cfset t1 = 0 />
    </cfif>
</cfif>

<cfif #isdefined('session.mocktoday')# >
<Cfset currentStartDate = "#DateFormat(session.mocktoday,'yyyy-mm-dd')#"/> 
    <cfelse>
<Cfset currentStartDate = "#DateFormat(Now(),'yyyy-mm-dd')#"/>
</cfif>

<cfparam name="contact_expand" default="true" />
<cfparam name="appointments_expand" default="false" />
<cfparam name="notes_expand" default="false" />
<cfparam name="relationship_expand" default="false" />

<cfset contact_expand = "false" />
<cfset appointments_expand = "false" />
<cfset notes_expand = "false" />
<cfset relationship_expand = "false" />

<!--- Save content for debugging purposes --->
<cfsavecontent variable="varcheck">
    <cfoutput>
        T1: #t1#<BR>
        T2: #t2#<BR>
        T3: #t3#<BR>
        T4: #t4#<BR>
    </cfoutput>
</cfsavecontent>

<cfif #dbugz# is "Y">
    <cfoutput>varcheck:#varcheck#<BR></cfoutput>
    <cfoutput>t1:#t1#<BR></cfoutput>
</cfif>

<!--- Determine which sections to expand based on t1, t2, t3, and t4 values --->
<cfif t1 eq 1>
    <cfif #dbugz# is "Y">
        <cfoutput>t1:#t1#<BR></cfoutput>
    </cfif>
    <cfset contact_expand = "true" />
<cfelseif t2 eq 1>
    <cfset appointments_expand = "true" />
<cfelseif t3 eq 1>
    <cfset notes_expand = "true" />
<cfelseif t4 eq 1>
    <cfset relationship_expand = "true" />
</cfif>

<cfif t1 + t2 + t3 + t4 eq 0>
    <cfset t1 = 1 />
</cfif>

<cfsavecontent variable="varif">
    <cfoutput>
        IF: if #t1# is "0" and #t2# is "0" and #t3# is "0" and #t4# is "0"<BR>
    </cfoutput>
</cfsavecontent>

<cfoutput>
    <cfif #t1# is "0" and #t2# is "0" and #t3# is "0" and #t4# is "0">
        <cfset contact_expand = "true" />
    </cfif>
</cfoutput>

<cfsavecontent variable="varafter">
    <cfoutput>
        T1: #t1#<BR>
        T2: #t2#<BR>
        T3: #t3#<BR>
        T4: #t4#<BR>
    </cfoutput>
</cfsavecontent>

<cfif #dbugz# is "Y">
    <cfoutput> varif:#varif#<BR>varafter:#varafter#</cfoutput>
    <cfoutput>
        <p>notes_expand: #notes_expand#</p>
        <p>contact_expand: #contact_expand#</p>
    </cfoutput>
</cfif>

<!--- Handle mobile device redirection based on t2, t3, and t4 values --->
<cfif #devicetype# is "mobile">
    <cfif #t2# is "1">
        <Cflocation url="/app/contact/?contactid=#contactid#&new_pgid=119" />
    </cfif>
    <cfparam name="t3" default="0" />
    <cfif #t3# is "1">
        <Cflocation url="/app/contact/?contactid=#contactid#&new_pgid=118" />
    </cfif>
    <cfparam name="t4" default="0" />
    <cfif #t4# is "1">
        <Cflocation url="/app/contact/?contactid=#contactid#&new_pgid=120" />
    </cfif>
</cfif>

<cfparam name="dbug" default="N" />
<cfparam name="newendlink" default="" />
<cfparam name="contact_expand" default="true" />
<cfparam name="emaillink" default="unknown" />
<cfparam name="newactionlinkURL" default="" />
<cfparam name="updatenoteid" default="0" />
<cfparam name="pgtype" default="add" />
<cfparam name="ctaction" default="view" />
<cfparam name="pfaction" default="view" />
<cfparam name="status_active" default="Y" />
<cfparam name="status_completed" default="N" />
<cfparam name="status_future" default="N" />

<cfset currentid = contactid />
<cfset session.currentpage = "/app/contact/?contactid=#currentid#" />

<!--- Check for cookie values and set status accordingly --->
<cfif isdefined('cookie.status_active')>
    <cfset status_active = cookie.status_active />
</cfif>
<cfif isdefined('cookie.status_completed')>
    <cfset status_completed = cookie.status_completed />
</cfif>
<cfif isdefined('cookie.status_future')>
    <cfset status_future = cookie.status_future />
</cfif>

<cfset rpgid = 36 />
<cfinclude template="/include/qry/details_456_1.cfm" />
<cfinclude template="/include/qry/eventresults.cfm" />
<cfinclude template="/include/qry/ru.cfm" />
<cfinclude template="/include/modalRemoteNewForm.cfm" />
<cfinclude template="/include/qry/contacts_333_1.cfm" />
<cfinclude template="/include/qry/categories_446_1.cfm" />
<cfinclude template="/include/qry/items_488_1.cfm" />
<cfinclude template="/include/qry/notesContact_507_1.cfm" />
<cfinclude template="/include/qry/Systems_540_1.cfm" />
<cfinclude template="/include/qry/TagsContact_541_1.cfm" />
<cfinclude template="/include/qry/profiles_516_1.cfm" />
<cfinclude template="/include/qry/sysActive_537_1.cfm" />
<cfinclude template="/include/qry/notsall_512_1.cfm" />
<cfinclude template="/include/qry/eventss_443_1.cfm" />
<!--- <cfinclude template="/include/qry/systemNotificationsActive.cfm" /> --->
<cfinclude template="/include/qry/findscope.cfm" />
<cfinclude template="/include/qry/sysAvail_539_3.cfm" />
<cfinclude template="/include/qry/getRemindersByRelationship.cfm" />
<cfinclude template="/include/qry/emailcheck_469_1.cfm" />
<cfinclude template="/include/qry/phonecheck_515_1.cfm" />
<!--- <cfinclude template="/include/qry/rels.cfm" /> --->
<cfinclude template="/include/qry/fetchcontactitems.cfm" />
<!--- DIR-LNK-WO-6: the findcompany_476_1.cfm include was removed from THIS page. Its consumer here
      was the item-derived company loop this WO replaced with the primary fields block (which reads
      the contactdetails column), so the query had no remaining reader on the contact page and ran
      once per page load for nothing. The file itself still exists and is still included by
      include/qry/findcompany.cfm:4 - that wrapper appears to have no live consumer of its own, so
      the pair registers to the qry-elimination list as a dead chain, to be verified at elimination
      rather than assumed here. emailcheck / phonecheck above are still consumed by the toolbar
      links and stay. --->
<cfinclude template="/include/qry/notesRelationship_509_1.cfm" />

<cfif #details.contactphoto# is not "">
    <cfset browser_contact_avatar_filename = details.contactphoto />
</cfif>

<cfparam name="status_active_check" default="" />
<cfparam name="status_completed_check" default="" />
<cfparam name="status_future_check" default="" />
<cfparam name="relationship_expand_check" default="" />

<!--- Set status checks based on details --->
<cfif #status_active# is "Y">
    <cfset status_active_check = "checked" />
</cfif>
<cfif #status_completed# is "Y">
    <cfset status_completed_check = "checked" />
</cfif>
<cfif #status_future# is "Y">
    <cfset status_future_check = "checked" />
</cfif>
<cfif #relationship_expand# is "true">
    <cfset relationship_expand_check = "show active" />
</cfif>

<script>
    $(document).ready(function() {
        $("#remoteUpdateSUID0").on("show.bs.modal", function(event) {
            
            $(this).find(".modal-body").load("<cfoutput>/include/remoteUpdateSUID.cfm?suid=0&contactid=#currentid#</cfoutput>");
        });
    });
</script>

<div id="remoteUpdateSUID0" class="modal fade" tabindex="-1" role="dialog" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title">
                    <cfoutput>Relationship System</cfoutput>
                </h4>
                <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
            </div>
            <div class="modal-body"></div>
        </div>
    </div>
</div>

<cfloop query="ru">
    <script>
        $(document).ready(function() {
            $("#remoteUpdate<cfoutput>SUID#ru.suid#</cfoutput>").on("show.bs.modal", function(event) {
                
                $(this).find(".modal-body").load("<cfoutput>/include/remoteUpdateSUID.cfm?suid=#ru.suid#&contactid=#currentid#</cfoutput>");
            });
        });
    </script>

    <div id="remoteUpdate<cfoutput>SUID#ru.suid#</cfoutput>" class="modal fade" tabindex="-1" role="dialog" >

        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title">Update <cfoutput>Relationship System</cfoutput></h4>
                    <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                </div>
                <div class="modal-body"></div>
            </div>
        </div>
    </div>
</cfloop>

<cfinclude template="/include/qry/cu_83_1.cfm" />

<cfloop query="cu">
<script>
    $(document).ready(function() {
        $("#remoteUpdate<cfoutput>C#cu.itemid#</cfoutput>").on("show.bs.modal", function(event) {
            var modal = $(this);
            
            // Load the modal content
            modal.find(".modal-body").load("<cfoutput>/include/remoteupdatec.cfm?userid=#userid#&itemid=#cu.itemid#</cfoutput>", function() {
                // Initialize Parsley.js for the dynamically loaded form
                modal.find("form").parsley();
            });
        });
    });
</script>


    <div id="remoteUpdate<cfoutput>C#cu.itemid#</cfoutput>" class="modal fade" tabindex="-1" role="dialog" >

        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title">
                        Update <cfoutput>#cu.valueCategory# Form</cfoutput>
                    </h4>
                    <button type="button" class="close" data-bs-dismiss="modal" >

                        <i class="mdi mdi-close-thick"></i>
                    </button>
                </div>
                <div class="modal-body"></div>
            </div>
        </div>
    </div>
</cfloop>

<cfloop query="sysactive">
    <cfoutput>
        <div id="action#sysactive.suid#-modal" class="modal fade" tabindex="-1" role="dialog" >

            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title">#sysactive.recordname#</h4>
                        <button type="button" class="close" data-bs-dismiss="modal" >
x</button>
                    </div>
                    <div class="modal-body">
                        <h5>Description</h5>
                        <p>#sysactive.systemdescript#</p>
                        <p><strong>Start Date:</strong> #this.formatDate(sysactive.sustartdate)#</p>
                        <cfif #sysactive.suenddate# is not "">
                            <p><strong>Completed:</strong> #this.formatDate(sysactive.suenddate)#</p>
                        </cfif>
                    </div>
                </div>
            </div>
        </div>

        <script>
            $(document).ready(function() {
                $("##remoteDeleteForm#sysActive.suid#").on("show.bs.modal", function(event) {
                    
                    $(this).find(".modal-body").load("/include/remoteDeleteForm.cfm?recid=#sysActive.suid#&rpgid=40&pgaction=update&contactid=#currentid#&pgdir=contact&t4=1");
                });
            });
        </script>

        <div id="remoteDeleteForm#sysActive.suid#" class="modal fade" tabindex="-1" role="dialog" >

            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title">Follow Up System</h4>
                        <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                    </div>
                    <div class="modal-body"></div>
                </div>
            </div>
        </div>
    </cfoutput>
</cfloop>

<cfinclude template="/include/qry/c_83_2.cfm" />

<cfloop query="c">


    <script>
    $(document).ready(function() {
        $("#remoteAdd<cfoutput>C#c.catid#</cfoutput>").on("show.bs.modal", function(event) {
            $(this).find(".modal-body").load("<cfoutput>/include/remoteAddC.cfm?catid=#c.catid#&userid=#userid#&contactid=#currentid#</cfoutput>", function() {
                // Initialize Parsley.js for the dynamically loaded form
                $(this).find("form").parsley();
            });
        });
    });
</script>

    <div id="remoteAdd<cfoutput>C#c.catid#</cfoutput>" class="modal fade" tabindex="-1" role="dialog" >

        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title">New <cfoutput>#c.valueCategory# Form</cfoutput></h4>
                    <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                </div>
                <div class="modal-body"></div>
            </div>
        </div>
    </div>
</cfloop>

<script>
    $(document).ready(function() {
        $("#remoteUpdateTag").on("show.bs.modal", function(event) {
            
            $(this).find(".modal-body").load("<cfoutput>/include/remoteUpdateTag.cfm?contactid=#currentid#</cfoutput>");
        });
    });
</script>

<div id="remoteUpdateTag" class="modal fade" tabindex="-1" role="dialog" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title">Update Tags</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
            </div>
            <div class="modal-body"></div>
        </div>
    </div>
</div>

<script>
    $(document).ready(function() {
        $("#remoteNewForm").on("show.bs.modal", function(event) {
            
            $(this).find(".modal-body").load("<cfoutput>/include/RemoteNewForm.cfm?rpgid=36&pgid=3&t2=1&pgdir=#pgdir#&contactid=#contactid#</cfoutput>");
        });
    });
</script>

<div id="showmaint" class="modal fade" tabindex="-1" role="dialog" >

    <div class="modal-dialog modal-sm">
        <div class="modal-content modal-filled bg-success">
            <div class="modal-body p-4">
                <div class="text-center">
                    <i class="dripicons-checkmark h1 text-white"></i>
                    <h4 class="mt-2 text-white">Follow-up System Completed!</h4>
                    <p class="mt-3 text-white">
                        <cfoutput>#details.recordname#</cfoutput> has been automatically placed into a maintenance list system.
                    </p>
                    <button type="button" class="btn btn-light my-2" data-bs-dismiss="modal">Continue</button>
                </div>
            </div>
        </div>
    </div>
</div>

<Cfoutput>
    <script>
        $(document).ready(function() {
            $("##remoteDeleteForm#currentid#").on("show.bs.modal", function(event) {
                
                $(this).find(".modal-body").load("/include/remoteDeleteForm.cfm?recid=#currentid#&rpgid=#pgid#&pgaction=update&pgdir=#pgdir#");
            });
        });
    </script>

    <div id="remoteDeleteForm#currentid#" class="modal fade" tabindex="-1" role="dialog" >

        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title">#compname#</h4>
                    <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                </div>
                <div class="modal-body"></div>
            </div>
        </div>
    </div>
</Cfoutput>

<script>
    $(document).ready(function() {
        $("#remoteUpdateName").on("show.bs.modal", function(event) {
            
            $(this).find(".modal-body").load("<cfoutput>/include/remoteUpdateName.cfm?contactid=#currentid#&userid=#userid#</cfoutput>");
        });
    });
</script>

<div id="remoteUpdateName" class="modal fade" tabindex="-1" role="dialog" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title">Contact Details</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
            </div>
            <div class="modal-body"></div>
        </div>
    </div>
</div>

<!--- PERF: Batch-fetch all notification data for active systems in 2 queries instead of 2*N. --->
<!--- The original N+1 pattern ran notsactive_510_1.cfm and notsInactive_510_2.cfm per sysActive row. --->
<cfset suidList = valueList(sysActive.suid)>

<cfif listLen(suidList)>
    <cfset notificationService = request.svc("NotificationService")>
    <cfset allNotsActive = notificationService.SELfunotifications_batch(
        currentid = currentid,
        suidList = suidList,
        userid = userid,
        hide_completed = hide_completed
    )>

    <cfset notificationStatusService = createObject("component", "services.NotificationStatusService")>
    <cfset allNotsInactive = notificationStatusService.SELnotstatuses_batch(
        currentid = currentid,
        suidList = suidList,
        userid = userid
    )>
<cfelse>
    <cfset allNotsActive = queryNew("notID,actionID,userID,suID,notTimeStamp,notStartDate,notEndDate,notStatus,notNotes,systemID,contactID,suTimeStamp,suStartDate,suEndDate,suStatus,suNotes,actionNo,actionDetails,actionTitle,navToURL,actionDaysNo,actionDaysRecurring,actionNotes,actionInfo,actionlinkid,BtnName,ActionLinkURL,endlink,targetlink,ispastdue,checktype,delstart,delend,status_color")>
    <cfset allNotsInactive = queryNew("notID,actionID,userID,suID,notTimeStamp,notStartDate,notEndDate,notStatus,notNotes,systemID,contactID,suTimeStamp,suStartDate,suEndDate,suStatus,suNotes,actionNo,actionDetails,actionTitle,navToURL,actionDaysNo,actionDaysRecurring,actionNotes,actionInfo,actionlinkid,BtnName,ActionLinkURL,endlink,targetlink,ispastdue,checktype,delstart,delend,status_color")>
</cfif>

<cfloop query="sysactive">
    <!--- PERF: Filter batch results by suid using query-of-queries instead of per-iteration DB calls. --->
    <cfquery name="notsActive" dbtype="query">
        SELECT * FROM allNotsActive WHERE suID = <cfqueryparam value="#sysActive.suid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
    <cfquery name="notsInactive" dbtype="query">
        SELECT * FROM allNotsInactive WHERE suID = <cfqueryparam value="#sysActive.suid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
    
    <cfloop query="notsactive">
        <cfoutput>
            <div id="action#notsActive.actionid#-modal" class="modal fade" tabindex="-1" role="dialog" >

                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h4 class="modal-title">#notsActive.actiontitle#</h4>
                            <button type="button" class="close" data-bs-dismiss="modal" >
x</button>
                        </div>
                        <div class="modal-body">
                            <h5>#notsActive.actiondetails#</h5>
                            <p>#notsActive.actionInfo#</p>
                            <cfif #notsActive.actionLinkID# is "2">
                                <cfif #emailcheck.recordcount# is "1">
                                    <cfset emaillink="#emailcheck.email#" />
                                </cfif>
                                <cfset newactionlinkURL="mailto:#emaillink#" />
                            </cfif>
                            <cfif #notsActive.actionLinkID# is "6">
                                <cfset newendlink="#details.contactfullname#" />
                                <cfset newactionlinkURL="#notsactive.ActionLinkURL##newendlink#+acting" />
                            </cfif>
                            <cfif #notsActive.actionLinkID# is not "6" and #notsActive.actionLinkID# is not "2" and #notsActive.actionLinkID# is not "0">
                                <cfset newendlink="#notsactive.endlink#" />
                                <cfset newactionlinkURL="#notsactive.ActionLinkURL#?contactid=#currentid##newendlink#" />
                            </cfif>
                            <p>
                                <center>
                                    <a href="#newActionLinkURL#" target="#notsactive.targetlink#" class="btn btn-xs btn-primary" style="background-color: ##406e8e; border: ##406e8e;">#notsactive.BtnName#</a>
                                </center>
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            <div id="actionconfirm#notsActive.actionid#-modal" class="modal fade" tabindex="-1" role="dialog" >

                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h4 class="modal-title">#notsActive.actiontitle# Completed</h4>
                            <button type="button" class="close" data-bs-dismiss="modal" >
x</button>
                        </div>
                        <div class="modal-body">
                            <center>
                                <h5>Looks like you completed this reminder. Congratulations!</h5>
                            </center>
                            <p>&nbsp;</p>
                    <center>   <h5>Click confirm and we'll close it out and add the next reminder</h5></center> 
<p>&nbsp;</p>
                            <p>
                                <center>

                                    <a href="/include/complete_not.cfm?contactid=#currentid#&systemid=#notsActive.systemID#&userid=#userid#&actionid=#actionid#&status_active=#status_active#&status_completed=#status_completed#&status_future=#status_future#&notid=#notsactive.notid#"   class="btn btn-xs btn-primary" style="background-color: ##406e8e; border: ##406e8e;">Confirm</a>

                                </center>

                            </p>

                        </div>

                    </div>

                </div>

            </div>

        </cfoutput>

    </cfloop>

</cfloop>

<div class="row w-100 m-0 p-0 d-flex">

    <div class="col-md-6 col-sm-6 col-xs-12">

        <div class="card h-100 mb-3" >

            <cfset tool_button = "btn-xl text-secondary px-1" />
            
            <cfoutput>
                                        <script>
                                $(document).ready(function() {
                                    $("##remoteDeleteForm#recid#").on("show.bs.modal", function(event) {
                                        
                                        $(this).find(".modal-body").load("/include/remoteDeleteForm.cfm?recid=#contactid#&rpgid=#3#&pgaction=update&pgdir=#pgdir#");
                                    });
                                });

                            </script>
            
            </cfoutput>

<!--- DIR-LNK-WO-6/UI-4: the blue bar carries the static panel label. The contact NAME moved into
      the card body below the avatar, where it renders at heading scale (UI-4a/b). --->
<h4 class="card-card-header text-center text-white text-nowrap py-0" style="background-color: #406E8E;margin:0!important;padding:15px!important;" >
                    Contact
                </h4>
                <div class="py-1 px-3 flex text-center font-22">

<cfif #emailcheck.recordcount# is "1">

                            <cfoutput>

                                <Cfset email="#emailcheck.email#" />

                                <a href="javascript:;" class="<cfoutput>#tool_button#</cfoutput>" data-bs-toggle="modal" data-bs-target="##emailOptionsModal" title="#email#">
                                    <i class="fe-mail"></i>
                                </a>

                            </cfoutput>

                        </cfif>

                        <cfif #phonecheck.recordcount# is "1">

                            <Cfset phonenumber=phonecheck.phonenumber />

                            <cfinclude template="/include/formatPhoneNumber.cfm" />

                            <cfoutput>

                                <a href="tel:#anchorPhoneNumber#" class="<cfoutput>#tool_button#</cfoutput>" target="_blank" title="Voice Call">

                                    <i class="fe-phone-call"></i>

                                </a>

                            </cfoutput>

                        </cfif>

                        <a href="/app/appoint-add/?returnurl=contact&rcontactid=<cfoutput>#currentid#</cfoutput>" class="<cfoutput>#tool_button#</cfoutput>" title="Add" data-bs-original-title="Add Appointment">

                            <i class="fe-calendar"></i>

                        </a>

</div>

<div class="card-body">

<p class="card-text">

<cfoutput> 
<cfset contact_avatar_filename = "#session.userContactsPath#\#currentid#\avatar.jpg" />

                        </cfoutput>

<!--- DIR-WO-2 (TAO-MCD-P1): master-link control + linked badge (read-only state).
      DIR-LNK-WO-6/UI-5: moved here from below the avatar (UI-5c needs master_image_url before the
      avatar renders) and extended with ONE join - co_locations - for the office address. No new
      query. Column names are not guessed: they come from the live prod capture committed at
      docs/plans/evidence/2026-07-04-wo0b-prod-Q8-Q15-master.txt (captured verbatim 2026-07-04).
        co_contacts  : imdbid varchar(50), image_url varchar(500)
        co_locations : address1/address2/city/state/zip varchar(500), PK colocid --->
<cfquery name="qMasterLink">
    SELECT d.master_co_contact_id, d.master_coid, d.company_location_id,
           d.contactCompany, d.contactCompany_src, d.master_last_sync,
           d.contactPhone, d.contactPhone_src,
           d.contactEmail, d.contactEmail_src, d.contactPhoto_src,
           cc.fullname AS master_person_name, co.coName AS master_company_name,
           cc.imdbid    AS master_imdbid,
           cc.image_url AS master_image_url,
           cl.address1  AS master_office_address1,
           cl.address2  AS master_office_address2,
           cl.city      AS master_office_city,
           cl.state     AS master_office_state,
           cl.zip       AS master_office_zip
    FROM contactdetails d
    LEFT JOIN co_contacts  cc ON cc.id      = d.master_co_contact_id
    LEFT JOIN companies    co ON co.coid    = d.master_coid
    LEFT JOIN co_locations cl ON cl.colocid = d.company_location_id
    WHERE d.contactid = <cfqueryparam value="#currentid#" cfsqltype="CF_SQL_INTEGER">
      AND d.userid    = <cfqueryparam value="#session.userid#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfset masterIsLinked = (qMasterLink.recordCount AND len(trim(qMasterLink.master_co_contact_id)))>

<!--- DIR-LNK-WO-6/UI-6 state predicate (AMENDED per D-23, operator evidence 2026-07-17):
        linked  = master_co_contact_id present (masterIsLinked, above);
        synced  = linked AND the company column is master-sourced (contactCompany_src='master').
      D-23: the old bridge stamps master_last_sync on EVERY linked row unconditionally, so that
      stamp cannot separate a synced primary from a stale-value link - testing it would classify
      every linked contact SYNCED (false provenance). The one true 'master' writer fleet-wide is the
      bridge company-write: it sets contactCompany + _src='master' ONLY when the column was blank,
      and never writes email/phone (those stay _src='user'; WO-4 backfill also left _src='user').
      contactCompany_src='master' is therefore the reliable "the Book actually owns a primary here"
      signal. Company-provenance proxy per D-23 until WO-7 writes full snapshots; revisited WO-7/8. --->
<cfset masterIsSynced = ( masterIsLinked AND qMasterLink.contactCompany_src EQ "master" )>

<!--- UI-5b: co_contacts.imdbid holds an IMDB name id. The "nm" prefix test is the guard: the
      column's exact value shape could not be sampled this session (the read-only DB channel is
      down), so a value that is not an nm-id renders nothing rather than a broken link. --->
<cfset masterImdbUrl = "">
<cfif masterIsLinked AND len(trim(qMasterLink.master_imdbid)) AND left(trim(qMasterLink.master_imdbid), 2) EQ "nm">
    <cfset masterImdbUrl = "https://www.imdb.com/name/" & trim(qMasterLink.master_imdbid) & "/">
</cfif>

<!--- UI-5c: master photo used ONLY as a fallback when the contact has no user photo. Display
      only - nothing is copied or persisted (that is PD-5 / WO-7). The https guard means a
      non-URL value simply falls through to the existing default avatar, and the onerror hook
      covers a URL that exists but refuses hotlinking. --->
<cfset masterPhotoUrl = "">
<cfif masterIsLinked AND len(trim(qMasterLink.master_image_url)) AND left(trim(qMasterLink.master_image_url), 8) EQ "https://">
    <cfset masterPhotoUrl = trim(qMasterLink.master_image_url)>
</cfif>

<!--- DIR-LNK-WO-7 (FLAG-2 / 2b): the photo choice is PROVENANCE-driven, not file-presence-driven.
      When the user adopted the Book's photo (contactPhoto_src='master'), the master image is
      authoritative regardless of any local avatar file - the UI-5c "no user file" fallback is not
      sufficient because the default-silhouette copy in the avatar block flips fileExists() true. --->
<cfset masterPhotoAdopted = ( masterIsLinked AND qMasterLink.contactPhoto_src EQ "master" AND len(masterPhotoUrl) )>

<!--- UI-5a: office address lines, built once. Blank office or blank address renders nothing. --->
<cfset masterOfficeLines = []>
<cfif masterIsLinked AND len(trim(qMasterLink.company_location_id))>
    <cfif len(trim(qMasterLink.master_office_address1))>
        <cfset arrayAppend(masterOfficeLines, trim(qMasterLink.master_office_address1))>
    </cfif>
    <cfif len(trim(qMasterLink.master_office_address2))>
        <cfset arrayAppend(masterOfficeLines, trim(qMasterLink.master_office_address2))>
    </cfif>
    <cfset masterOfficeCity  = trim(qMasterLink.master_office_city)>
    <cfset masterOfficeStZip = trim(trim(qMasterLink.master_office_state) & " " & trim(qMasterLink.master_office_zip))>
    <cfif len(masterOfficeCity) AND len(masterOfficeStZip)>
        <cfset arrayAppend(masterOfficeLines, masterOfficeCity & ", " & masterOfficeStZip)>
    <cfelseif len(masterOfficeCity) OR len(masterOfficeStZip)>
        <cfset arrayAppend(masterOfficeLines, masterOfficeCity & masterOfficeStZip)>
    </cfif>
</cfif>

                        <A class="no-hover-effect" href="/app/image-upload-contact/?contactid=<cfoutput>#contactid#&ref_pgid=3</cfoutput>">

<figure class="tao-avatar-figure">
<cfoutput>

<div class="text-center">

<cfset contact_avatar = session.userContactsUrl & "/" & currentid & "/avatar.jpg">
<cfset default_avatar = application.defaultAvatarUrl>
<cfset avatar_path = session.userContactsPath & "/" & currentid & "/avatar.jpg"> <!--- Physical path --->

<cfif masterPhotoAdopted>
    <!--- DIR-LNK-WO-7 (FLAG-2 / 2b): user adopted the Book's photo -> render the master image even
          when a local avatar file exists. onerror still degrades to the default silhouette. --->
    <img src="#masterPhotoUrl#"
         class="tao-avatar tao-avatar--lg"
         alt="profile-image"
         onerror="this.onerror=null;this.src='#default_avatar#';" />
<cfelseif NOT fileExists(avatar_path)>
    <!--- No user photo. UI-5c: prefer the linked master's IMDB image when there is one, else the
          default silhouette. onerror falls back to the default if the host refuses the hotlink,
          so a blocked image degrades to today's behavior rather than a broken-image icon. --->
    <cfif len(masterPhotoUrl)>
        <img src="#masterPhotoUrl#"
             class="tao-avatar tao-avatar--lg"
             alt="profile-image"
             onerror="this.onerror=null;this.src='#default_avatar#';" />
    <cfelse>
        <img src="#default_avatar#"
             class="tao-avatar tao-avatar--lg"
             alt="profile-image" />
    </cfif>

    <!--- Copy the default avatar to the user's contact folder --->
    <cftry>
        <!--- Ensure the directory exists --->
        <cfif NOT directoryExists(session.userContactsPath & "/" & currentid)>
            <cfdirectory action="create" directory="#session.userContactsPath & "/" & currentid#">
        </cfif>

        <!--- Copy the default avatar to the user's contact directory --->
        <cffile action="copy"
                source="#application.defaultAvatarUrl#"
                destination="#avatar_path#" >

    <cfcatch type="any">
        <!--- Log or handle the error --->
        <cfset application.errorLog = "Failed to copy default avatar: " & cfcatch.message>
    </cfcatch>
    </cftry>
<cfelse>
    <!--- Display the contact's avatar if it exists --->
    <img src="#contact_avatar#?v=#dateformat(now(), 'yyyymmdd')#"
         class="tao-avatar tao-avatar--lg"
         alt="profile-image" />
</cfif>

</div>

</cfoutput>

</figure>

                        </A>

<!--- DIR-LNK-WO-6/UI-4: contact identity. The name renders at heading scale here because the blue
      bar now carries the static "Contact" label; contacttitle follows as a subdued line when the
      contact has one. Both are DISPLAY ONLY - neither is a primary column, neither is
      master-managed, and neither is wired to updatePrimary(). Both come from the details query
      (include/qry/details_456_1.cfm -> ContactService.DETcontactdetails_24624), which already
      selects contactFullName AS fullname and contacttitle; no query was added or widened. --->
<cfoutput>
<div class="text-center mt-2">
    <div class="tao-contact-name">#encodeForHTML(trim(details.fullname))#</div>
    <cfif len(trim(details.contacttitle))>
        <div class="tao-contact-title">#encodeForHTML(trim(details.contacttitle))#</div>
    </cfif>
</div>
</cfoutput>

<!--- DIR-LNK-WO-6: the item-derived company loop that stood here is replaced by the primary
      fields block below. Primaries now render from the contactdetails COLUMNS - the same source
      contacts_ss and the share views read since the WO-5 cutover - so the detail page and the
      lists can no longer disagree. Additional companies/phones/emails remain in the item grid
      (contact_pane.cfm, "Additional information"). --->

<!--- DIR-LNK-WO-6/UI-5: qMasterLink and its derived display vars moved ABOVE the avatar block
      (see the card-body top) - the UI-5c avatar fallback needs master_image_url, and this query
      used to run after the avatar had already rendered. Pure read; the move changes ordering
      only, never behavior. --->


<!--- DIR-LNK-WO-6/UI-6 primary field rows - three render states of one panel.
      SYNCED  : leading muted icon + value + trailing lock; office address under Company; read-only.
      INTERIM : same locked rows showing the current column values ("No X on file" when blank);
                read-only, plus an "Awaiting first sync" pill - but never a "Managed by the Book"
                claim (never assert false provenance on a link that has not synced).
      UNLINKED: same rows with the WO-6 inline pencil editor; a blank field renders an "Add X" link.
      The value source is the contactdetails COLUMN in every state (contactCompany / contactEmail /
      contactPhone), so the row content can never disagree with the lists. The lock / pencil is
      presentation on top of the /ajax/contact/update-primary.cfm enforcement, never the enforcement
      itself: the server rejects a primary write on a linked contact regardless of what renders. --->
<cfoutput>
<div id="primaryFields" class="book-fields mt-2" data-contactid="#currentid#">
    <cfset primaryDefs = [
        { "field"="contactCompany", "icon"="mdi-briefcase-outline", "value"=trim(qMasterLink.contactCompany), "emptyLabel"="No company on file", "addLabel"="Add company", "editTitle"="Edit primary company" },
        { "field"="contactEmail",   "icon"="mdi-email-outline",          "value"=trim(qMasterLink.contactEmail),   "emptyLabel"="No email on file",   "addLabel"="Add email",   "editTitle"="Edit primary email" },
        { "field"="contactPhone",   "icon"="mdi-phone-outline",          "value"=trim(qMasterLink.contactPhone),   "emptyLabel"="No phone on file",   "addLabel"="Add phone",   "editTitle"="Edit primary phone" }
    ]>
    <cfloop array="#primaryDefs#" index="pf">
        <div class="book-field<cfif NOT masterIsLinked> primary-row</cfif>" data-field="#pf.field#">
            <i class="mdi #pf.icon# book-field__icon" aria-hidden="true"></i>
            <div class="book-field__body">
                <cfif masterIsLinked>
                    <span class="primary-value" data-field="#pf.field#"><cfif len(pf.value)>#encodeForHTML(pf.value)#<cfelse><span class="book-field__empty">#pf.emptyLabel#</span></cfif></span>
                    <cfif masterIsSynced AND pf.field EQ "contactCompany" AND arrayLen(masterOfficeLines)>
                        <div class="book-office"><cfloop array="#masterOfficeLines#" index="masterOfficeLine">#encodeForHTML(masterOfficeLine)#<br /></cfloop></div>
                    </cfif>
                <cfelse>
                    <span class="primary-value" data-field="#pf.field#" data-raw="#encodeForHTMLAttribute(pf.value)#" data-empty="#pf.emptyLabel#"><cfif len(pf.value)>#encodeForHTML(pf.value)#</cfif></span>
                </cfif>
            </div>
            <cfif masterIsLinked>
                <i class="mdi mdi-lock-outline book-field__lock" title="<cfif masterIsSynced>Managed by the Book<cfelse>Awaiting first sync</cfif>" aria-hidden="true"></i>
            <cfelse>
                <cfif len(pf.value)>
                    <button type="button" class="btn btn-link btn-sm p-0 primary-edit" data-field="#pf.field#" title="#pf.editTitle#" aria-label="#pf.editTitle#"><i class="mdi mdi-square-edit-outline font-18"></i></button>
                <cfelse>
                    <button type="button" class="btn btn-link btn-sm p-0 primary-edit book-field__add" data-field="#pf.field#">#pf.addLabel#</button>
                </cfif>
            </cfif>
        </div>
    </cfloop>

    <cfif masterIsLinked AND NOT masterIsSynced>
        <div class="book-await mt-2 mb-1"><span class="book-pill">Awaiting first sync</span></div>
    </cfif>

    <div id="primaryMsg" class="small mt-1" style="display:none;"></div>
</div>
</cfoutput>

<!--- DIR-LNK-WO-6 primary inline editor. CSRF is auto-injected by core.cfm on non-GET, per the
      master-link controller below. Rejects are server-authored: whatever the endpoint returns is
      what the user sees; this script never decides whether an edit is allowed. --->
<script>
$(function () {
    var wrap = $("#primaryFields");
    if (!wrap.length) { return; }
    var contactid = wrap.data("contactid");

    function showMsg(text, ok) {
        var m = $("#primaryMsg");
        m.text(text).css("color", ok ? "#3bafda" : "#f1556c").show();
        if (ok) { setTimeout(function () { m.fadeOut(); }, 2000); }
    }

    function render(valSpan, value) {
        valSpan.data("raw", value);
        if (value && value.length) {
            valSpan.text(value);
        } else {
            valSpan.empty().append(
                $('<span class="text-muted font-weight-lighter"></span>').text(valSpan.data("empty") || "")
            );
        }
    }

    wrap.on("click", ".primary-edit", function () {
        var btn = $(this);
        var row = btn.closest(".primary-row");
        var field = btn.data("field");
        if (row.find(".primary-input").length) { return; }

        var valSpan = row.find(".primary-value");
        var editor = $('<div class="primary-editor mt-1"></div>');
        var input = $('<input type="text" class="form-control form-control-sm primary-input">').val(valSpan.data("raw") || "");
        var save = $('<button type="button" class="btn btn-primary btn-sm mt-1">Save</button>');
        var cancel = $('<button type="button" class="btn btn-link btn-sm mt-1">Cancel</button>');

        editor.append(input).append(save).append(cancel);
        valSpan.hide(); btn.hide(); row.append(editor); input.trigger("focus");

        cancel.on("click", function () { editor.remove(); valSpan.show(); btn.show(); });

        save.on("click", function () {
            save.prop("disabled", true);
            $.ajax({
                url: "/ajax/contact/update-primary.cfm",
                method: "POST",
                dataType: "json",
                data: { contactid: contactid, field: field, value: input.val() },
                success: function (d) {
                    if (d && d.success) {
                        render(valSpan, (d.data && typeof d.data.value !== "undefined") ? d.data.value : "");
                        editor.remove(); valSpan.show(); btn.show();
                        showMsg(d.message || "Saved.", true);
                    } else {
                        save.prop("disabled", false);
                        showMsg((d && d.message) ? d.message : "Save failed.", false);
                    }
                },
                error: function () {
                    save.prop("disabled", false);
                    showMsg("Save failed.", false);
                }
            });
        });
    });

    $("#suggestCorrectionLink").on("click", function (e) {
        e.preventDefault();
        showMsg("Correction requests are not available yet.", false);
    });
});
</script>

<!--- DIR-LNK-WO-6/UI-6 consolidated band. Replaces the old managed-by line / blue badge / last-sync
      / Unlink stack (removed from the fields block above and folded into this ONE band). Both the
      linked band (#masterLinkBadge) and the unlinked CTA (#masterLinkForm) stay in the DOM, one
      hidden, so the DIR-WO-2 link / unlink JS below keeps toggling them by id with no change.
      SYNCED  -> gold "In the Book" chip (lit Book mark, glow) + match line + IMDB + "Synced from
                 the Book" stamp + fine print (Suggest a correction / unlink).
      INTERIM -> gray "Linked" chip (flat mark) + match line + IMDB + fine print. NO sync stamp and
                 no "Managed by the Book" claim; the "Awaiting first sync" pill renders with the
                 fields above (never assert false provenance on an unsynced link).
      UNLINKED-> outline "Find in the Book" chip wired to the existing #masterLinkToggle control.
      The Book mark is inlined at each point of use (house pattern); colours inherit from chip ink,
      and only the lit gold mark on this contact panel carries the glow (per UI-6 asset rules). --->
<cfoutput>
<div id="masterLinkWrap" data-contactid="#currentid#">

    <div id="masterLinkBadge" class="book-band" style="#masterIsLinked ? '' : 'display:none;'#">
        <cfif masterIsSynced>
            <span class="book-chip book-chip--gold">
                <svg class="book-mark" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path fill-rule="evenodd" d="M7 3.25h10.25a2.25 2.25 0 0 1 2.25 2.25v13a2.25 2.25 0 0 1-2.25 2.25H7A2.25 2.25 0 0 1 4.75 18.5v-13A2.25 2.25 0 0 1 7 3.25zm1.3 0v17.5h1.35V3.25z"/></svg>
                In the Book
            </span>
        <cfelse>
            <span class="book-chip book-chip--gray">
                <svg class="book-mark" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path fill-rule="evenodd" d="M7 3.25h10.25a2.25 2.25 0 0 1 2.25 2.25v13a2.25 2.25 0 0 1-2.25 2.25H7A2.25 2.25 0 0 1 4.75 18.5v-13A2.25 2.25 0 0 1 7 3.25zm1.3 0v17.5h1.35V3.25z"/></svg>
                Linked
            </span>
        </cfif>

        <div class="book-band__match">
            <span id="masterLinkPerson">#encodeForHTML(qMasterLink.master_person_name)#</span><span id="masterLinkSep"><cfif len(trim(qMasterLink.master_company_name))> &middot; </cfif></span><span id="masterLinkCompany">#encodeForHTML(qMasterLink.master_company_name)#</span>
        </div>

        <cfif len(masterImdbUrl)>
            <div style="margin-top:2px;">
                <a href="#masterImdbUrl#" target="_blank" rel="noopener noreferrer" class="btn btn-link btn-sm p-0" style="font-size:0.75rem;">IMDB</a>
            </div>
        </cfif>

        <cfif masterIsSynced>
            <div class="book-band__sync">Synced from the Book &middot; <span id="masterLinkSync">#len(trim(qMasterLink.master_last_sync)) ? dateTimeFormat(qMasterLink.master_last_sync, 'yyyy-mm-dd HH:nn') : ''#</span></div>
        </cfif>

        <div class="book-band__fine">
            <a href="##" id="suggestCorrectionLink">Suggest a correction</a> &middot; <button type="button" id="masterUnlinkBtn" class="book-unlink">unlink</button>
        </div>
    </div>

    <div id="masterLinkForm" class="book-band" style="#masterIsLinked ? 'display:none;' : ''#">
        <button type="button" id="masterLinkToggle" class="book-chip book-chip--cta">
            <svg class="book-mark" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="4.75" y="3.25" width="14.75" height="17.5" rx="2.25"/><line x1="8.3" y1="3.25" x2="8.3" y2="20.75"/></svg>
            Find in the Book
        </button>
        <div id="masterLinkSearchBox" style="display:none;margin-top:6px;">
            <input type="text" id="masterLinkSearch" class="form-control form-control-sm" placeholder="Search the Book" autocomplete="off" />
            <div id="masterLinkLocBox" style="display:none;margin-top:4px;"></div>
        </div>
    </div>
</div>

<!--- DIR-LNK-WO-7 link-preview modal shell; the body is GET-loaded from master_link_preview.cfm --->
<div class="modal fade" id="masterPreviewModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content" style="overflow:hidden;border-radius:10px;">
            <div id="masterPreviewContent"></div>
        </div>
    </div>
</div>
</cfoutput>

</div>
        </div>

    </div>

<cfoutput>

        <cfset fileExist="#FileExists(browser_contact_avatar_filename)#" />

        <Cfset recid=#currentid# />

        <cfset h5style="font-size:0.875rem;font-weight: 500;text-align:left;margin-bottom:0;" />

    </cfoutput>

    <div class="col-md-6 col-sm-6 col-xs-12">

        <div class="card h-100 mb-3">

<h4 class="card-header text-center text-white text-nowrap py-0 relationship-header">
    Relationship Info
</h4>


<cfoutput>
<p class="pt-3 pr-3 d-flex text-nowrap" style="background-color: ##F9F9F9;">
  <span class="ms-auto pe-3">
    <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteUpdateName" data-bs-placement="top" title="Update Contact" data-bs-original-title="Update Contact">
      <i class="mdi mdi-square-edit-outline"></i>
    </a>
  </span>
</p>


</cfoutput>

<div class="card-body">

<p class="mt-1 mb-0 py-3">

                    <cfloop query="tagscontact">

                        <cfoutput>

                            <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteUpdateTag" data-bs-placement="top" title="Update Tag" data-bs-original-title="Update Tag">#tagscontact.valuetext#</a>

                        </cfoutput>

                    </cfloop>
             
                    <cfif #tagscontact.recordcount# is "0">

                        <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteUpdateTag" data-bs-placement="top" title="Update Tag" data-bs-original-title="Update Tag">Add a Tag</a>

                    </cfif>

                    <cfif #tagscontact.recordcount# is not "0">

                        <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteUpdateTag" data-bs-placement="bottom" title="Update Tag" data-bs-original-title="Update Tag"><small><i class="fe-plus-circle"></i></small></a>

                    </cfif>

                </p>

<p class="mt-1 mb-0 text-muted py-1 font-14">
                            <cfoutput><strong>Gender Pronoun:</strong>    <cfif #details.contactpronoun# is not "">#details.contactpronoun#  
                            </cfif></cfoutput>
                            </p>

<p class="mt-1 mb-0 text-muted py-1 font-14">  

<cfoutput> 
                        <strong>Birthday:</strong>

                        <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteUpdateName" data-bs-placement="top" title="Update Contact" data-bs-original-title="Update Contact">

                            <cfif #details.contactBirthday# is not "">

                                #month(details.contactbirthday)#/#day(details.contactbirthday)#

                            </cfif>

                            <cfif #details.contactBirthday# is "">

                                Add Birthday

                            </cfif>

                        </a>
                    </cfoutput>
                </p>

<cfset meetingdate=#this.formatDate(details.contactmeetingdate)# />

                    <p class="mt-1 mb-0 text-muted py-1 font-14">
                        <cfoutput>

                            <strong>Initial Meeting:</strong>

                            <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteUpdateName" data-bs-placement="top" title="Update Contact" data-bs-original-title="Update Contact">#meetingdate#</a>

                            <cfif #details.contactmeetingloc# is not "">

                                <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteUpdateName" data-bs-placement="top" title="Update Contact" data-bs-original-title="Update Contact">(#details.contactmeetingloc#)</a>

                            </cfif>
                        </cfoutput>
                    </p>

<p class="mt-1 mb-0 text-muted py-1 font-14">

                            <strong>Referred By:</strong> <cfif #details.referdetailsfullname# is not "">  <cfoutput>#details.referdetailsfullname#</cfoutput>  </cfif>
                        </p>

<cfif #details.newsletter_yn# is "Y" or #details.googlealert_yn# is "Y" or #details.socialmedia_yn# is "Y">

                        <p class="mt-1 mb-0 text-muted py-1  font-14">

                            <cfif #details.newsletter_yn# is "Y">

                                <span class="badge badge-outline-blue rounded-pill"> &#10004; Newsletter</span>

                            </cfif>

                            <cfif #details.googlealert_yn# is "Y">

                                <span class="badge badge-outline-blue rounded-pill"> &#10004; Google Alert</span>

                            </cfif>

                            <cfif #details.socialmedia_yn# is "Y">

                                <span class="badge badge-outline-blue rounded-pill"> &#10004; Followed - Social Media</span>

                            </cfif>

                        </p>

                    </cfif>

                    <cfif #profiles.recordcount# is not "0">

                        <p class="mt-1 mb-0 text-muted font-18">

                            <cfloop query="profiles">

                                <cfoutput>

                                    <a href="#profiles.valuetext#" class="text-white font-14 py-1 ps-o me-2   d-inline-block" data-bs- data-bs-placement="top" title="" target="#profiles.valuetext#" data-bs-original-title="#profiles.valuetype#">
<cfif #profiles.typeicon# is "">
                   <img src="#application.retinaIcons14Url#/customlink.png" title="#profiles.valuetext#"  width="32px" />                           

<cfelse>
          <img src="#application.retinaIcons14Url#/#profiles.typeicon#" title="#profiles.valuetext#"  width="32px" />
                                        
                                        </cfif>

</a>

                                </Cfoutput>

                            </cfloop>

                        </p>

                    </cfif>

<cfloop query="inactivecategories">
 
    <cfif #catid# is "0">

                  <div class="flexit">

                      <div class="contact-info-section" style="margin-top: 35px;position: relative;padding-left: 50px;">

                          <cfoutput>

                              <cfif #rels.recordcount# is not "0">

                                  <i class="fe-users font-26" style="position: absolute;left: 0;top: 0;"></i>

                              </cfif>
                              <!--- end if rels.recordcount is not 0 --->

                              <cfif #rels.recordcount# is "0">

                                  <i class="fe-users text-muted font-weight-lighter font-26" style="position: absolute;left: 0;top: 0;"></i>

                              </cfif>
                              <!--- end if rels.recordcount is 0 --->

                          </cfoutput>

                          <cfoutput query="rels">

                              <h5 style="#h5style#">

                                  <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteUpdateSUID#rels.suid#" data-bs-placement="top" title="Relationship System" data-bs-original-title="Relationship System">#rels.SystemType#

</a>

                              </h5>

                              <div class="font-13 text-uppercase mb-1" style="text-align:left;">

                                  #rels.systemscope#

                              </div>

                          </cfoutput>

                          <cfif #rels.recordcount# is "0">

<h5 class="text-muted font-weight-lighter">

                                  <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteUpdateSUID0" data-bs-placement="top" title="Relationship" data-bs-original-title="Relationship ">Add Relationship System

                                  </a>

                              </h5>

                              <div class="font-13 text-uppercase mb-1" style="text-align:left;">

                                  None

                              </div>

</cfif>
                          <!--- end if rels.recordcount is 0 --->

                      </div>

                  </div>

              </cfif>

</cfloop>

</div>
        </div>

    </div>

</div>
<p>&nbsp;</p>

<cfif #devicetype# is "mobile">

    <div class="card mb-3">

        <div class="btn-group py-0 col-md-12">

            <button type="button" class="btn btn-primary btn-lg dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">

                <Cfoutput>#pgname#</Cfoutput>
                <i class="fe-menu"></i>

            </button>
            <div class="dropdown-menu">

                <cfloop query="FindOptions">
                    <cfoutput>
                        <a class="dropdown-item" href="/app/#pgDir#/?contactid=#contactid#&new_pgid=#FindOptions.pgid#">#FindOptions.pgname#</a>
                    </cfoutput>
                </cfloop>

            </div>
        </div> 
<div class="card-body">

            <cfif #pgid# is "117">
                <cfinclude template="/include/contact_pane.cfm" />
            </cfif>

            <cfif #pgid# is "118">
                <cfinclude template="/include/notes_relationship_pane.cfm" />
            </cfif>

            <cfif #pgid# is "119">
                <cfinclude template="/include/appointments_pane.cfm" />
            </cfif>

            <cfif #pgid# is "120">
                <cfinclude template="/include/reminder_pane.cfm" />
            </cfif>

        </div>
    </div>

<cfelse>

<cfif #contact_expand# is "true">
        
            <cfset contact_active = "show active" />
            
        </cfif>

<cfif #contact_expand# is not "true">
        
            <cfset contact_active = "" />
            
        </cfif>
            
        <cfif #appointments_expand# is "true">
        
            <cfset appointments_active = "show active" />
            
        </cfif>

<cfif #appointments_expand# is not "true">
        
            <cfset appointments_active = "" />
            
        </cfif>
            
        <cfif #notes_expand# is "true">
        
            <cfset notes_active = "show active" />
            
        </cfif>

<cfif #notes_expand# is not "true">
        
            <cfset notes_active = "" />
            
        </cfif>

<cfparam name="status_active_check" default="" />

<cfparam name="status_completed_check" default="" />

<cfparam name="status_future_check" default="" />

<cfparam name="relationship_expand_check" default="" />

<cfif #status_active# is "Y">

    <cfset status_active_check="checked" />

</cfif>

<cfif #status_completed# is "Y">

    <cfset status_completed_check="checked" />

</cfif>

<cfif #status_future# is "Y">

    <cfset status_future_check="checked" />

</cfif>

<div class="card mb-3">
    
        <div class="card-body">
     <ul class="nav nav-pills navtab-bg nav-justified p-1" role="tablist">
      <li class="nav-item">

                <a href="#contact" data-bs-toggle="tab" aria-expanded="false" class="nav-link<cfif #contact_expand# is 'true'> active</cfif>">Contact details</a>

            </li>

            <li class="nav-item">

                <cfoutput><a href="##notes" data-bs-toggle="tab" aria-expanded="#notes_expand#" class="nav-link<cfif #notes_expand# is "true"> active</cfif>">Notes

                    <cfif notesContact.recordcount neq 0>

                  

                            (#numberformat(notesContact.recordcount)#)

           

                    </cfif>

                </a></cfoutput>

            </li>

            <li class="nav-item">

                <a href="#appointments" data-bs-toggle="tab" aria-expanded="<cfoutput>#appointments_expand#</cfoutput>" class="nav-link<cfif #appointments_expand# is 'true'> active</cfif>">Appointments

                    <cfif eventresults.recordcount neq 0>

                        

                            <cfoutput>(#numberformat(eventresults.recordcount)#)</cfoutput>


                    </cfif>

                </a>

            </li>

            <li class="nav-item">

                    <a href="#relationship" data-bs-toggle="tab" aria-expanded="<cfoutput>#relationship_expand#</cfoutput>" class="nav-link<cfif #relationship_expand# is 'true'> active</cfif>">Relationship reminders</a>

                </li>
    </ul>

<div class="tab-content">

<div class="tab-pane <Cfoutput>#contact_active#</cfoutput>" id="contact">
              <cfinclude template="/include/contact_pane.cfm" />
                
            </div>
            
            <div class="tab-pane<cfif #notes_expand# is "true"> show active</cfif>" id="notes">
                <cfinclude template="/include/notes_relationship_pane.cfm" />
                
            </div>
            
            <div class="tab-pane <Cfoutput>#appointments_active#</cfoutput>" id="appointments">
                  <cfinclude template="/include/appointments_pane.cfm" />
                
            </div>
            
            <div class="tab-pane <Cfoutput>#relationship_expand_check#</cfoutput>" id="relationship">
                <cfinclude template="/include/reminder_pane.cfm" />
                
            </div>

</div>
    
    </div>

</div>

</cfif>

<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), " \")#" />

<script>
document.addEventListener("DOMContentLoaded", function () {
    // Attach reset handler for modals
    $('.modal').on('hidden.bs.modal', function () {
        var modalForm = $(this).find("form")[0];
        if (modalForm) {
            modalForm.reset(); // Reset all fields
            $(modalForm).parsley().reset(); // Reset Parsley validation state
            $("#hidden_div").hide(); // Hide the custom type div
            $("#special").hide(); // Hide the custom company name div
        }
    });
});
</script>
<script>
    // Reset form and validation state on modal close
    $(document).ready(function () {
        $('.modal').on('hidden.bs.modal', function () {
            var modalForm = $(this).find("form")[0];
            if (modalForm) {
                modalForm.reset();
                $(modalForm).parsley().reset();
                $("#hidden_div").hide(); // Hide custom type div
                $("#special").hide(); // Hide custom company name div
            }
        });

        // Attach toggleCustomField and handleCustomTypeValidation on load
        $("#valueCompany").on("change", function () {
            toggleCustomField(this);
        });

        $("#valueType").on("change", function () {
            handleCustomTypeValidation(this);
        });
    });
</script>

<!--- DIR-WO-2 (TAO-MCD-P1): master-link search / link / unlink. jQuery UI autocomplete
      per include/autocomplete.cfm. CSRF auto-injected by core.cfm on non-GET. No reloads. --->
<script>
$(function () {
    var wrap = $("#masterLinkWrap");
    if (!wrap.length) return;
    var contactid = wrap.data("contactid");

    $("#masterLinkToggle").on("click", function () {
        $("#masterLinkSearchBox").toggle();
        $("#masterLinkSearch").focus();
    });

    // DIR-LNK-WO-7: selecting a master person opens the PREVIEW modal (GET-load, house pattern).
    // The office picker, the diff and the confirm all live in the preview; nothing is written until
    // the user confirms there, and the preview reloads the page on success so the WO-6 panel
    // re-renders in its SYNCED state. Replaces the old direct search -> loadLocations -> link flow.
    function openPreview(masterCoContactId) {
        $("#masterPreviewContent").html('<div class="p-4 text-center text-muted">Loading preview...</div>');
        $("#masterPreviewContent").load(
            "/include/master_link_preview.cfm?contactid=" + encodeURIComponent(contactid)
            + "&masterCoContactId=" + encodeURIComponent(masterCoContactId)
            + "&colocid=0",
            function () { $("#masterPreviewModal").modal("show"); }
        );
    }

    $("#masterLinkSearch").autocomplete({
        minLength: 2,
        source: function (req, resp) {
            $.ajax({
                url: "/ajax/master/search.cfm",
                dataType: "json",
                data: { term: req.term, limit: 10 },
                success: function (d) {
                    var rows = (d && d.data) ? d.data : [];
                    resp($.map(rows, function (it) {
                        var lbl = it.fullname
                            + (it.jobtitle_type ? " - " + it.jobtitle_type : "")
                            + (it.coName ? " (" + it.coName + ")" : "");
                        return { label: lbl, value: it.fullname, item: it };
                    }));
                }
            });
        },
        select: function (e, ui) {
            var it = ui.item.item;
            $("#masterLinkSearch").val(it.fullname);
            openPreview(it.master_co_contact_id);
            return false;
        }
    });

    // Relink (the "Find in the Book" control is also shown from the linked badge's guarded area):
    // any master selection routes through the same preview, which detects the relink server-side.

    $("#masterUnlinkBtn").on("click", function () {
        if (!confirm("Unlink this contact from the Book? Your pre-link values are restored where possible.")) return;
        $.ajax({
            url: "/ajax/master/unlink.cfm",
            method: "POST",
            dataType: "json",
            data: { contactid: contactid },
            success: function (d) {
                if (d && d.success) { window.location.reload(); }
                else { alert((d && d.message) ? d.message : "Unlink failed."); }
            },
            error: function () { alert("Unlink failed."); }
        });
    });
});
</script>

<script>
 $('.modal').on('show.bs.modal', function () {
    var modalId = $(this).attr('id');
    $(`#${modalId} select[name="valueType"]`).off("change").on("change", function () {
        handleCustomTypeValidation(this, modalId);
    });
});
</script>


<script>
document.addEventListener('DOMContentLoaded', function() {
    window.Parsley.addValidator('phone', {
        validateString: function(value) {
            // Simple regex for US phone numbers (e.g., 123-456-7890 or (123) 456-7890)
            const phoneRegex = /^(?:\(?\d{3}\)?[-.\s]?)?\d{3}[-.\s]?\d{4}$/;
            return phoneRegex.test(value);
        },
        messages: {
            en: 'Please enter a valid phone number (e.g., 123-456-7890)',
        }
    });
});
</script>


<script>
document.addEventListener("DOMContentLoaded", function () {
    // Attach reset handler for modals
    $('.modal').on('hidden.bs.modal', function () {
        var modalForm = $(this).find("form")[0];
        if (modalForm) {
            modalForm.reset(); // Reset all fields
            $("#hidden_div").hide(); // Hide the custom type div
            $("#special").hide(); // Hide the custom company name div
        }
    });
});
</script>

<cfif emailcheck.recordcount is "1">
<cfoutput>
<div id="emailOptionsModal" class="modal fade" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h5 class="modal-title">Email #email#</h5>
                <button type="button" class="close" data-bs-dismiss="modal"><i class="mdi mdi-close-thick"></i></button>
            </div>
            <div class="modal-body p-0">
                <div class="list-group list-group-flush">
                    <a href="javascript:;" onclick="window.open('https://mail.google.com/mail/?view=cm&to=#email#&body=%0A%0APowered%20by%20The%20Actors%20Office','_blank'); $('##emailOptionsModal').modal('hide');" class="list-group-item list-group-item-action d-flex align-items-center">
                        <i class="mdi mdi-google font-18 me-2 text-danger"></i> Gmail
                    </a>
                    <a href="javascript:;" onclick="window.open('https://outlook.live.com/mail/0/deeplink/compose?to=#email#&body=%0A%0APowered%20by%20The%20Actors%20Office','_blank'); $('##emailOptionsModal').modal('hide');" class="list-group-item list-group-item-action d-flex align-items-center">
                        <i class="mdi mdi-microsoft-outlook font-18 me-2 text-primary"></i> Outlook
                    </a>
                    <a href="javascript:;" onclick="window.open('https://compose.mail.yahoo.com/?to=#email#&body=%0A%0APowered%20by%20The%20Actors%20Office','_blank'); $('##emailOptionsModal').modal('hide');" class="list-group-item list-group-item-action d-flex align-items-center">
                        <i class="mdi mdi-yahoo font-18 me-2 text-purple"></i> Yahoo Mail
                    </a>
                    <a href="javascript:;" onclick="window.location.href='mailto:#email#?body=%0A%0APowered%20by%20The%20Actors%20Office'; $('##emailOptionsModal').modal('hide');" class="list-group-item list-group-item-action d-flex align-items-center">
                        <i class="fe-mail font-18 me-2 text-secondary"></i> Default Mail App
                    </a>
                    <a href="javascript:;" onclick="navigator.clipboard.writeText('#email#'); $(this).html('<i class=\'mdi mdi-check font-18 me-2 text-success\'></i> Copied!'); setTimeout(function(){ $('##emailOptionsModal').modal('hide'); }, 800);" class="list-group-item list-group-item-action d-flex align-items-center">
                        <i class="mdi mdi-content-copy font-18 me-2 text-muted"></i> Copy Email Address
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
</cfoutput>
</cfif>

<cfinclude template="/include/email_options_modal.cfm" />