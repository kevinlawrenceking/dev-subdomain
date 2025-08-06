<!--- 
    My Links Pane - Personal Link Management Interface
    
    This file provides a personalized links management interface for the TAO Relationship System.
    It allows users to organize and manage their custom links organized by site types in an
    accordion-style interface with collapsible panels.
    
    Part of: TAO Relationship System - Dashboard/Maintenance Module
    
    Key Features:
    - Displays user's custom links organized by site types
    - Provides accordion-style collapsible panels for each site type
    - Allows adding, editing, and removing custom links
    - Supports panel title customization
    - Includes restore functionality for deleted links
    
    Database Tables:
    - sitetypes: Contains site type definitions and categories
    - mylinks: User's custom links with site type associations
    - actionusers_tbl: User account information
    
    Related Files:
    - /include/qry/sitetypes_535_1.cfm: Retrieves site types for user
    - /include/qry/mylinks_159_1.cfm: Retrieves all user links
    - /include/qry/mylinks_user_164_2.cfm: User-specific links by site type
    - /include/qry/mylinks_user_del_164_3.cfm: Deleted links for restore
    - /include/qry/master_164_4.cfm: Master data for validation
    - /include/modal.cfm: Standard modal template
    - /include/remotePanelAdd.cfm: Add panel form
    - /include/remotelinkAdd.cfm: Add link form
    - /include/remoteheadingupdate.cfm: Update panel title form
    - /include/remotelinkUpdate.cfm: Update link form
--->

<!--- ============================================================================ --->
<!--- SECTION 1: INITIALIZATION AND DATA RETRIEVAL --->
<!--- ============================================================================ --->

<!--- Load core data queries --->
<cfinclude template="/include/qry/sitetypes_535_1.cfm" />
<cfinclude template="/include/qry/mylinks_159_1.cfm" />

<!--- ============================================================================ --->
<!--- SECTION 2: JAVASCRIPT INITIALIZATION FOR MODALS --->
<!--- ============================================================================ --->

<!--- Initialize panel add modal --->
<cfoutput>
    <script>
        $(document).ready(function() {
            $("##paneladd").on("show.bs.modal", function(event) {
                <!--- Load the HTML for adding a new panel into the modal body --->
                $(this).find(".modal-body").load("/include/remotePanelAdd.cfm?userid=#userid#&pgrtn=P");
            });
        });
    </script>
</cfoutput>

<!--- ============================================================================ --->
<!--- SECTION 3: MODAL SETUP FOR SITE TYPES --->
<!--- ============================================================================ --->

<!--- Create modals and JavaScript handlers for each site type --->
<cfloop query="sitetypes">
    <cfoutput>
        <!--- JavaScript for add link modal --->
        <script>
            $(document).ready(function() {
                $("##addlink_#sitetypes.sitetypeid#").on("show.bs.modal", function(event) {
                    <!--- Load the HTML for adding a new link into the modal body --->
                    $(this).find(".modal-body").load("/include/remotelinkAdd.cfm?new_sitetypeid=#sitetypes.sitetypeid#&userid=#userid#");
                });
            });
        </script>

        <!--- Add link modal setup --->
        <cfset modalid="addlink_#sitetypes.sitetypeid#" />
        <cfset modaltitle="Add Custom #sitetypes.sitetypename# Link" />
        <cfinclude template="/include/modal.cfm" />

        <!--- JavaScript for update heading modal --->
        <script>
            $(document).ready(function() {
                $("##updateheading#sitetypes.sitetypeid#").on("show.bs.modal", function(event) {
                    <!--- Load the HTML for updating the panel title into the modal body --->
                    $(this).find(".modal-body").load("/include/remoteheadingupdate.cfm?new_sitetypeid=#sitetypes.sitetypeid#&userid=#userid#");
                });
            });
        </script>

        <!--- Update heading modal setup --->
        <cfset modalid="updateheading#sitetypes.sitetypeid#" />
        <cfset modaltitle="Update Panel Title" />
        <cfinclude template="/include/modal.cfm" />
    </cfoutput>
</cfloop>

<!--- ============================================================================ --->
<!--- SECTION 4: MODAL SETUP FOR INDIVIDUAL LINKS --->
<!--- ============================================================================ --->

<!--- Create modals and JavaScript handlers for each link --->
<cfloop query="mylinks">
    <cfoutput>
        <!--- JavaScript for update link modal --->
        <script>
            $(document).ready(function() {
                $("##updatelink_#mylinks.id#").on("show.bs.modal", function(event) {
                    <!--- Load the HTML for updating a link into the modal body --->
                    $(this).find(".modal-body").load("/include/remotelinkUpdate.cfm?new_id=#mylinks.id#");
                });
            });
        </script>

        <!--- Update link modal setup --->
        <cfset modalid="updatelink_#mylinks.id#" />
        <cfset modaltitle="#mylinks.sitetypename# Link Update" />
        <cfinclude template="/include/modal.cfm" />
    </cfoutput>
