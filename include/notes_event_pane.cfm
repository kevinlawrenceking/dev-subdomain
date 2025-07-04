<!--- This ColdFusion page displays notes associated with an event, allowing users to view, add, and delete notes and their attachments. --->
<div class="d-flex justify-content-between">

    <div class="float-left">

        <!--- Check if there are no notes and display a message if true --->
        <cfif #NotesEvent.recordcount# is "0">
            No notes.
        </cfif>

        <!--- Output the count of notes --->
        <cfoutput>
            You have <strong>#NotesEvent.recordcount#</strong> note<cfif #NotesEvent.recordcount# is not "1">s</cfif>
        </cfoutput>

    </div>

    <div class="float-end">

        <!--- Link to add a new note --->
        <a href="/app/note-add-event/?returnurl=appoint&reventid=<cfoutput>#eventid#</cfoutput>&rcontactid=0" class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: #406e8e; border: #406e8e;">
            Add
        </a>

    </div>

</div>

<div class="nomobile">

    <div class="table-responsive" id="NotesContact_container">
        <table id="notes-datatable" class="table display dt-responsive nowrap w-100 table-striped table-hover">

            <thead>

                <!--- Output the header row for the notes table --->
                <cfoutput query="NotesEvent" maxrows="1">
                    <cfif (NotesEvent.CurrentRow MOD 2)>
                        <Cfset rowtypee="Odd" />
                    </cfif>

                    <cfif (NotesEvent.CurrentRow MOD 1)>
                        <Cfset rowtypee="Even" />
                    </cfif>

                    <tr class="#rowtypee#">
                        <th>Action</th>
                        <th>#head1#</th>
                        <th>#head4#</th>
                        <th>Links</th>
                        <th>Attachments</th>
                        <th>#head5#</th>
                        <th></th>
                    </tr>
                </cfoutput>

            </thead>

            <tbody>

                <!--- Loop through each note in NotesEvent --->
                <cfloop query="NotesEvent">
                    <cfset new_noteid=NotesEvent.noteid />

                    <!--- Include templates for links and attachments --->
                    <cfinclude template="/include/qry/getLinksByNoteId.cfm" />
                    <cfinclude template="/include/qry/attachments_181_2.cfm" />

                    <cfoutput>

                        <!--- JavaScript to handle modal for adding links --->
                        <script>
                            $(document).ready(function() {
                                $("##remoteaddlink#NotesEvent.noteid#").on("show.bs.modal", function(event) {
                                    
                                    $(this).find(".modal-body").load("/include/linkadd.cfm?contactid=0&noteid=#new_noteid#&returnurl=appoint");
                                });
                            });
                        </script>

                        <div id="remoteaddlink#NotesEvent.noteid#" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header" >
                                        <h4 class="modal-title" id="standard-modalLabel">Note Links</h4>
                                        <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                                    </div>
                                    <div class="modal-body"></div>
                                </div>
                            </div>
                        </div>

                        <!--- JavaScript to handle modal for note details --->
                        <script>
                            $(document).ready(function() {
                                $("##remotenotedetails#NotesEvent.noteid#").on("show.bs.modal", function(event) {
                                    
                                    $(this).find(".modal-body").load("/include/remotenotedetails.cfm?contactid=0&noteid=#new_noteid#&returnurl=appoint");
                                });
                            });
                        </script>

                        <div id="remotenotedetails#NotesEvent.noteid#" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

                            <div class="modal-dialog modal-lg modal-dialog-scrollable" role="document">
                                <div class="modal-content">
                                    <div class="modal-header" >
                                        <h4 class="modal-title" id="standard-modalLabel">Note</h4>
                                        <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                                    </div>
                                    <div class="modal-body"></div>
                                </div>
                            </div>
                        </div>

                        <!--- JavaScript to handle modal for adding attachments --->
                        <script>
                            $(document).ready(function() {
                                $("##remoteaddattachment#NotesEvent.noteid#").on("show.bs.modal", function(event) {
                                    
                                    $(this).find(".modal-body").load("/include/attachmentadd.cfm?contactid=0&noteid=#new_noteid#&returnurl=appoint");
                                });
                            });
                        </script>

                        <div id="remoteaddattachment#NotesEvent.noteid#" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header" >
                                        <h4 class="modal-title" id="standard-modalLabel">Upload an Attachment</h4>
                                        <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                                    </div>
                                    <div class="modal-body"></div>
                                </div>
                            </div>
                        </div>

                        <tr role="row">
                            <td>
                                <!--- Link to edit the note --->
                                <a title="Edit" href="/app/note-update-event/?noteid=#NotesEvent.noteid#&returnurl=appoint&reventid=#eventid#&eventid=#eventid#&rcontactid=0">
                                    <i class="mdi mdi-square-edit-outline"></i>
                                </a>
                            </td>

                            <td class="text-nowrap">#this.formatDate(NotesEvent.col1)#<BR />#timeformat('#NotesEvent.col2#','medium')#</td>

                            <td class="text-nowrap">
                                <cfif #NotesEvent.col4# is "1">Public<cfelse>Private</cfif>
                            </td>

                            <TD class="text-nowrap">
                                <!--- Link to add a new link --->
                                <a href="" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteaddlink#NotesEvent.noteid#" data-bs-placement="top" title="Add Link" data-bs-original-title="Add Link">
                                    <i class="fe-plus-circle"></i> Add link
                                </a>
                                <cfif #links.recordcount# is not "0">
                                    <cfloop query="links">
                                        <BR />
                                        <a href="#linkurl#" target="#new_noteid#">#linkname#</a>
                                        <a href="/include/linkdel.cfm?linkid=#links.linkid#&eventid=#eventid#&reventid=#eventid#&returnurl=appoint" title="delete link">
                                            <i class="mdi mdi-trash-can-outline mr-1"></i>
                                        </a>
                                    </cfloop>
                                </cfif>
                            </TD>

                            <TD class="text-nowrap">
                                <!--- Link to add a new attachment --->
                                <a href="" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteaddattachment#NotesEvent.noteid#" data-bs-placement="top" title="Add attachment" data-bs-original-title="Add attachment">
                                    <i class="fe-plus-circle"></i> Add attachment
                                </a>
                                <cfif #attachments.recordcount# is not "0">
                                    <cfloop query="attachments">
                                        <BR />
                                        <a href="/include/download.cfm?attachid=#attachid#">#attachname#</a>
                                        <a href="/include/attachmentdel.cfm?contactid=0&rcontactid=0&attachid=#attachments.attachid#&eventid=#eventid#&returnurl=appoint" title="delete attachment">
                                            <i class="mdi mdi-trash-can-outline mr-1"></i>
                                        </a>
                                    </cfloop>
                                </cfif>
                            </TD>

                            <td>
                                #NotesEvent.col5#
                                <cfif #notedetailshtml# is not "">
                                    <BR>
                                    <a href="" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remotenotedetails#NotesEvent.noteid#" data-bs-placement="top" title="View Details" data-bs-original-title="View Details">
                                        <i class="mdi mdi-eye-outline"></i> Details
                                    </a>
                                </cfif>
                            </td>

                            <TD>
                                <!--- Link to delete the note --->
                                <A href="/include/deletenote.cfm?recid=#NotesEvent.recid#&eventid=#eventid#&returnurl=#returnurl#">
                                    <i class="mdi mdi-trash-can-outline mr-1"></i>
                                </A>
                            </TD>
                        </tr>

                    </cfoutput>

                </cfloop>

            </tbody>

        </table>

    </div>
