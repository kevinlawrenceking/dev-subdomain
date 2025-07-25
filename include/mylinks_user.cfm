<!--- This ColdFusion page handles the display and management of site links for a specific dashboard panel. --->
<cfset siteLinksService = createObject("component", "services.SiteLinksService")>
<cfset mylinks_user = siteLinksService.getSiteLinksByPanelId(dashboards.pnid)>
<cfset siteurl_list = siteLinksService.getAllUrlsByPanelId(dashboards.pnid)>
<cfset siteTypeDetails = siteLinksService.getSiteTypeDetailsByPanelId(dashboards.pnid)>
<cfoutput>

    <!--- Set modal ID and title for adding a link --->
    <cfset modalid = "addlink_#siteTypeDetails.sitetypeid#" />
    <cfset modaltitle = "Add #mylinks_user.pntitle#" />
    
    <cfinclude template="/include/modal.cfm" />

    <!--- Modal for adding a link --->
    <div id="addlink_#siteTypeDetails.sitetypeid#" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header" >
                    <h4 class="modal-title" id="standard-modalLabel">Add #mylinks_user.pntitle#</h4>
                    <button type="button" class="close" data-bs-dismiss="modal" >

                        <i class="mdi mdi-close-thick"></i>
                    </button>
                </div>
                <div class="modal-body"></div>
            </div>
        </div>
    </div>

    <!--- Dashboard Card --->
    <div class="card grid-item loaded" data-id="#dashboards.pnid#">
        <div class="card-header" id="heading_system_#dashboards.currentrow#">
            <h5 class="m-0">
                <a class="text-dark collapsed" data-bs-toggle="collapse" href="##collapse_system_#dashboards.currentrow#">
                    #siteTypeDetails.sitetypename# Links
                </a>
            </h5>
        </div>
        <div class="card-body">
            <div class="row">
                <!--- Loop through site links --->
                <cfloop query="mylinks_user">
                    <cfoutput>

                        <!--- Set modal ID and title for updating a link --->
                        <cfset modalid = "updatelink_#mylinks_user.id#" />
                        <cfset modaltitle = "#siteTypeDetails.sitetypename# Link Update" />
                        <cfinclude template="/include/modal.cfm" />

                        <!--- Set modal ID and title for deleting a link --->
                        <cfset modalid = "remoteDeleteLink_#mylinks_user.id#" />
                        <cfset modaltitle = "#siteTypeDetails.sitetypename# Link Delete" />
                        <cfinclude template="/include/modal.cfm" />

                        <div class="col-md-12">
                            <a href="#mylinks_user.siteurl#" class="text-reset font-14 py-1 px-1 d-inline-block" target="#mylinks_user.sitename#" title="#mylinks_user.sitename#">
                                <img class="site-icon" id="icon_#mylinks_user.id#" src="#application.retinaIcons14Url#/#mylinks_user.siteicon#" style="width:14px;" />
                                #mylinks_user.sitename#
                            </a> 

                            <span id="edit_#mylinks_user.id#" class="hide-edit-icon" data-card-id="#dashboards.pnid#">
                                <a title="Edit" href="" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##updatelink_#mylinks_user.id#">
                                    <i class="mdi mdi-square-edit-outline"></i>
                                </a>
                                <a class="pt-0" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteDeleteLink_#mylinks_user.id#" data-bs-placement="top" data-bs-original-title="Delete link" title="Remove #mylinks_user.sitename#" class="pl-1" style="color:red;">
                                    <i class="mdi mdi-trash-can-outline"></i>
                                </a>
                            </span>
                        </div>
                    </cfoutput>
                </cfloop>
                <cfoutput>
                    <div class="col-md-12 col-lg-12">
                        <!--- Check if there are any active links --->
                        <cfif mylinks_user.recordcount gt 0>
                            <button onclick="openAllUrls('#siteurl_list#')" style="border: 1px solid ##406E8E!important; outline: none!important; color: ##406E8E!important;" class="badge badge-light text-dark">
                                <i class="mdi mdi-book-plus-multiple"></i> Open Allz
                            </button>
                        <cfelse>
                            <center>No active links</center>
                        </cfif>
                    </div>
                </cfoutput>
            </div>
        </div><!--- card-body end --->
        
        <div class="card-footer bg-light d-flex justify-content-between">
            <cfif mylinks_user.recordcount gt 0>
                <button class="btn btn-link toggle_edit_mode" data-card-id="#dashboards.pnid#">
                    <i class="mdi mdi-square-edit-outline"></i>
                </button>
            </cfif>
            <a class="btn btn-link" href="addlink.cfm" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##addlink_#siteTypeDetails.sitetypeid#">
                <i class="fe-plus-circle"></i>
            </a>
        </div><!--- end card footer --->
    </div><!--- end card --->
</cfoutput>

<script>
    $(document).ready(function () {
        <cfoutput>
            <!--- Loop through site links to setup modals for update and delete actions --->
            <cfloop query="mylinks_user">
                setupModalLoading("updatelink_#mylinks_user.id#", "/include/remotelinkUpdate.cfm", "userid=#userid#&new_id=#mylinks_user.new_id#&target=dashboard_new");
                setupModalLoading("remoteDeleteLink_#mylinks_user.id#", "/include/remoteDeleteFormLink.cfm", "userid=#userid#&new_id=#mylinks_user.new_id#&target=dashboard_new");
            </cfloop>
            setupModalLoading("addlink_#siteTypeDetails.sitetypeid#", "/include/remotelinkAdd.cfm", "application.retinaIcons14Path=#URLEncodedFormat(application.retinaIcons14Path)#&new_sitetypeid=#siteTypeDetails.sitetypeid#&userid=#userid#&target=dashboard_new");
        </cfoutput>
    });
</script>
