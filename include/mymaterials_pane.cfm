<!---
================================================================================
MYMATERIALS_PANE.CFM - My Materials Management Interface
================================================================================

Purpose:
This file provides the user interface for managing personal materials within the
TAO Relationship System. It handles the display, addition, updating, and deletion
of user materials such as monologues, songs, and sides that can be used for auditions.

TAO System Integration:
- Part of the user account materials management system
- Provides interface for managing personal audition materials
- Integrates with audition projects for material assignment
- Supports file uploads and URL-based materials

Database Tables:
- audmedia (main materials table)
- events_tbl (for audition associations)
- User-related tables for ownership and permissions

Key Features:
- Add new materials (files or URLs)
- Edit existing materials
- Delete unused materials
- View material usage across auditions
- Download/access material files
- Help information modal

Dependencies:
- jQuery for modal management and DataTables
- Bootstrap for UI components
- ColdFusion for server-side processing
- File upload handling for media files

Modal Components:
- Add Material modal
- Update Material modal
- Delete Material modal
- Help information modal

Author: TAO Development Team
Last Updated: 2025
================================================================================
--->

<!--- ============================================================================ --->
<!--- SECTION 1: INITIALIZATION AND SETUP --->
<!--- ============================================================================ --->

<!--- Parameters and variable initialization --->
<cfparam name="materials" default="" />

<!--- Include core data queries --->
<cfinclude template="/include/qry/materials_sel.cfm" />

<!--- ============================================================================ --->
<!--- SECTION 2: MODAL SETUP --->
<!--- ============================================================================ --->

<!--- Standard modal setup for material management --->
<cfset modalid = "remoteaddMaterial" />
<cfset modaltitle = "Add Material" />
<cfinclude template="/include/modal.cfm" />

<cfset modalid = "remoteDeleteaudmedia" />
<cfset modaltitle = "Delete Material" />
<cfinclude template="/include/modal.cfm" />

<cfset modalid = "remoteupdatematerial" />
<cfset modaltitle = "Update Material" />
<cfinclude template="/include/modal.cfm" />

<!--- ============================================================================ --->
<!--- SECTION 3: HELP MODAL --->
<!--- ============================================================================ --->

<!--- Help information modal --->
<div id="mymaterialshelp" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="standard-modalLabel">My Materials</h4>
                <button type="button" class="close" data-bs-dismiss="modal">
                    <i class="mdi mdi-close-thick"></i>
                </button>
            </div>
            <div class="modal-body">
                <p>There are times when you submit your own monologues, songs, or sides as your audition.</p>
                <p>To add materials in your repertoire to TAO, go to My Account and then Materials.</p>
                <p>Once added, they will appear in this list so you can easily add them to any of your auditions.</p>
            </div>
        </div>
    </div>
</div>

<!--- ============================================================================ --->
<!--- SECTION 4: PAGE HEADER AND CONTROLS --->
<!--- ============================================================================ --->

<!--- Page header with help link --->
<cfoutput>
    <h4 class="p-1 d-flex">
        My Materials &nbsp;&nbsp; 
        <a href="" title="click for details" data-bs-toggle="modal" data-bs-target="##mymaterialshelp">  
            <i class="fe-info font-14 mr-1"></i>
        </a>
    </h4>
</cfoutput>

<!--- Add Material button --->
<cfoutput>
    <div class="col-md-12 col-lg-12 col-xl-12 p-1 d-flex">
        <center>
            <a data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteaddMaterial" 
               class="btn btn-xs btn-primary waves-effect waves-light" title="Add Material">
                Add Material
            </a>
        </center>
    </div>
</cfoutput>

<!--- ============================================================================ --->
<!--- SECTION 5: MATERIALS DATA TABLE --->
<!--- ============================================================================ --->

