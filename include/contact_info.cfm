<!---
    PURPOSE: Contact information page with tabbed interface for contact details, notes, appointments, and reminders
    AUTHOR: Kevin King
    DATE: 2025-08-07
    PARAMETERS: contactid, t1-t4 (tab selection), status filters
    DEPENDENCIES: Bootstrap 5, jQuery, Parsley.js, various service components
--->

<cfinclude template="/include/qry/fetchLocationService.cfm" />

<!--- Initialize parameters --->
<cfparam name="suID" default="7" />
<cfparam name="recid" default="0" />
<cfparam name="t1" default="1" />
<cfparam name="t2" default="0" />
<cfparam name="t3" default="0" />
<cfparam name="t4" default="0" />
<cfparam name="hide_completed" default="N" />
<cfparam name="dbugz" default="N" />
<cfparam name="status_active" default="Y" />
<cfparam name="status_completed" default="N" />
<cfparam name="status_future" default="N" />

<!--- Set current date based on session or current time --->
<cfif isDefined('session.mocktoday')>
    <cfset currentStartDate = dateFormat(session.mocktoday, 'yyyy-mm-dd') />
<cfelse>
    <cfset currentStartDate = dateFormat(now(), 'yyyy-mm-dd') />
</cfif>

<!--- Initialize tab expansion variables --->
<cfset contact_expand = false />
<cfset appointments_expand = false />
<cfset notes_expand = false />
<cfset relationship_expand = false />

<!--- Determine which tab should be active based on URL parameters --->
<cfif t1 eq 1>
    <cfset contact_expand = true />
<cfelseif t2 eq 1>
    <cfset appointments_expand = true />
<cfelseif t3 eq 1>
    <cfset notes_expand = true />
<cfelseif t4 eq 1>
    <cfset relationship_expand = true />
<cfelse>
    <!--- Default to contact tab if no tab specified --->
    <cfset contact_expand = true />
</cfif>

<!--- Handle mobile device redirections --->
<cfif devicetype eq "mobile">
    <cfif t2 eq 1>
        <cflocation url="/app/contact/?contactid=#contactid#&new_pgid=119" />
    <cfelseif t3 eq 1>
        <cflocation url="/app/contact/?contactid=#contactid#&new_pgid=118" />
    <cfelseif t4 eq 1>
        <cflocation url="/app/contact/?contactid=#contactid#&new_pgid=120" />
    </cfif>
</cfif>

<!--- Set session and application variables --->
<cfset currentid = contactid />
<cfset session.currentpage = "/app/contact/?contactid=#currentid#" />

<!--- Check for cookie values and set status accordingly --->
<cfif isDefined('cookie.status_active')>
    <cfset status_active = cookie.status_active />
</cfif>
<cfif isDefined('cookie.status_completed')>
    <cfset status_completed = cookie.status_completed />
</cfif>
<cfif isDefined('cookie.status_future')>
    <cfset status_future = cookie.status_future />
</cfif>

<!--- Include all required query templates --->
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
<cfinclude template="/include/qry/findscope.cfm" />
<cfinclude template="/include/qry/sysAvail_539_3.cfm" />
<cfinclude template="/include/qry/getRemindersByRelationship.cfm" />
<cfinclude template="/include/qry/emailcheck_469_1.cfm" />
<cfinclude template="/include/qry/phonecheck_515_1.cfm" />
<cfinclude template="/include/qry/fetchcontactitems.cfm" />
<cfinclude template="/include/qry/findcompany_476_1.cfm" />
<cfinclude template="/include/qry/notesRelationship_509_1.cfm" />

<!--- Set contact photo and status variables --->
<cfif len(trim(details.contactphoto))>
    <cfset browser_contact_avatar_filename = details.contactphoto />
</cfif>

<!--- Set status check variables for form controls --->
<cfset status_active_check = (status_active eq "Y") ? "checked" : "" />
<cfset status_completed_check = (status_completed eq "Y") ? "checked" : "" />
<cfset status_future_check = (status_future eq "Y") ? "checked" : "" />
<cfset relationship_expand_check = relationship_expand ? "show active" : "" />

