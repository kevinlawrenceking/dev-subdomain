<!--- This ColdFusion page displays notes related to a contact, allowing users to view, add, edit, and delete notes and their associated links and attachments. --->

<div class="d-flex justify-content-between">

    <div class="float-left">
        <!--- Check if there are no notes and display a message if true --->
        <cfif #notesRelationship.recordcount# is "0">
            No notes.
        </cfif>

        <!--- Output the count of notes --->
        <cfoutput>
            You have <strong>#notesRelationship.recordcount#</strong> note<cfif #notesRelationship.recordcount# is not "1">s</cfif>
        </cfoutput>
    </div>

    <div class="float-end">
        <!--- Button to add a new note --->
        <a href="/app/note-add-event/?returnurl=contact&contactid=<cfoutput>#currentid#</cfoutput>&rcontactid=<cfoutput>#currentid#</cfoutput>" class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: #406e8e; border: #406e8e;">
            Add
        </a>
    </div>
</div>

<div class="nomobile">
    <div class="table-responsive" id="notes_datatable_container">
        <table id="notes-datatable" class="table display dt-responsive nowrap w-100 table-striped table-hover">
            <thead>
                <!--- Output the table header based on the notes relationship query --->
                <cfoutput query="notesRelationship" maxrows="1">
                    <cfif (notesRelationship.CurrentRow MOD 2)>
                        <Cfset rowtypee="Odd" />
                    </cfif>
                    <cfif (notesRelationship.CurrentRow MOD 1)>
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
                <!--- Loop through the notes relationship query to display each note --->
                <cfloop query="notesRelationship">
                    <cfset new_noteid=notesRelationship.noteid />

                    <!--- Include links and attachments for each note --->
                    <cfinclude template="/include/qry/links_183_1.cfm" />
                    <cfinclude template="/include/qry/attachments_181_2.cfm" />

                    <cfoutput>
                        <!--- Modal for deleting a note --->
                        <script>
                            $(document).ready(function() {
                                $("##remoteDeleteFormNote#new_noteid#").on("show.bs.modal", function(event) {
                                    
                                    $(this).find(".modal-body").load("/include/remoteDeleteFormNote.cfm?recid=#new_noteid#&contactid=#currentid#&pgdir=contact&t3=1");
                                });
                            });
                        </script>
                        <div id="remoteDeleteFormNote#new_noteid#" class="modal fade" tabindex="-1" role="dialog" >

                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header" style="background-color: red;">
                                        <h4 class="modal-title">Delete Note Confirmation</h4>
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                            <span aria-hidden="true">&times;</span>
                                        </button>
                                    </div>
                                    <div class="modal-body"></div>
                                </div>
                            </div>
                        </div>

                        <!--- Modal for adding a link to a note --->
                        <script>
                            $(document).ready(function() {
                                $("##remoteaddlink#notesRelationship.noteid#").on("show.bs.modal", function(event) {
                                    
                                    $(this).find(".modal-body").load("/include/linkadd.cfm?noteid=#new_noteid#&contactid=#currentid#&returnurl=contact");
                                });
                            });
                        </script>
                        <div id="remoteaddlink#notesRelationship.noteid#" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header" >
                                        <h4 class="modal-title" id="standard-modalLabel">Note Links</h4>
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                            <span aria-hidden="true">&times;</span>
                                        </button>
                                    </div>
                                    <div class="modal-body"></div>
                                </div>
                            </div>
                        </div>

                        <!--- Modal for viewing note details --->
                        <div id="remotenotedetails#notesRelationship.noteid#" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >
                            <div class="modal-dialog modal-lg modal-dialog-scrollable" role="document">
                                <div class="modal-content">
                                    <div class="modal-header" >
                                        <h4 class="modal-title" id="standard-modalLabel">Note Details</h4>
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                            <span aria-hidden="true">&times;</span>
                                        </button>
                                    </div>
                                    <div class="modal-body">
                                        <cfif len(trim(notesRelationship.notedetailshtml))>
                                            #notesRelationship.notedetailshtml#
                                        <cfelse>
                                            <p class="text-muted">No additional details available for this note.</p>
                                        </cfif>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!--- Modal for adding an attachment to a note --->
                        <script>
                            $(document).ready(function() {
                                $("##remoteaddattachment#notesRelationship.noteid#").on("show.bs.modal", function(event) {
                                    
                                    $(this).find(".modal-body").load("/include/attachmentadd.cfm?noteid=#new_noteid#&reventid=0&eventid=0&contactid=#currentid#&returnurl=contact");
                                });
                            });
                        </script>
                        <div id="remoteaddattachment#notesRelationship.noteid#" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header" >
                                        <h4 class="modal-title" id="standard-modalLabel">Upload an Attachment</h4>
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                            <span aria-hidden="true">&times;</span>
                                        </button>
                                    </div>
                                    <div class="modal-body"></div>
                                </div>
                            </div>
                        </div>

                        <tr role="row">
                            <td>
                                <!--- Link to edit the note --->
                                <a title="Edit" href="/app/note-update-event/?noteid=#notesRelationship.noteid#&returnurl=contact&rcontactid=#currentid#">
                                    <i class="mdi mdi-square-edit-outline"></i>
                                </a>
                            </td>

                            <td class="text-nowrap">#this.formatDate(notesRelationship.col1)#<BR />#timeformat('#notesRelationship.col2#','medium')#</td>

                            <td class="text-nowrap">
                                <cfif #notesRelationship.col4# is "1">Public<cfelse>Private</cfif>
                            </td>

                            <td class="text-nowrap">
                                <!--- Link to add a new link --->
                                <a href="" data-remote="true" data-toggle="modal" data-target="##remoteaddlink#notesRelationship.noteid#" data-placement="top" title="Add Link" data-original-title="Add Link">
                                    <i class="fe-plus-circle"></i> Add link
                                </a>
                                <cfif #links.recordcount# is not "0">
                                    <cfloop query="links">
                                        <BR />
                                        <a href="#linkurl#" target="#new_noteid#">#linkname#</a>
                                        <a href="/include/linkdel.cfm?reventid=0&eventid=0&rcontactid=#currentid#&linkid=#links.linkid#&returnurl=contact" title="delete link">
                                            <i class="mdi mdi-trash-can-outline mr-1"></i>
                                        </a>
                                    </cfloop>
                                </cfif>
                            </td>

                            <td class="text-nowrap">
                                <!--- Link to add a new attachment --->
                                <a href="" data-remote="true" data-toggle="modal" data-target="##remoteaddattachment#notesRelationship.noteid#" data-placement="top" title="Add attachment" data-original-title="Add attachment">
                                    <i class="fe-plus-circle"></i> Add attachment
                                </a>
                                <cfif #attachments.recordcount# is not "0">
                                    <cfloop query="attachments">
                                        <BR />
                                        <a href="/include/download.cfm?attachid=#attachid#">#attachname#</a>
                                        <a href="/include/attachmentdel.cfm?attachid=#attachments.attachid#&contactid=#currentid#&returnurl=contact" title="delete attachment">
                                            <i class="mdi mdi-trash-can-outline mr-1"></i>
                                        </a>
                                    </cfloop>
                                </cfif>
                            </td>

                            <td>#notesRelationship.col5#
                                <cfif len(trim(notesRelationship.notedetailshtml))><BR> 
                                    <a href="" data-remote="true" data-toggle="modal" data-target="##remotenotedetails#notesRelationship.noteid#" data-placement="top" title="View Details" data-original-title="View Details">
                                        <i class="mdi mdi-eye-outline"></i> Details
                                    </a>
                                </cfif>
                            </td>

                            <td>
                                <!--- Link to delete the note --->
                                <a title="Delete Note" href="" data-toggle="modal" data-target="##remoteDeleteFormNote#notesRelationship.noteid#">
                                    <i class="mdi mdi-trash-can-outline mr-1"></i>
                                </a>
                            </td>
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
            <div id="accordion_systems" class="mb-3" >
                <cfset k=0 />
                <!--- Loop through notes for mobile display --->
                <cfloop query="notesRelationship">
                    <cfset new_noteID = notesRelationship.noteID />
                    <cfoutput>
                        <cfset k=#k# + 1 />
                    </cfoutput>

                    <cfset cardclass="" />
                    <cfif #notesRelationship.currentrow# is "1">
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
                        <div class="card-header" id="heading_system_<cfoutput>#notesRelationship.currentrow#</cfoutput>">
                            <h5 class="m-0 align-middle w-100">
                                <a class="text-dark collapsed" data-toggle="collapse" href="#collapse_system_<cfoutput>#notesRelationship.currentrow#</cfoutput>" aria-expanded="<cfoutput>#header_aria_exanded#</cfoutput>">
                                    <cfoutput> <strong>#this.formatDate(notesRelationship.noteTimestamp)#</strong> -  #timeformat('#notesRelationship.noteTimestamp#','short')# <i class="fe-menu"></i> </cfoutput>
                                    <span class="badge badge-sm badge-blue badge-pill float-end" style="font-size:.7em;">
                                        <cfoutput>  <cfif #notesRelationship.col4# is "1">Public<cfelse>Private</cfif></cfoutput>
                                    </span>
                                </a>
                            </h5>
                        </div>

                        <div id="collapse_system_<cfoutput>#notesRelationship.currentrow#</cfoutput>" class="<cfoutput>#collapse_show#</cfoutput>" aria-labelledby="collapse_system_<cfoutput>#notesRelationship.currentrow#</cfoutput>" data-parent="#accordion_systems">
                            <div class="card-body">
                                <cfoutput>
                                    <h5>#notesRelationship.noteDetails# 
                                        <a title="Edit" href="/app/note-update-event/?noteid=#notesRelationship.noteid#&returnurl=contact&rcontactid=#currentid#">
                                            <i class="mdi mdi-square-edit-outline"></i>
                                        </a>
                                    </h5>
                                </cfoutput>
                                <cfif #notesRelationship.col4# is not "">
                                    <h6>Who Can See Note?</h6>
                                    <p>
                                        <cfif #notesRelationship.col4# is "1">Public<cfelse>Private</cfif>
                                    </p>
                                </cfif>

                                <cfif #notesRelationship.noteDetailsHTML# is not "">
                                    <h6>Description</h6>
                                    <p><cfoutput>#notesRelationship.noteDetailsHTML#</cfoutput></p>
                                </cfif>
                            </div>
                        </div>
                    </div>
                </cfloop>
            </div>
        </div>
    </div>
</div>