<!--- Materials data table structure --->
<div class="row pt-3 pb-3">
    <table id="materials_tbl" class="table display nowrap table-striped dataTable w-100 dtr-inline dt-checkboxes-select dt-responsive">
        <thead>
            <tr>
                <th width="50">Action</th>
                <th>Type</th>
                <th>Name</th>
                <th>Filename</th>
                <th>URL</th>
                <th>Created</th>
                <th>Audition</th>
            </tr>
        </thead>
        <tbody>
            <!--- ============================================================================ --->
            <!--- SECTION 6: MATERIALS LOOP AND TABLE ROWS --->
            <!--- ============================================================================ --->
            
            <!--- Loop through materials and generate table rows with associated modals --->
            <cfloop query="materials_sel">
                <!--- Load audition events for this material --->
                <cfinclude template="/include/qry/events_166_1.cfm" />
                <cfset materials = ValueList(events.audprojectid) />
                
                <cfoutput>
                    <!--- ============================================================================ --->
                    <!--- SECTION 7: DYNAMIC MODAL SETUP FOR EACH MATERIAL --->
                    <!--- ============================================================================ --->
                    
                    <!--- JavaScript for dynamic modal initialization --->
                    <script>
                        $(document).ready(function() {
                            // Initialize delete material modal
                            $("##remoteDeleteaudmedia#materials_sel.mediaid#").on("show.bs.modal", function() {
                                $(this).find(".modal-body").load("/include/remoteDeleteaudmedia.cfm?mediaid=#materials_sel.mediaid#&new_secid=196&secid=196");
                            });
                            
                            // Initialize update material modal
                            $("##remoteupdatematerial#materials_sel.mediaid#").on("show.bs.modal", function() {
                                $(this).find(".modal-body").load("/include/remoteupdatematerial.cfm?src=account&mediaid=#materials_sel.mediaid#");
                            });
                        });
                    </script>

                    <!--- Delete Material Modal --->
                    <div id="remoteDeleteaudmedia#materials_sel.mediaid#" class="modal fade" tabindex="-1" role="dialog">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header" style="background-color: red;">
                                    <h4 class="modal-title">Delete Material</h4>
                                    <button type="button" class="close" data-bs-dismiss="modal">
                                        <i class="mdi mdi-close-thick"></i>
                                    </button>
                                </div>
                                <div class="modal-body"></div>
                            </div>
                        </div>
                    </div>

                    <!--- Update Material Modal --->
                    <div id="remoteupdatematerial#materials_sel.mediaid#" class="modal fade" tabindex="-1" role="dialog">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h4 class="modal-title">Update Material</h4>
                                    <button type="button" class="close" data-bs-dismiss="modal">
                                        <i class="mdi mdi-close-thick"></i>
                                    </button>
                                </div>
                                <div class="modal-body"></div>
                            </div>
                        </div>
                    </div>

                    <!--- ============================================================================ --->
                    <!--- SECTION 8: TABLE ROW DATA --->
                    <!--- ============================================================================ --->
                    
                    <!--- Table row for material data --->
                    <tr>
                        <!--- Action column with edit/delete buttons --->
                        <td>
                            <a title="Edit" data-bs-toggle="modal" data-bs-target="##remoteupdatematerial#materials_sel.mediaid#">
                                <i class="mdi mdi-square-edit-outline"></i>
                            </a>
                            <cfif events.recordcount is 0>
                                <a data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteDeleteaudmedia#materials_sel.mediaid#" title="Delete media">
                                    <i class="mdi mdi-trash-can-outline"></i>
                                </a>
                            </cfif>
                        </td>
                        
                        <!--- Material type --->
                        <td class="text-nowrap">#materials_sel.mediaType#</td>
                        
                        <!--- Material name --->
                        <td class="text-nowrap">#materials_sel.mediaName#</td>
                        
                        <!--- Filename with download link --->
                        <td class="text-nowrap">
                            <a href="##" id="downloadLink_#materials_sel.mediaid#" style="text-decoration: underline; color: blue;">
                                #materials_sel.mediaFilename#
                            </a>
                        </td>
                        
                        <!--- URL link (if available) --->
                        <td class="text-nowrap">
                            <cfif materials_sel.mediaurl is not "" and materials_sel.mediaurl is not "https://">
                                <a href="#materials_sel.mediaurl#" target="_blank" style="text-decoration: underline; color: blue;">
                                    #materials_sel.mediaurl#
                                </a>
                            </cfif>
                        </td>
                        
                        <!--- Created date and time --->
                        <td class="text-nowrap">
                            #this.formatDate(materials_sel.mediacreated)#<br />
                            #timeformat(materials_sel.mediacreated, 'medium')#
                        </td>
                        
                        <!--- Audition count with link --->
                        <td class="text-nowrap">
                            <cfif events.recordcount neq 0>
                                <a href="/app/auditions/?materials=#materials#" style="text-decoration: underline; color: blue;">
                                    #events.recordcount#
                                </a>
                            <cfelse>
                                0
                            </cfif>
                        </td>
                    </tr>

                    <!--- ============================================================================ --->
                    <!--- SECTION 9: DOWNLOAD FUNCTIONALITY --->
                    <!--- ============================================================================ --->
                    
                    <!--- Download link functionality --->
                    <script type="text/javascript">
                        document.getElementById('downloadLink_#materials_sel.mediaid#').addEventListener('click', function(e) {
                            e.preventDefault();
                            const host = '#host#';
                            const userid = '#userid#';
                            const mediafilename = '#materials_sel.mediafilename#';
                            window.location.href = '/include/mediadownload.cfm?host=' + host + '&userid=' + userid + '&mediafilename=' + mediafilename;
                        });
                    </script>
                </cfoutput>
            </cfloop>
        </tbody>
    </table>
</div>
<!--- ============================================================================ --->
<!--- SECTION 10: JAVASCRIPT INITIALIZATION --->
<!--- ============================================================================ --->

<!--- Main JavaScript initialization and DataTable setup --->
<cfoutput>
    <script>
        $(document).ready(function() {
            // Initialize Add Material modal
            $("##remoteaddMaterial").on("show.bs.modal", function() {
                $(this).find(".modal-body").load("/include/remoteaddMaterial.cfm?userid=#userid#&src=account&new_isshare=1");
            });
            
            // Initialize DataTable with responsive settings
            var table = $('##materials_tbl').DataTable({
                responsive: true,
                ordering: true,
                searching: true
            });
            
            // Adjust DataTable columns when tab is shown (for responsive layout)
            $('a[data-bs-toggle="tab"]').on('shown.bs.tab', function(e) {
                table.columns.adjust();
            });
        });
    </script>
</cfoutput>