<!--- Initialize modal for relationship system (SUID 0) --->
<script>
$(document).ready(function() {
    $("#remoteUpdateSUID0").on("show.bs.modal", function(event) {
        $(this).find(".modal-body").load("<cfoutput>/include/remoteUpdateSUID.cfm?suid=0&contactid=#currentid#</cfoutput>");
    });
});
</script>

<!--- Modal for relationship system (SUID 0) --->
<div id="remoteUpdateSUID0" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="remoteUpdateSUID0Title" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="remoteUpdateSUID0Title">Relationship System</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body"></div>
        </div>
    </div>
</div>

<!--- Dynamic modals for each relationship system --->
<cfloop query="ru">
    <script>
    $(document).ready(function() {
        $("#remoteUpdateSUID<cfoutput>#ru.suid#</cfoutput>").on("show.bs.modal", function(event) {
            $(this).find(".modal-body").load("<cfoutput>/include/remoteUpdateSUID.cfm?suid=#ru.suid#&contactid=#currentid#</cfoutput>");
        });
    });
    </script>

    <div id="remoteUpdateSUID<cfoutput>#ru.suid#</cfoutput>" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="remoteUpdateSUID<cfoutput>#ru.suid#</cfoutput>Title" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="remoteUpdateSUID<cfoutput>#ru.suid#</cfoutput>Title">Update Relationship System</h4>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body"></div>
            </div>
        </div>
    </div>
</cfloop>

<!--- Include contact update modal queries --->
<cfinclude template="/include/qry/cu_83_1.cfm" />

<!--- Dynamic modals for contact updates --->
<cfloop query="cu">
    <script>
    $(document).ready(function() {
        $("#remoteUpdateC<cfoutput>#cu.itemid#</cfoutput>").on("show.bs.modal", function(event) {
            var modal = $(this);
            modal.find(".modal-body").load("<cfoutput>/include/remoteupdatec.cfm?userid=#userid#&itemid=#cu.itemid#</cfoutput>", function() {
                modal.find("form").parsley();
            });
        });
    });
    </script>

    <div id="remoteUpdateC<cfoutput>#cu.itemid#</cfoutput>" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="remoteUpdateC<cfoutput>#cu.itemid#</cfoutput>Title" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="remoteUpdateC<cfoutput>#cu.itemid#</cfoutput>Title">
                        Update <cfoutput>#cu.valueCategory#</cfoutput> Form
                    </h4>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body"></div>
            </div>
        </div>
    </div>
</cfloop>

<!--- System active modals and delete forms --->
<cfloop query="sysactive">
    <cfoutput>
        <!--- System information modal --->
        <div id="action#sysactive.suid#-modal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="action#sysactive.suid#Title" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title" id="action#sysactive.suid#Title">#sysactive.recordname#</h4>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <h5>Description</h5>
                        <p>#sysactive.systemdescript#</p>
                        <p><strong>Start Date:</strong> #this.formatDate(sysactive.sustartdate)#</p>
                        <cfif len(trim(sysactive.suenddate))>
                            <p><strong>Completed:</strong> #this.formatDate(sysactive.suenddate)#</p>
                        </cfif>
                    </div>
                </div>
            </div>
        </div>

        <!--- Delete confirmation modal --->
        <script>
        $(document).ready(function() {
            $("#remoteDeleteForm#sysActive.suid#").on("show.bs.modal", function(event) {
                $(this).find(".modal-body").load("/include/remoteDeleteForm.cfm?recid=#sysActive.suid#&rpgid=40&pgaction=update&contactid=#currentid#&pgdir=contact&t4=1");
            });
        });
        </script>

        <div id="remoteDeleteForm#sysActive.suid#" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="remoteDeleteForm#sysActive.suid#Title" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg-danger text-white">
                        <h4 class="modal-title text-white" id="remoteDeleteForm#sysActive.suid#Title">Follow Up System</h4>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body"></div>
                </div>
            </div>
        </div>
    </cfoutput>
</cfloop>

<!--- Include category query and create add modals --->
<cfinclude template="/include/qry/c_83_2.cfm" />

