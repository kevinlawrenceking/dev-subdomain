

<cfparam name="t2" default="0" />

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

<cfset currentid=contactid />

<cfset session.currentpage="/app/contact/?contactid=#currentid#" />

<cfif isdefined('cookie.status_active')>

    <cfset status_active=cookie.status_active />

</cfif>

<cfif isdefined('cookie.status_completed')>

    <cfset status_completed=cookie.status_completed />

</cfif>

<cfif isdefined('cookie.status_future')>

    <cfset status_future=cookie.status_future />

</cfif>

<cfset rpgid=36 />

<cfinclude template="/include/tab_check.cfm" />

<cfinclude template="/include/modalRemoteNewForm.cfm" />

<cfinclude template="/include/qry/friendfamilycheck.cfm" />

<cfinclude template="/include/qry/contacts.cfm" />

<cfinclude template="/include/qry/categories.cfm" />

<cfinclude template="/include/qry/items.cfm" />

<cfinclude template="/include/qry/notesContact.cfm" />

<cfinclude template="/include/qry/SystemsContact.cfm" />

<cfinclude template="/include/qry/tagsContact.cfm" />

<cfinclude template="/include/qry/profiles.cfm" />

<cfinclude template="/include/qry/sysactive.cfm" />

<cfinclude template="/include/qry/notsall.cfm" />

<cfinclude template="/include/qry/events.cfm" />

<cfinclude template="/include/qry/systemNotificationsActive.cfm" />

<cfinclude template="/include/qry/SystemsActiveContact.cfm" />

<cfinclude template="/include/qry/ru.cfm" />

<cfinclude template="/include/qry/emailcheck.cfm" />

<cfinclude template="/include/qry/phonecheck.cfm" />

<cfinclude template="/include/qry/rels.cfm" />

<cfinclude template="/include/qry/fetchcontactitems.cfm">

<cfinclude template="/include/qry/tagFriendCheck.cfm" />

<cfif #details.contactphoto# is not "">

    <cfset browser_contact_avatar_filename=details.contactphoto />

</cfif>

<cfquery result="result"  name="cu">
    SELECT i.itemid, c.catid, c.valuecategory FROM contactitems i INNER JOIN itemcategory c ON c.valuecategory = i.valuecategory WHERE contactid = #currentid#
</cfquery>

<cfloop query="cu">

    <script>
        $(document).ready(function() {
            $("#remoteUpdate<cfoutput>C#cu.itemid#</cfoutput>").on("show.bs.modal", function(event) {
                
                $(this).find(".modal-body").load("<cfoutput>/include/remoteupdatec.cfm?userid=#userid#&itemid=#cu.itemid#</cfoutput>");
            });
        });
    </script>

    <div id="remoteUpdate<cfoutput>C#cu.itemid#</cfoutput>" class="modal fade" tabindex="-1" role="dialog" >


        <div class="modal-dialog">

            <div class="modal-content">

                <div class="modal-header">

                    <h4 class="modal-title">

                        Update <cfoutput>#cu.valueCategory# Form</cfoutput>

                    </h4>

                    <button type="button" class="close" data-bs-dismiss="modal" >


                        <i class="mdi mdi-close-thick"></i>

                    </button>

                </div>

                <div class="modal-body">

                </div>

            </div>

        </div>

    </div>

</cfloop>

<cfquery result="result"  name="c">
    SELECT * FROM itemcategory
</cfquery>

<cfloop query="c">

    <script>
        $(document).ready(function() {
            $("#remoteAdd<cfoutput>C#c.catid#</cfoutput>").on("show.bs.modal", function(event) {
                
                $(this).find(".modal-body").load("<cfoutput>/include/remoteAddC.cfm?catid=#c.catid#&userid=#userid#&contactid=#currentid#</cfoutput>");
            });
        });
    </script>

    <div id="remoteAdd<cfoutput>C#c.catid#</cfoutput>" class="modal fade" tabindex="-1" role="dialog" >


        <div class="modal-dialog">

            <div class="modal-content">

                <div class="modal-header">

                    <h4 class="modal-title">New <cfoutput>#c.valueCategory# Form</cfoutput>

                    </h4>

                    <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>

                </div>

                <div class="modal-body">

                </div>

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

            <div class="modal-body">

            </div>

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

    <div id="remoteDeleteForm#currentid#" class="modal fade" tabindex="-1" role="dialog" >


        <div class="modal-dialog">

            <div class="modal-content">

                <div class="modal-header" style="background-color: red;">

                    <h4 class="modal-title">#compname#</h4>

                    <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>

                </div>

                <div class="modal-body">

                </div>

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

            <div class="modal-body">

            </div>

        </div>

    </div>

</div>

<div class="row">

    <div class="col-md-3 col-sm-6 col-xs-12">

        <div class="card h-100 mb-3">

<Center>
                <h4 class="card-header text-nowrap">
                    <cfoutput>#details.fullname#</cfoutput>
                </h4>
            </Center>
            <div class="card-body">

<p class="card-text">

