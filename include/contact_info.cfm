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

                        <A class="no-hover-effect" href="/app/image-upload-contact/?contactid=<cfoutput>#contactid#&ref_pgid=3</cfoutput>">

<figure class="tao-avatar-figure">
<cfoutput>

<div class="text-center">

<cfset contact_avatar = session.userContactsUrl & "/" & currentid & "/avatar.jpg">
<cfset default_avatar = application.defaultAvatarUrl>
<cfset avatar_path = session.userContactsPath & "/" & currentid & "/avatar.jpg"> <!--- Physical path --->

<cfif NOT fileExists(avatar_path)>
    <!--- Fallback to default avatar if the contact's avatar doesn't exist --->
    <img src="#default_avatar#"
         class="tao-avatar tao-avatar--lg"
         alt="profile-image" />

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

<!--- DIR-WO-2 (TAO-MCD-P1): master-link control + linked badge (read-only state) --->
<cfquery name="qMasterLink">
    SELECT d.master_co_contact_id, d.master_coid, d.company_location_id,
           d.contactCompany, d.contactCompany_src, d.master_last_sync,
           d.contactPhone, d.contactPhone_src,
           d.contactEmail, d.contactEmail_src,
           cc.fullname AS master_person_name, co.coName AS master_company_name
    FROM contactdetails d
    LEFT JOIN co_contacts cc ON cc.id   = d.master_co_contact_id
    LEFT JOIN companies   co ON co.coid = d.master_coid
    WHERE d.contactid = <cfqueryparam value="#currentid#" cfsqltype="CF_SQL_INTEGER">
      AND d.userid    = <cfqueryparam value="#session.userid#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfset masterIsLinked = (qMasterLink.recordCount AND len(trim(qMasterLink.master_co_contact_id)))>

<!--- DIR-LNK-WO-6 primary fields block (spec 13.1 editable / 13.2 read-only).
      Unlinked: the three primaries are user-editable (Q1e) and save to contactdetails_tbl via
      /ajax/contact/update-primary.cfm. Linked: read-only and master-managed (spec 8.1) - the
      edit affordance is not rendered, and the server rejects a primary write regardless (the
      UI state is presentation on top of the enforcement, never the enforcement itself). --->
<cfoutput>
<div id="primaryFields" class="text-center mt-2" data-contactid="#currentid#" style="font-size:0.85rem;">

    <div class="primary-row mb-1" data-field="contactCompany">
        <span class="primary-value" data-field="contactCompany" data-raw="#encodeForHTMLAttribute(trim(qMasterLink.contactCompany))#" data-empty="No company"><cfif len(trim(qMasterLink.contactCompany))>#encodeForHTML(trim(qMasterLink.contactCompany))#<cfelse><span class="text-muted font-weight-lighter">No company</span></cfif></span><cfif NOT masterIsLinked><button type="button" class="btn btn-link btn-sm p-0 ms-1 primary-edit" data-field="contactCompany" title="Edit primary company" aria-label="Edit primary company"><i class="mdi mdi-square-edit-outline font-18"></i></button></cfif>
    </div>

    <div class="primary-row mb-1" data-field="contactEmail">
        <span class="primary-value" data-field="contactEmail" data-raw="#encodeForHTMLAttribute(trim(qMasterLink.contactEmail))#" data-empty="No email"><cfif len(trim(qMasterLink.contactEmail))>#encodeForHTML(trim(qMasterLink.contactEmail))#<cfelse><span class="text-muted font-weight-lighter">No email</span></cfif></span><cfif NOT masterIsLinked><button type="button" class="btn btn-link btn-sm p-0 ms-1 primary-edit" data-field="contactEmail" title="Edit primary email" aria-label="Edit primary email"><i class="mdi mdi-square-edit-outline font-18"></i></button></cfif>
    </div>

    <div class="primary-row mb-1" data-field="contactPhone">
        <span class="primary-value" data-field="contactPhone" data-raw="#encodeForHTMLAttribute(trim(qMasterLink.contactPhone))#" data-empty="No phone"><cfif len(trim(qMasterLink.contactPhone))>#encodeForHTML(trim(qMasterLink.contactPhone))#<cfelse><span class="text-muted font-weight-lighter">No phone</span></cfif></span><cfif NOT masterIsLinked><button type="button" class="btn btn-link btn-sm p-0 ms-1 primary-edit" data-field="contactPhone" title="Edit primary phone" aria-label="Edit primary phone"><i class="mdi mdi-square-edit-outline font-18"></i></button></cfif>
    </div>

    <cfif masterIsLinked>
        <div class="text-muted" style="font-size:0.72rem;">Managed by the TAO Master Directory</div>
        <a href="##" id="suggestCorrectionLink" class="btn btn-link btn-sm p-0" style="font-size:0.72rem;">Suggest a correction</a>
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