<cfloop query="c">
    <script>
    $(document).ready(function() {
        $("#remoteAddC<cfoutput>#c.catid#</cfoutput>").on("show.bs.modal", function(event) {
            $(this).find(".modal-body").load("<cfoutput>/include/remoteAddC.cfm?catid=#c.catid#&userid=#userid#&contactid=#currentid#</cfoutput>", function() {
                $(this).find("form").parsley();
            });
        });
    });
    </script>

    <div id="remoteAddC<cfoutput>#c.catid#</cfoutput>" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="remoteAddC<cfoutput>#c.catid#</cfoutput>Title" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="remoteAddC<cfoutput>#c.catid#</cfoutput>Title">New <cfoutput>#c.valueCategory#</cfoutput> Form</h4>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body"></div>
            </div>
        </div>
    </div>
</cfloop>

<!--- Tag management modal --->
<script>
$(document).ready(function() {
    $("#remoteUpdateTag").on("show.bs.modal", function(event) {
        $(this).find(".modal-body").load("<cfoutput>/include/remoteUpdateTag.cfm?contactid=#currentid#</cfoutput>");
    });
});
</script>

<div id="remoteUpdateTag" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="remoteUpdateTagTitle" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="remoteUpdateTagTitle">Update Tags</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body"></div>
        </div>
    </div>
</div>

<!--- New form modal --->
<script>
$(document).ready(function() {
    $("#remoteNewForm").on("show.bs.modal", function(event) {
        $(this).find(".modal-body").load("<cfoutput>/include/RemoteNewForm.cfm?rpgid=36&pgid=3&t2=1&pgdir=#pgdir#&contactid=#contactid#</cfoutput>");
    });
});
</script>

<!--- Maintenance completion notification modal --->
<div id="showmaint" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="showmaintTitle" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content modal-filled bg-success">
            <div class="modal-body p-4">
                <div class="text-center">
                    <i class="dripicons-checkmark h1 text-white"></i>
                    <h4 class="mt-2 text-white" id="showmaintTitle">Follow-up System Completed!</h4>
                    <p class="mt-3 text-white">
                        <cfoutput>#details.recordname#</cfoutput> has been automatically placed into a maintenance list system.
                    </p>
                    <button type="button" class="btn btn-light my-2" data-bs-dismiss="modal">Continue</button>
                </div>
            </div>
        </div>
    </div>
</div>

<!--- Contact deletion modal --->
<cfoutput>
<script>
$(document).ready(function() {
    $("#remoteDeleteForm#currentid#").on("show.bs.modal", function(event) {
        $(this).find(".modal-body").load("/include/remoteDeleteForm.cfm?recid=#currentid#&rpgid=#pgid#&pgaction=update&pgdir=#pgdir#");
    });
});
</script>

<div id="remoteDeleteForm#currentid#" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="remoteDeleteForm#currentid#Title" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h4 class="modal-title text-white" id="remoteDeleteForm#currentid#Title">#compname#</h4>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body"></div>
        </div>
    </div>
</div>
</cfoutput>

<!--- Contact name update modal --->
<script>
$(document).ready(function() {
    $("#remoteUpdateName").on("show.bs.modal", function(event) {
        $(this).find(".modal-body").load("<cfoutput>/include/remoteUpdateName.cfm?contactid=#currentid#&userid=#userid#</cfoutput>");
    });
});
</script>

<div id="remoteUpdateName" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="remoteUpdateNameTitle" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="remoteUpdateNameTitle">Contact Details</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body"></div>
        </div>
    </div>
</div>

