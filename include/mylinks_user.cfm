<!--- This ColdFusion page handles the display and management of site links for a specific dashboard panel. --->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<style>
/* Link Styles - matching reminder format */
.link-row {
    border: 1px solid #e9ecef;
    border-radius: 6px;
    padding: 8px 12px;
    margin-bottom: 8px;
    background-color: #ffffff;
    transition: all 0.3s ease;
    word-wrap: break-word;
    overflow: hidden;
    position: relative;
    min-height: 48px;
}

.link-row:hover {
    border-color: #adb5bd;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.link-icon-container {
    display: flex;
    align-items: center;
    margin-right: 12px;
    min-width: 32px;
    height: 32px;
}

.link-icon {
    max-width: 32px;
    max-height: 32px;
    width: auto;
    height: auto;
    object-fit: contain;
}

.link-content {
    display: flex;
    flex-direction: column;
    justify-content: center;
    min-height: 32px;
}

.link-sitename {
    font-weight: 600;
    color: #495057;
    font-size: 14px;
    line-height: 1.3;
}

.link-actions .btn {
    padding: 2px 6px;
    font-size: 11px;
    border-radius: 3px;
    margin-left: 4px;
}

.link-actions .btn i {
    font-size: 10px;
}

.links-empty {
    text-align: center;
    padding: 20px;
    color: #6c757d;
    font-style: italic;
}

#linksContainer {
    overflow: hidden;
}
</style>

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
            <!--- Container for links with similar styling to reminders --->
            <div id="linksContainer">
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

                        <!--- Link card row --->
                        <div class="link-row d-flex align-items-center" data-link-id="#mylinks_user.id#">
                            <!--- Icon on the left (full height) --->
                            <div class="link-icon-container">
                                <img class="link-icon" 
                                     id="icon_#mylinks_user.id#" 
                                     src="#application.retinaIcons14Url#/#mylinks_user.siteicon#" 
                                     alt="#mylinks_user.sitename#" />
                            </div>
                            
                            <!--- Site name in the middle --->
                            <div class="flex-grow-1 link-content">
                                <div class="link-sitename">#mylinks_user.sitename#</div>
                            </div>
                            
                            <!--- Action buttons on the right --->
                            <div class="link-actions">
                                <!--- Link button --->
                                <a href="#mylinks_user.siteurl#" 
                                   target="_blank" 
                                   class="btn btn-primary btn-xs" 
                                   title="Visit #mylinks_user.sitename#">
                                    <i class="fas fa-external-link-alt"></i>
                                </a>
                                <!--- Edit button 
                                <button class="btn btn-secondary btn-xs edit-link" 
                                        data-id="#mylinks_user.id#" 
                                        data-sitename="#mylinks_user.sitename#" 
                                        title="Edit Link">
                                    <i class="fas fa-edit"></i>
                                </button> --->
                            </div>
                        </div>
                    </cfoutput>
                </cfloop>
                
                <!--- Show message if no links --->
                <cfif mylinks_user.recordcount EQ 0>
                    <div class="links-empty">
                        <center>No active links</center>
                    </div>
                </cfif>
            </div>
        </div><!--- card-body end --->
        
        <div class="card-footer bg-light d-flex justify-content-between align-items-center">
            <!--- Open All button on the left --->
            <div>
                <cfif mylinks_user.recordcount gt 0>
                    <button onclick="openAllUrls('#siteurl_list#')" 
                            class="btn btn-sm btn-outline-secondary">
                        <i class="mdi mdi-open-in-new"></i> Open All
                    </button>
                <cfelse>
                    <span class="text-muted small">No links available</span>
                </cfif>
            </div>
            
            <!--- Add Link button on the right --->
            <div>
                <a class="btn btn-sm btn-primary" 
                   href="addlink.cfm" 
                   data-bs-remote="true" 
                   data-bs-toggle="modal" 
                   data-bs-target="##addlink_#siteTypeDetails.sitetypeid#">
                    <i class="fe-plus-circle"></i> Add Link
                </a>
            </div>
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