<A href="/app/image-upload/?contactid=<cfoutput>#contactid#&ref_pgid=#pgid#</cfoutput>"  class="no-hover-effect">

                            <figure>

                                <cfif isimagefile(browser_contact_avatar_filename)>

                                    <centeR><img src="<cfoutput>#browser_contact_avatar_filename#</cfoutput>?ver=<Cfoutput>#rand()#</cfoutput>" class="mr-3 rounded-circle gambar img-responsive img-thumbnail w-100" style="max-width:120px" alt="profile-image" id="item-img-output" />      </centeR>
                                    <CFELSE>
                                        <center><img src="/media-<cfoutput>#host#</cfoutput>/defaults/avatar.jpg" class="mr-3 rounded-circle gambar img-responsive img-thumbnail w-100" style="max-width:120px;" alt="profile-image" id="item-img-output" /></center>
                                </CFIF>

</figure>

                        </A>

</p>

</div>
        </div>

    </div>

<cfoutput>

        <cfset fileExist="#FileExists(browser_contact_avatar_filename)#" />

        <Cfset recid=#currentid# />

        <cfset h5style="font-size:0.875rem;font-weight: 500;text-align:left;margin-bottom:0;" />

    </cfoutput>

    <div class="col-md-9 col-sm-6 col-xs-12">

        <div class="card h-100 mb-3">

       <h4 class="card-header">

<cfif #emailcheck.recordcount# is "1">

                            <cfoutput>

                                <Cfset email="#emailcheck.email#" />

                                <a href="mailto:#email#" class="text-reset font-18 px-2 d-inline-block" data-bs- data-bs-placement="top" title="" data-bs-original-title="Email">

                                    <i class="fe-mail"></i>

                                </a>

                            </cfoutput>

                        </cfif>

                        <cfif #phonecheck.recordcount# is "1">

                            <Cfset phonenumber=phonecheck.phonenumber />

                            <cfinclude template="/include/formatPhoneNumber.cfm" />

                            <cfoutput>

                                <a href="tel:#anchorPhoneNumber#" class="text-reset font-18 px-2 d-inline-block" data-bs- data-bs-placement="top" title="" data-bs-original-title="Voice Call">

                                    <i class="fe-phone-call"></i>

                                </a>

                            </cfoutput>

                        </cfif>

                        <a href="javascript:;" class="text-reset font-18 px-2 d-inline-block" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteNewForm" data-bs-placement="top" title="" data-bs-original-title="Add Appointment">

                            <i class="fe-calendar"></i>

                        </a>

                        <cfoutput>

                            <script>
                                $(document).ready(function() {
                                    $("##remoteDeleteForm#recid#").on("show.bs.modal", function(event) {
                                        
                                        $(this).find(".modal-body").load("/include/remoteDeleteForm.cfm?recid=#recid#&rpgid=#3#&pgaction=update&pgdir=#pgdir#");
                                    });
                                });

                            </script>

                            <a class="text-reset font-18 px-2 d-inline-block" href="javascript:;" data-bs-toggle="modal" data-bs-target="##remoteDeleteForm#recid#" title="Delete Relationship">

                                <i class="fe-trash-2"></i>

                            </a>

                        </cfoutput>

</h4>

            <div class="card-body">

<p class="mt-1 mb-0 py-1 text-muted font-14">

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

<cfif #details.contactpronoun# is not "">
     <p class="mt-1 mb-0 text-muted py-1 font-14">
                            <cfoutput><strong>Gender Pronoun:</strong> #details.contactpronoun#</cfoutput>
                            </p>
                        </cfif>

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

<cfif #details.contactmeetingdate# is not "">

                    <cfset meetingdate="#dateformat('#details.contactmeetingdate#','medium')#" />

                    <p class="mt-1 mb-0 text-muted py-1 font-14">
                        <cfoutput>

                            <strong>Initial Meeting:</strong>

                            <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteUpdateName" data-bs-placement="top" title="Update Contact" data-bs-original-title="Update Contact">#meetingdate#</a>

                            <cfif #details.contactmeetingloc# is not "">

                                <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteUpdateName" data-bs-placement="top" title="Update Contact" data-bs-original-title="Update Contact">(#details.contactmeetingloc#)</a>

                            </cfif>
                        </cfoutput>
                    </p>

                </cfif>

<cfif #details.referdetailsfullname# is not "">

                    <cfif #refer_details.recordcount# is "1">

                        <p class="mt-1 mb-0 text-muted py-1 font-14">

                            <strong>Referred By:</strong> #details.referdetailsfullname#
                        </p>

                    </cfif>

                </cfif>

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

                                    <a href="#profiles.valuetext#" class="text-reset font-14 py-1 ps-o me-2   d-inline-block" data-bs- data-bs-placement="top" title="" target="#profiles.valuetext#" data-bs-original-title="#profiles.valuetype#">

                                        <img src="#application.retinaIcons14Url#/#profiles.typeicon#" width="16px" />

                                    </a>

                                </Cfoutput>

                            </cfloop>

                        </p>

                    </cfif>

</div>
        </div>

    </div>

</div>
<p>&nbsp;</p>

<div class="card mb-3">

        <div class="btn-group py-2 col-md-12">

            <button type="button" class="btn btn-primary dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">

                <Cfoutput>#pgname#</Cfoutput>
                <i class="mdi mdi-chevron-down"></i>

            </button>
            <div class="dropdown-menu">

                <cfloop query="FindOptions">
                    <cfoutput>
                        <a class="dropdown-item" href="/app/#pgDir#/?contactid=#contactid#&new_pgid=#FindOptions.pgid#">#FindOptions.pgname#</a>
                    </cfoutput>
                </cfloop>

            </div>
        </div><!--- /btn-group --->

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

<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), " \")#" />