<!--- Active notifications modals --->
<cfloop query="sysactive">
    <cfinclude template="/include/qry/notsactive_510_1.cfm" />
    <cfinclude template="/include/qry/notsInactive_510_2.cfm" />
    
    <cfloop query="notsactive">
        <cfoutput>
            <!--- Action modal --->
            <div id="action#notsActive.actionid#-modal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="action#notsActive.actionid#Title" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h4 class="modal-title" id="action#notsActive.actionid#Title">#notsActive.actiontitle#</h4>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <h5>#notsActive.actiondetails#</h5>
                            <p>#notsActive.actionInfo#</p>
                            
                            <!--- Build action link URL based on type --->
                            <cfset newactionlinkURL = "" />
                            <cfif notsActive.actionLinkID eq 2>
                                <cfset emaillink = (emailcheck.recordcount eq 1) ? emailcheck.email : "unknown" />
                                <cfset newactionlinkURL = "mailto:#emaillink#" />
                            <cfelseif notsActive.actionLinkID eq 6>
                                <cfset newendlink = details.contactfullname />
                                <cfset newactionlinkURL = "#notsactive.ActionLinkURL##newendlink#+acting" />
                            <cfelseif notsActive.actionLinkID neq 0>
                                <cfset newendlink = notsactive.endlink />
                                <cfset newactionlinkURL = "#notsactive.ActionLinkURL#?contactid=#currentid##newendlink#" />
                            </cfif>
                            
                            <cfif len(trim(newactionlinkURL))>
                                <p class="text-center">
                                    <a href="#newActionLinkURL#" target="#notsactive.targetlink#" class="btn btn-sm btn-primary">#notsactive.BtnName#</a>
                                </p>
                            </cfif>
                        </div>
                    </div>
                </div>
            </div>

            <!--- Action confirmation modal --->
            <div id="actionconfirm#notsActive.actionid#-modal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="actionconfirm#notsActive.actionid#Title" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h4 class="modal-title" id="actionconfirm#notsActive.actionid#Title">#notsActive.actiontitle# Completed</h4>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body text-center">
                            <h5>Looks like you completed this reminder. Congratulations!</h5>
                            <p class="my-3">Click confirm and we'll close it out and add the next reminder</p>
                            <a href="/include/complete_not.cfm?contactid=#currentid#&systemid=#notsActive.systemID#&userid=#userid#&actionid=#actionid#&status_active=#status_active#&status_completed=#status_completed#&status_future=#status_future#&notid=#notsactive.notid#" 
                               class="btn btn-primary">Confirm</a>
                        </div>
                    </div>
                </div>
            </div>
        </cfoutput>
    </cfloop>
</cfloop>