</cfloop>

<!--- Panel add modal setup --->
<cfset modalid="paneladd" />
<cfset modaltitle="Custom Panel Add" />
<cfinclude template="/include/modal.cfm" />

<!--- ============================================================================ --->
<!--- SECTION 5: MAIN INTERFACE - LINKS MANAGEMENT --->
<!--- ============================================================================ --->

<div class="row">
    <div class="col-xl-12">
        <!--- Main action buttons --->
        <button type="button" class="btn btn-xs btn-primary waves-effect mb-2 waves-light" 
                href="addlink.cfm" data-bs-remote="true" data-bs-toggle="modal" 
                data-bs-target="#paneladd" title="Add Custom Panel">
            Add Panel
        </button>

        <!--- Dashboard preferences link --->
        <span class="float-end">
            <a title="Edit" href="/include/dashboardupdate.cfm" data-bs-remote="true" 
               data-bs-toggle="modal" data-bs-target="#dashboardupdate">
                Dashboard preferences <i class="mdi mdi-square-edit-outline"></i>
            </a>
        </span>

        <!--- ============================================================================ --->
        <!--- SECTION 6: ACCORDION INTERFACE FOR SITE TYPES --->
        <!--- ============================================================================ --->

        <div id="accordion" class="mb-1">
            <cfset z = 0 />
            
            <!--- Loop through each site type to create accordion panels --->
            <cfloop query="sitetypes">
                <!--- Set current site type variables --->
                <cfset current_sitetypeid = sitetypes.sitetypeid />
                <cfset current_sitetypename = sitetypes.sitetypename />
                
                <!--- Increment counter and set target for first panel --->
                <cfoutput>
                    <cfset z = #z# + 1 />
                </cfoutput>
                
                <cfif z is 1>
                    <cfoutput>
                        <cfparam name="target_id" default="#sitetypes.sitetypeid#" />
                    </cfoutput>
                </cfif>

                <!--- Load data for current site type --->
                <cfinclude template="/include/qry/mylinks_user_164_2.cfm" />
                <cfinclude template="/include/qry/mylinks_user_del_164_3.cfm" />
                <cfinclude template="/include/qry/master_164_4.cfm" />

                <!--- Determine if this site type can be deleted --->
                <cfif master.recordcount is 0>
                    <cfset deletable = "Y" />
                <cfelse>
                    <cfset deletable = "N" />
                </cfif>

                <!--- ============================================================================ --->
                <!--- SECTION 7: RENDER ACCORDION PANEL FOR CURRENT SITE TYPE --->
                <!--- ============================================================================ --->

                <!--- Render expanded panel (first/target panel) --->
                <cfif sitetypes.sitetypeid is target_id>
                    <cfoutput>
                        <div class="card mb-1">
                            <div class="card-header" id="heading#sitetypes.sitetypeid#">
                                <h5 class="m-0">
                                    <a class="text-dark" data-bs-toggle="collapse" 
                                       href="##collapse#sitetypes.sitetypeid#" aria-expanded="true">
                                        #sitetypes.sitetypename#
                                    </a>
                                    
                                    <!--- Edit title button --->
                                    <a title="Edit Title" href="" data-bs-remote="true" 
                                       data-bs-toggle="modal" data-bs-target="##updateheading#sitetypes.sitetypeid#">
                                        <i class="mdi mdi-square-edit-outline"></i>
                                    </a>

                                    <!--- Delete button (if allowed) --->
                                    <cfif mylinks_user.recordcount is 0 and deletable is "y">
                                        <a title="Remove #current_sitetypename#" class="pl-1" style="color:red;" 
                                           href="/include/excludesitetype.cfm?current_sitetypeid=#current_sitetypeid#&target_id=#current_sitetypeid#">
                                            <i class="mdi mdi-trash-can-outline"></i>
                                        </a>
                                    </cfif>
                                    
                                    <!--- Link count badge --->
                                    <a class="text-dark" data-bs-toggle="collapse" 
                                       href="##collapse#sitetypes.sitetypeid#" aria-expanded="true">
                                        <span class="badge badge-blue badge-pill float-end">
                                            #numberformat(mylinks_user.recordcount)#
                                        </span>
                                    </a>
                                </h5>
                            </div>
                            <!--- end card-header --->

                            <div id="collapse#sitetypes.sitetypeid#" class="collapse show" 
                                 aria-labelledby="heading#sitetypes.sitetypeid#" data-bs-parent="##accordion">
                    </cfoutput>
                
                <!--- Render collapsed panel (non-target panels) --->
                <cfelse>
                    <cfoutput>
                        <div class="card mb-1">
                            <div class="card-header" id="heading#sitetypes.sitetypeid#">
                                <h5 class="m-0">
                                    <a class="text-dark collapsed" data-bs-toggle="collapse" 
                                       href="##collapse#sitetypes.sitetypeid#" aria-expanded="false">
                                        #sitetypes.sitetypename#
                                    </a>
                                    
                                    <!--- Edit title button --->
                                    <a title="Edit Title" href="" data-bs-remote="true" 
                                       data-bs-toggle="modal" data-bs-target="##updateheading#sitetypes.sitetypeid#">
                                        <i class="mdi mdi-square-edit-outline"></i>
                                    </a>

                                    <!--- Delete button (if allowed) --->
                                    <cfif mylinks_user.recordcount is 0 and deletable is "y">
                                        <a title="Remove #current_sitetypename#" class="pl-1" style="color:red;" 
                                           href="/include/excludesitetype.cfm?current_sitetypeid=#current_sitetypeid#&target_id=#current_sitetypeid#">
                                            <i class="mdi mdi-trash-can-outline"></i>
                                        </a>
                                    </cfif>
                                    
                                    <!--- Link count badge --->
                                    <a class="text-dark collapsed" data-bs-toggle="collapse" 
                                       href="##collapse#sitetypes.sitetypeid#" aria-expanded="false">
                                        <span class="badge badge-blue badge-pill float-end">
                                            #numberformat(mylinks_user.recordcount)#
                                        </span>
                                    </a>
                                </h5>
                            </div>

                            <div id="collapse#sitetypes.sitetypeid#" class="collapse" 
                                 aria-labelledby="heading#sitetypes.sitetypeid#" data-bs-parent="##accordion">
                    </cfoutput>
                </cfif>

                <!--- ============================================================================ --->
                <!--- SECTION 8: PANEL CONTENT - LINKS AND ACTIONS --->
                <!--- ============================================================================ --->

                <div class="card-body">
                    <!--- Add custom link button --->
                    <cfoutput>
                        <button type="button" class="btn btn-xs btn-primary waves-effect mb-2 waves-light" 
                                style="background-color: ##406e8e; border: ##406e8e" 
                                href="addlink.cfm" data-bs-remote="true" data-bs-toggle="modal" 
                                data-bs-target="##addlink_#sitetypes.sitetypeid#">
                            Add Custom
                        </button>
                    </cfoutput>

                    <!--- Display user's links for this site type --->
                    <div class="row">
                        <cfloop query="mylinks_user">
                            <div class="col-md-6 col-lg-4">
                                <cfoutput>
                                    <h5 id="item#mylinks_user.id#">
                                        <!--- Edit link --->
                                        <a title="Edit" href="updateuserlink.cfm" data-bs-remote="true" 
                                           data-bs-toggle="modal" data-bs-target="##updatelink_#mylinks_user.id#">
                                            <img src="#application.retinaIcons14Url#/#mylinks_user.siteicon#" width="14px" /> 
                                            #mylinks_user.sitename# 
                                            <cfif mylinks_user.ver is not ""> (#mylinks_user.ver#)</cfif>
                                            <i class="mdi mdi-square-edit-outline"></i>
                                        </a>
                                        
                                        <!--- Delete link --->
                                        <a title="Remove #mylinks_user.sitename#" class="pl-1" style="color:red;" 
                                           href="/include/excludelink.cfm?new_id=#mylinks_user.id#&target_id=#sitetypes.sitetypeid#">
                                            <i class="mdi mdi-trash-can-outline"></i>
                                        </a>
                                    </h5>
                                </cfoutput>
                            </div><!--- end col-md-6 col-lg-4 --->
                        </cfloop>
                    </div><!--- end row --->

                    <!--- Restore deleted links section --->
                    <cfif mylinks_user_del.recordcount is not 0>
                        <form action="/include/linkinclude.cfm">
                            <cfoutput>
                                <input type="hidden" name="target_id" value="#target_id#" />
                            </cfoutput>
                            <h5>Restore:
                                <select name="new_id" id="<cfoutput>new_id_#sitetypes.sitetypeid#</cfoutput>" 
                                        required onchange='this.form.submit()'>
                                    <option value=""></option>
                                    <cfoutput query="mylinks_user_del">
                                        <option value="#mylinks_user_del.id#">#mylinks_user_del.sitename#</option>
                                    </cfoutput>
                                </select>
                            </h5>
                        </form>
                    </cfif>
                </div><!--- end card-body --->
                
                <!--- Close the panel div --->
                </div><!--- end collapse div --->
                </div><!--- end card --->
            </cfloop>
        </div><!--- end accordion --->
    </div><!--- end col-xl-12 --->
</div><!--- end row --->

