<!--- This ColdFusion page displays contact information, including profile image, tags, birthday, and various actions related to the contact. --->

<cfoutput>
    <cfset fileExist="#FileExists(browser_contact_avatar_filename)#" />
</cfoutput>

<div class="card mb-3">
    <cfoutput>
        <Cfset recid=#currentid# />
        <cfset h5style="font-size:0.875rem;font-weight: 500;text-align:left;margin-bottom:0;" />
    </cfoutput>

    <div class="card-body py-2 px-3 border-bottom border-light">
        <A  class="no-hover-effect" href="/app/image-upload/?contactid=<cfoutput>#contactid#&ref_pgid=#pgid#</cfoutput>">
            <figure>
                <!--- Check if the browser contact avatar filename is an image file --->
                <cfif isimagefile(browser_contact_avatar_filename)>
                    <img src="<cfoutput>#browser_contact_avatar_filename#</cfoutput>?ver=<Cfoutput>#rand()#</cfoutput>" class="mr-3 rounded-circle gambar img-responsive img-thumbnail" style="height:120px;" alt="profile-image" id="item-img-output" />
                <CFELSE>
                    <img src="<cfoutput>#application.defaultAvatarUrl#</cfoutput>" class="mr-3 rounded-circle gambar img-responsive img-thumbnail" style="height:120px;" alt="profile-image" id="item-img-output" />
                </cfif>
            </figure>
        </A>

        <h4 class="mt-0 mb-0">
            <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteUpdateName" data-bs-placement="top" title="Update Contact" data-bs-original-title="Update Contact">
                <cfoutput>#details.fullname#</cfoutput>
                <cfif #TRIM(details.fullname)# is "">
                    Add Name
                </cfif>
                <cfif #details.contactpronoun# is not "">
                    <cfoutput>(#details.contactpronoun#)</cfoutput>
                </cfif>
            </a>
        </h4>

        <HR/>

        <div class="container-flex">
            <div class="row">
                <div class="col-12 col-md-12 col-lg-6">
                    <p class="mt-1 mb-0 text-muted font-16">
                        <!--- Loop through tags contact --->
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

                    <p class="mt-1 mb-0 text-muted font-14">
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
                        <cfset meetingdate="#Details.contactmeetingdate#" />
                        <p class="mt-1 mb-0 text-muted font-14">
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
                            <p class="mt-1 mb-0 text-muted font-14">
                                <strong>Referred By:</strong> #details.referdetailsfullname#
                            </p>
                        </cfif>
                    </cfif>
                </div>

                <div class="col-12 col-md-12 col-lg-6">
                    <cfif #details.newsletter_yn# is "Y" or #details.googlealert_yn# is "Y" or #details.socialmedia_yn# is "Y">
                        <p class="mt-1 mb-0 text-muted font-14">
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
                            <!--- Loop through profiles --->
                            <cfloop query="profiles">
                                <cfoutput>
                                    <a href="#profiles.valuetext#" class="text-reset font-18 py-1 ps-o me-2 px-1 d-inline-block" data-bs- data-bs-placement="top" title="" target="#profiles.valuetext#" data-bs-original-title="#profiles.valuetype#">
                                        <img src="#application.retinaIcons14Url#/#profiles.typeicon#" width="16px" />
                                    </a>
                                </cfoutput>
                            </cfloop>
                        </p>
                    </cfif>

                    <div>
                        <cfif #emailcheck.recordcount# is "1">
                            <cfoutput>
                                <Cfset email="#emailcheck.email#" />
                                <a href="mailto:#email#" class="text-reset font-18 py-1 px-2 d-inline-block" data-bs- data-bs-placement="top" title="" data-bs-original-title="Email">
                                    <i class="fe-mail"></i>
                                </a>
                            </cfoutput>
                        </cfif>

                        <cfif #phonecheck.recordcount# is "1">
                            <Cfset phonenumber=phonecheck.phonenumber />
                            <cfinclude template="/include/formatPhoneNumber.cfm" />
                            <cfoutput>
                                <a href="tel:#anchorPhoneNumber#" class="text-reset font-18 py-1 px-2 d-inline-block" data-bs- data-bs-placement="top" title="" data-bs-original-title="Voice Call">
                                    <i class="fe-phone-call"></i>
                                </a>
                            </cfoutput>
                        </cfif>

                        <a href="javascript:;" class="text-reset font-18 py-1 px-2 d-inline-block" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteNewForm" data-bs-placement="top" title="" data-bs-original-title="Add Appointment">
                            <i class="fe-calendar"></i>
                        </a>

                        <cfoutput>
                            <script>
                                $(document).ready(function() {
                                    $("##remoteDeleteForm#recid#").on("show.bs.modal", function(event) {
                                        
                                        $(this).find(".modal-body").load("/include/remoteDeleteForm.cfm?recid=#recid#&rpgid=#pgid#&pgaction=update&pgdir=#pgdir#");
                                    });
                                });
                            </script>

                            <a class="text-reset font-18 py-1 px-2 d-inline-block" href="javascript:;" data-bs-toggle="modal" data-bs-target="##remoteDeleteForm#recid#" title="Delete Relationship">
                                <i class="fe-trash-2"></i>
                            </a>
                        </cfoutput>
                    </div>
                </div>
            </div>
        </div>

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

        <cfif #relationship_expand# is "true">
            <cfset relationship_expand_check="show active" />
        </cfif>

        <div class="card-body">
            <ul class="nnav nav-pills nav-fill navtab-bg>
                <li class="nav-item">
                    <a href="#contact" data-bs-toggle="tab" aria-expanded="<cfoutput>#contact_expand#</cfoutput>" class="nav-link<cfif #contact_expand# is 'true'> active</cfif>">Relationship Info</a>
                </li>

                <li class="nav-item">
                    <a href="#notes" data-bs-toggle="tab" aria-expanded="<cfoutput>#notes_expand#</cfoutput>" class="nav-link<cfif #notes_expand# is 'true'> active</cfif>">Notes
                        <cfif notesContact.recordcount neq 0>
                            <span class="badge  badge-primary badge-pill">
                                <cfoutput>#numberformat(notesContact.recordcount)#</cfoutput>
                            </span>
                        </cfif>
                    </a>
                </li>

                <li class="nav-item">
                    <a href="#appointments" data-bs-toggle="tab" aria-expanded="<cfoutput>#appointments_expand#</cfoutput>" class="nav-link<cfif #appointments_expand# is 'true'> active</cfif>">Appointments
                        <cfif eventresults.recordcount neq 0>
                            <span class="badge  badge-primary badge-pill">
                                <cfoutput>(#numberformat(eventresults.recordcount)#)</cfoutput>
                            </span>
                        </cfif>
                    </a>
                </li>

                <li class="nav-item">
                    <a href="#relationship" data-bs-toggle="tab" aria-expanded="<cfoutput>#relationship_expand#</cfoutput>" class="nav-link<cfif #relationship_expand# is 'true'> active</cfif>">Relationship Reminders</a>
                </li>
            </ul>

            <div class="tab-content">
                <div class="tab-pane <Cfoutput>#contact_active#</cfoutput>" id="contact">
                    <cfinclude template="/include/contact_pane.cfm" />
                </div>

                <div class="tab-pane<cfif #notes_expand# is 'true'> show active</cfif>" id="notes">
                    <cfinclude template="/include/notes_relationship_pane.cfm" />
                </div>

                <div class="tab-pane <Cfoutput>#appointments_active#</cfoutput>" id="appointments">
                    <cfinclude template="/include/appointments_pane.cfm" />
                </div>

                <div class="tab-pane <Cfoutput>#relationship_expand_check#</cfoutput>" id="relationship">
                    <cfinclude template="/include/reminder_pane.cfm" />
                </div>
            </div>

            <cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), " \")#" />
        </div>
    </div>
</div>