<!--- Main content layout --->
<div class="row w-100 m-0 p-0 d-flex">
    <!--- Contact Photo and Basic Info Card --->
    <div class="col-md-6 col-sm-6 col-xs-12">
        <div class="card h-100 mb-3">
            <cfset tool_button = "btn-xl text-secondary px-1" />
            
            <!--- Contact delete form modal initialization --->
            <cfoutput>
            <script>
            $(document).ready(function() {
                $("#remoteDeleteForm#recid#").on("show.bs.modal", function(event) {
                    $(this).find(".modal-body").load("/include/remoteDeleteForm.cfm?recid=#contactid#&rpgid=3&pgaction=update&pgdir=#pgdir#");
                });
            });
            </script>
            </cfoutput>

            <h4 class="card-header text-center text-white text-nowrap py-3" style="background-color: #406E8E;">
                <cfoutput>#details.fullname#</cfoutput>
            </h4>
            
            <!--- Contact action buttons --->
            <div class="py-2 px-3 text-center">
                <cfif emailcheck.recordcount eq 1>
                    <cfoutput>
                    <cfset email = emailcheck.email />
                    <a href="mailto:#email#" class="#tool_button#" data-bs-toggle="tooltip" data-bs-placement="top" title="Email" aria-label="Send Email">
                        <i class="fe-mail"></i>
                    </a>
                    </cfoutput>
                </cfif>

                <cfif phonecheck.recordcount eq 1>
                    <cfset phonenumber = phonecheck.phonenumber />
                    <cfinclude template="/include/formatPhoneNumber.cfm" />
                    <cfoutput>
                    <a href="tel:#anchorPhoneNumber#" class="#tool_button#" data-bs-toggle="tooltip" data-bs-placement="top" title="Voice Call" aria-label="Make Phone Call">
                        <i class="fe-phone-call"></i>
                    </a>
                    </cfoutput>
                </cfif>

                <a href="/app/appoint-add/?returnurl=contact&rcontactid=<cfoutput>#currentid#</cfoutput>" class="<cfoutput>#tool_button#</cfoutput>" data-bs-toggle="tooltip" data-bs-placement="top" title="Add Appointment" aria-label="Add Appointment">
                    <i class="fe-calendar"></i>
                </a>
            </div>

            <div class="card-body text-center">
                <!--- Contact avatar with upload link --->
                <a class="no-hover-effect" href="/app/image-upload-contact/?contactid=<cfoutput>#contactid#&ref_pgid=3</cfoutput>" aria-label="Upload Contact Photo">
                    <figure>
                        <cfoutput>
                        <cfset contact_avatar = session.userContactsUrl & "/" & currentid & "/avatar.jpg" />
                        <cfset default_avatar = application.defaultAvatarUrl />
                        <cfset avatar_path = session.userContactsPath & "/" & currentid & "/avatar.jpg" />

                        <cfif NOT fileExists(avatar_path)>
                            <img src="#default_avatar#" 
                                 class="mr-3 rounded-circle img-responsive img-thumbnail w-100" 
                                 style="max-width:180px;" 
                                 alt="Default profile image" 
                                 id="item-img-output" />
                            
                            <!--- Copy default avatar to user's contact folder --->
                            <cftry>
                                <cfif NOT directoryExists(session.userContactsPath & "/" & currentid)>
                                    <cfdirectory action="create" directory="#session.userContactsPath & '/' & currentid#" />
                                </cfif>
                                <cffile action="copy" 
                                        source="#application.defaultAvatarUrl#" 
                                        destination="#avatar_path#" />
                            <cfcatch type="any">
                                <cfset application.errorLog = "Failed to copy default avatar: " & cfcatch.message />
                            </cfcatch>
                            </cftry>
                        <cfelse>
                            <img src="#contact_avatar#?rev=#rand()#" 
                                 class="mr-3 rounded-circle img-responsive img-thumbnail w-100" 
                                 style="max-width:180px;" 
                                 alt="Contact profile image" 
                                 id="item-img-output" />
                        </cfif>
                        </cfoutput>
                    </figure>
                </a>
                
                <!--- Company information --->
                <cfloop query="findcompany">
                    <cfoutput><div class="mt-2 text-center font-weight-bold">#valueCompany#</div></cfoutput>
                </cfloop>
            </div>
        </div>
    </div>

    <!--- Relationship Info Card --->
    <div class="col-md-6 col-sm-6 col-xs-12">
        <div class="card h-100 mb-3">
            <h4 class="card-header text-center text-white text-nowrap py-3 relationship-header" style="background-color: #406E8E;">
                Relationship Info
                <span class="float-end">
                    <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteUpdateName" 
                       class="text-white" data-bs-toggle="tooltip" data-bs-placement="top" title="Update Contact" aria-label="Update Contact">
                        <i class="mdi mdi-square-edit-outline"></i>
                    </a>
                </span>
            </h4>

            <div class="card-body">
                <!--- Tags section --->
                <div class="mb-3">
                    <cfif tagscontact.recordcount gt 0>
                        <cfloop query="tagscontact">
                            <cfoutput>
                            <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteUpdateTag" 
                               class="badge bg-secondary me-1" data-bs-toggle="tooltip" title="Update Tag">#tagscontact.valuetext#</a>
                            </cfoutput>
                        </cfloop>
                        <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteUpdateTag" 
                           class="text-muted" data-bs-toggle="tooltip" title="Add Tag">
                            <small><i class="fe-plus-circle"></i></small>
                        </a>
                    <cfelse>
                        <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteUpdateTag" 
                           class="text-muted" data-bs-toggle="tooltip" title="Add Tag">Add a Tag</a>
                    </cfif>
                </div>

                <!--- Contact details --->
                <cfif len(trim(details.contactpronoun))>
                    <p class="text-muted small mb-2">
                        <strong>Gender Pronoun:</strong> <cfoutput>#details.contactpronoun#</cfoutput>
                    </p>
                </cfif>

                <p class="text-muted small mb-2">
                    <cfoutput>
                    <strong>Birthday:</strong>
                    <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteUpdateName" 
                       class="text-decoration-none" data-bs-toggle="tooltip" title="Update Contact">
                        <cfif len(trim(details.contactBirthday))>
                            #month(details.contactbirthday)#/#day(details.contactbirthday)#
                        <cfelse>
                            Add Birthday
                        </cfif>
                    </a>
                    </cfoutput>
                </p>

                <p class="text-muted small mb-2">
                    <cfoutput>
                    <cfset meetingdate = this.formatDate(details.contactmeetingdate) />
                    <strong>Initial Meeting:</strong>
                    <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteUpdateName" 
                       class="text-decoration-none" data-bs-toggle="tooltip" title="Update Contact">#meetingdate#</a>
                    <cfif len(trim(details.contactmeetingloc))>
                        <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteUpdateName" 
                           class="text-decoration-none" data-bs-toggle="tooltip" title="Update Contact">(#details.contactmeetingloc#)</a>
                    </cfif>
                    </cfoutput>
                </p>

                <cfif len(trim(details.referdetailsfullname))>
                    <p class="text-muted small mb-2">
                        <strong>Referred By:</strong> <cfoutput>#details.referdetailsfullname#</cfoutput>
                    </p>
                </cfif>

                <!--- Newsletter and social media badges --->
                <cfif details.newsletter_yn eq "Y" OR details.googlealert_yn eq "Y" OR details.socialmedia_yn eq "Y">
                    <div class="mb-3">
                        <cfif details.newsletter_yn eq "Y">
                            <span class="badge bg-outline-primary me-1">✓ Newsletter</span>
                        </cfif>
                        <cfif details.googlealert_yn eq "Y">
                            <span class="badge bg-outline-primary me-1">✓ Google Alert</span>
                        </cfif>
                        <cfif details.socialmedia_yn eq "Y">
                            <span class="badge bg-outline-primary me-1">✓ Social Media</span>
                        </cfif>
                    </div>
                </cfif>

                <!--- Social media profiles --->
                <cfif profiles.recordcount gt 0>
                    <div class="mb-3">
                        <cfloop query="profiles">
                            <cfoutput>
                            <a href="#profiles.valuetext#" class="text-decoration-none me-2" target="_blank" 
                               data-bs-toggle="tooltip" title="#profiles.valuetype#" aria-label="#profiles.valuetype#">
                                <cfif len(trim(profiles.typeicon))>
                                    <img src="#application.retinaIcons14Url#/#profiles.typeicon#" alt="#profiles.valuetype#" width="32" height="32" />
                                <cfelse>
                                    <img src="#application.retinaIcons14Url#/customlink.png" alt="Custom Link" width="32" height="32" />
                                </cfif>
                            </a>
                            </cfoutput>
                        </cfloop>
                    </div>
                </cfif>

                <!--- Relationship systems --->
                <cfloop query="inactivecategories">
                    <cfif catid eq 0>
                        <div class="mt-4 position-relative ps-5">
                            <cfif rels.recordcount gt 0>
                                <i class="fe-users position-absolute start-0 top-0 fs-4"></i>
                                <cfloop query="rels">
                                    <cfoutput>
                                    <h6 class="mb-1">
                                        <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" 
                                           data-bs-target="#remoteUpdateSUID#rels.suid#" 
                                           class="text-decoration-none" data-bs-toggle="tooltip" title="Relationship System">#rels.SystemType#</a>
                                    </h6>
                                    <div class="text-uppercase small text-muted">#rels.systemscope#</div>
                                    </cfoutput>
                                </cfloop>
                            <cfelse>
                                <i class="fe-users position-absolute start-0 top-0 fs-4 text-muted"></i>
                                <h6 class="mb-1 text-muted">
                                    <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" 
                                       data-bs-target="#remoteUpdateSUID0" class="text-decoration-none" 
                                       data-bs-toggle="tooltip" title="Add Relationship">Add Relationship System</a>
                                </h6>
                                <div class="text-uppercase small text-muted">None</div>
                            </cfif>
                        </div>
                    </cfif>
                </cfloop>
            </div>
        </div>
    </div>
</div>

<div class="mb-4"></div>

<!--- Mobile Layout --->
<cfif devicetype eq "mobile">
    <div class="card mb-3">
        <div class="btn-group py-0 col-md-12">
            <button type="button" class="btn btn-primary btn-lg dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                <cfoutput>#pgname#</cfoutput>
                <i class="fe-menu ms-2"></i>
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
            <cfswitch expression="#pgid#">
                <cfcase value="117">
                    <cfinclude template="/include/contact_pane.cfm" />
                </cfcase>
                <cfcase value="118">
                    <cfinclude template="/include/notes_relationship_pane.cfm" />
                </cfcase>
                <cfcase value="119">
                    <cfinclude template="/include/appointments_pane.cfm" />
                </cfcase>
                <cfcase value="120">
                    <cfinclude template="/include/reminder_pane.cfm" />
                </cfcase>
            </cfswitch>
        </div>
    </div>

<!--- Desktop Layout with Tabs --->
<cfelse>
    <!--- Set active tab classes --->
    <cfset contact_active = contact_expand ? "show active" : "" />
    <cfset appointments_active = appointments_expand ? "show active" : "" />
    <cfset notes_active = notes_expand ? "show active" : "" />
    <cfset relationship_active = relationship_expand ? "show active" : "" />

    <div class="card mb-3">
        <div class="card-body">
            <!--- Tab Navigation --->
            <ul class="nav nav-pills navtab-bg nav-justified p-1" role="tablist">
                <li class="nav-item">
                    <a href="#contact" data-bs-toggle="tab" aria-expanded="<cfoutput>#contact_expand#</cfoutput>" 
                       class="nav-link<cfif contact_expand> active</cfif>" role="tab" aria-controls="contact">
                        Contact Details
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#notes" data-bs-toggle="tab" aria-expanded="<cfoutput>#notes_expand#</cfoutput>" 
                       class="nav-link<cfif notes_expand> active</cfif>" role="tab" aria-controls="notes">
                        Notes
                        <cfif notesContact.recordcount gt 0>
                            <cfoutput>(#numberFormat(notesContact.recordcount)#)</cfoutput>
                        </cfif>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#appointments" data-bs-toggle="tab" aria-expanded="<cfoutput>#appointments_expand#</cfoutput>" 
                       class="nav-link<cfif appointments_expand> active</cfif>" role="tab" aria-controls="appointments">
                        Appointments
                        <cfif eventresults.recordcount gt 0>
                            <cfoutput>(#numberFormat(eventresults.recordcount)#)</cfoutput>
                        </cfif>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#relationship" data-bs-toggle="tab" aria-expanded="<cfoutput>#relationship_expand#</cfoutput>" 
                       class="nav-link<cfif relationship_expand> active</cfif>" role="tab" aria-controls="relationship">
                        Relationship Reminders
                    </a>
                </li>
            </ul>

            <!--- Tab Content --->
            <div class="tab-content">
                <div class="tab-pane <cfoutput>#contact_active#</cfoutput>" id="contact" role="tabpanel">
                    <cfinclude template="/include/contact_pane.cfm" />
                </div>
                
                <div class="tab-pane <cfoutput>#notes_active#</cfoutput>" id="notes" role="tabpanel">
                    <cfinclude template="/include/notes_relationship_pane.cfm" />
                </div>
                
                <div class="tab-pane <cfoutput>#appointments_active#</cfoutput>" id="appointments" role="tabpanel">
                    <cfinclude template="/include/appointments_pane.cfm" />
                </div>
                
                <div class="tab-pane <cfoutput>#relationship_active#</cfoutput>" id="relationship" role="tabpanel">
                    <cfinclude template="/include/reminder_pane.cfm" />
                </div>
            </div>
        </div>
    </div>
</cfif>

<!--- JavaScript for modal and form handling --->
<script>
document.addEventListener("DOMContentLoaded", function () {
    // Initialize tooltips
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });

    // Modal reset handler
    $('.modal').on('hidden.bs.modal', function () {
        var modalForm = $(this).find("form")[0];
        if (modalForm) {
            modalForm.reset();
            if ($(modalForm).parsley) {
                $(modalForm).parsley().reset();
            }
            $("#hidden_div").hide();
            $("#special").hide();
        }
    });

    // Custom field handlers
    $("#valueCompany").on("change", function () {
        toggleCustomField(this);
    });

    $("#valueType").on("change", function () {
        handleCustomTypeValidation(this);
    });

    // Modal-specific handlers
    $('.modal').on('show.bs.modal', function () {
        var modalId = $(this).attr('id');
        $(`#${modalId} select[name="valueType"]`).off("change").on("change", function () {
            handleCustomTypeValidation(this, modalId);
        });
    });

    // Phone number validator
    if (window.Parsley) {
        window.Parsley.addValidator('phone', {
            validateString: function(value) {
                const phoneRegex = /^(?:\(?\d{3}\)?[-.\s]?)?\d{3}[-.\s]?\d{4}$/;
                return phoneRegex.test(value);
            },
            messages: {
                en: 'Please enter a valid phone number (e.g., 123-456-7890)',
            }
        });
    }
});
</script>