</div>

<div class="mobile" style="100%;">

    <cfparam name="target_id" default="0" />

    <div class="row">

        <div class="col-xl-12">

            <div id="accordion_systems" class="mb-3 w-100" >
                <cfset k=0 />

                <!--- Loop through each note in notesEvent for mobile display --->
                <cfloop query="notesEvent">
                    <cfset new_noteID = notesEvent.noteID />

                    <cfoutput>
                        <cfset k=#k# + 1 />
                    </cfoutput>

                    <cfset cardclass="" />

                    <cfif #notesEvent.currentrow# is "1">
                        <cfoutput>
                            <cfset target_id="#new_noteID#" />
                        </cfoutput>
                    </cfif>

                    <cfif #new_noteID# is "#target_id#">
                        <cfset header_aria_exanded="true" />
                        <cfset collapse_show = "collapse show" />
                    </cfif>

                    <cfif #new_noteID# is not "#target_id#">
                        <cfset header_aria_exanded="false" />
                        <cfset collapse_show = "collapse" />
                    </cfif>

                    <div class="card mb-1 w-100" >
                        <div class="card-header" id="heading_system_<cfoutput>#notesEvent.currentrow#</cfoutput>">
                            <h5 class="m-0 align-middle w-100" >
                                <a class="text-dark collapsed" data-bs-toggle="collapse" href="#collapse_system_<cfoutput>#notesEvent.currentrow#</cfoutput>" aria-expanded="<cfoutput>#header_aria_exanded#</cfoutput>">
                                    <cfoutput>
                                        <strong>#this.formatDate(notesEvent.noteTimestamp)#</strong> - #timeformat('#notesEvent.noteTimestamp#','short')# <i class="fe-menu"></i>
                                    </cfoutput>
                                    <span class="badge badge-sm badge-blue badge-pill float-end" style="font-size:.7em;">
                                        <cfoutput>
                                            <cfif #notesEvent.col4# is "1">Public<cfelse>Private</cfif>
                                        </cfoutput>
                                    </span>
                                </a>
                            </h5>
                        </div>

                        <div id="collapse_system_<cfoutput>#notesEvent.currentrow#</cfoutput>" class="<cfoutput>#collapse_show#</cfoutput>" aria-labelledby="collapse_system_<cfoutput>#notesEvent.currentrow#</cfoutput>" data-bs-parent="#accordion_systems">
                            <div class="card-body">
                                <cfoutput>
                                    <h5>#notesEvent.noteDetails#
                                        <a title="Edit" href="/app/note-update-event/?noteid=#notesEvent.noteid#&returnurl=appoint&rcontactid=0">
                                            <i class="mdi mdi-square-edit-outline"></i>
                                        </a>
                                    </h5>
                                </cfoutput>
                                <cfif #notesEvent.col4# is not "">
                                    <h6>Who Can See Note?</h6>
                                    <p>
                                        <cfif #notesEvent.col4# is "1">Public<cfelse>Private</cfif>
                                    </p>
                                </cfif>

                                <cfif #notesEvent.noteDetailsHTML# is not "">
                                    <h6>Description</h6>
                                    <p>
                                        <cfoutput>#notesEvent.noteDetailsHTML#</cfoutput>
                                    </p>
                                </cfif>
                            </div>
                        </div>
                    </div>

                </cfloop>

            </div>

        </div>

    </div>

</div>