<cfoutput>
<div id="masterLinkWrap" class="text-center mt-2" data-contactid="#currentid#" style="font-size:0.8rem;">
    <div id="masterLinkBadge" style="#masterIsLinked ? '' : 'display:none;'#">
        <span class="badge badge-blue">Linked to directory</span>
        <!--- UI-4c: the matched person and company are the content here; the badge and the Unlink
              control are chrome. They were rendering at or below the chrome's size, which inverted
              the hierarchy. The data now leads at 0.95rem; last sync stays deliberately small. --->
        <div class="text-muted" style="margin-top:2px;font-size:0.95rem;">
            <span id="masterLinkPerson">#encodeForHTML(qMasterLink.master_person_name)#</span><span id="masterLinkSep"><cfif len(trim(qMasterLink.master_company_name))> &middot; </cfif></span><span id="masterLinkCompany">#encodeForHTML(qMasterLink.master_company_name)#</span>
        </div>
        <div class="text-muted" style="font-size:0.72rem;">
            last sync: <span id="masterLinkSync">#len(trim(qMasterLink.master_last_sync)) ? dateTimeFormat(qMasterLink.master_last_sync, 'yyyy-mm-dd HH:nn') : ''#</span>
        </div>
        <button type="button" id="masterUnlinkBtn" class="btn btn-link btn-sm p-0" style="font-size:0.75rem;">Unlink</button>
    </div>
    <div id="masterLinkForm" style="#masterIsLinked ? 'display:none;' : ''#">
        <button type="button" id="masterLinkToggle" class="btn btn-link btn-sm p-0" style="font-size:0.75rem;">Link to directory</button>
        <div id="masterLinkSearchBox" style="display:none;margin-top:4px;">
            <input type="text" id="masterLinkSearch" class="form-control form-control-sm" placeholder="Search industry people" autocomplete="off" />
            <div id="masterLinkLocBox" style="display:none;margin-top:4px;"></div>
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
    var selected = { masterCoContactId: null, coid: null, coName: null, colocid: null, fullname: null };

    $("#masterLinkToggle").on("click", function () {
        $("#masterLinkSearchBox").toggle();
        $("#masterLinkSearch").focus();
    });

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
            selected = {
                masterCoContactId: it.master_co_contact_id,
                coid: it.coid,
                coName: it.coName,
                colocid: null,
                fullname: it.fullname
            };
            $("#masterLinkSearch").val(it.fullname);
            loadLocations(it.coid);
            return false;
        }
    });

    function loadLocations(coid) {
        var box = $("#masterLinkLocBox");
        box.hide().empty();
        if (!coid || coid <= 0) { doLink(); return; }
        $.ajax({
            url: "/ajax/master/locations.cfm",
            dataType: "json",
            data: { coid: coid },
            success: function (d) {
                var locs = (d && d.data) ? d.data : [];
                if (locs.length === 0) { selected.colocid = null; doLink(); }
                else if (locs.length === 1) { selected.colocid = locs[0].colocid; doLink(); }
                else {
                    var sel = $('<select class="form-control form-control-sm"></select>');
                    sel.append('<option value="">Choose office...</option>');
                    $.each(locs, function (i, l) {
                        var parts = [];
                        if (l.location) parts.push(l.location);
                        if (l.city) parts.push(l.city);
                        if (l.state) parts.push(l.state);
                        var t = parts.join(", ");
                        sel.append($("<option></option>").val(l.colocid).text(t || ("office " + l.colocid)));
                    });
                    var go = $('<button type="button" class="btn btn-primary btn-sm mt-1">Link</button>');
                    go.on("click", function () { selected.colocid = sel.val() || null; doLink(); });
                    box.append(sel).append("<br>").append(go).show();
                }
            }
        });
    }

    function doLink() {
        $.ajax({
            url: "/ajax/master/link.cfm",
            method: "POST",
            dataType: "json",
            data: {
                contactid: contactid,
                masterCoContactId: selected.masterCoContactId,
                coid: selected.coid || 0,
                colocid: selected.colocid || 0
            },
            success: function (d) {
                if (d && d.success) {
                    $("#masterLinkPerson").text(selected.fullname || "");
                    if (selected.coName) {
                        $("#masterLinkSep").html(" &middot; ");
                        $("#masterLinkCompany").text(selected.coName);
                    } else {
                        $("#masterLinkSep").html("");
                        $("#masterLinkCompany").text("");
                    }
                    var now = new Date();
                    var pad = function (n) { return (n < 10 ? "0" : "") + n; };
                    $("#masterLinkSync").text(now.getFullYear() + "-" + pad(now.getMonth() + 1) + "-" + pad(now.getDate())
                        + " " + pad(now.getHours()) + ":" + pad(now.getMinutes()));
                    $("#masterLinkForm").hide();
                    $("#masterLinkSearchBox").hide();
                    $("#masterLinkLocBox").hide().empty();
                    $("#masterLinkSearch").val("");
                    $("#masterLinkBadge").show();
                } else {
                    alert((d && d.message) ? d.message : "Link failed.");
                }
            },
            error: function () { alert("Link failed."); }
        });
    }

    $("#masterUnlinkBtn").on("click", function () {
        if (!confirm("Unlink this contact from the directory?")) return;
        $.ajax({
            url: "/ajax/master/unlink.cfm",
            method: "POST",
            dataType: "json",
            data: { contactid: contactid },
            success: function (d) {
                if (d && d.success) {
                    $("#masterLinkBadge").hide();
                    $("#masterLinkForm").show();
                    $("#masterLinkSearchBox").hide();
                } else {
                    alert((d && d.message) ? d.message : "Unlink failed.");
                }
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