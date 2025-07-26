<!--- This ColdFusion page handles the display and management of site links for a specific dashboard panel. --->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<style>
/* Link Styles - matching reminder format */
.link-row {
    border: 1px solid #e9ecef;
    border-radius: 6px;
    padding: 8px 12px;
    margin-bottom: 8px;
    background-color: #FFFFFF !important;
    transition: all 0.3s ease;
    word-wrap: break-word;
    overflow: hidden;
    position: relative;
    min-height: 48px;
    color: inherit;
}

.link-row:hover {
    border-color: #adb5bd;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    text-decoration: none;
    color: inherit;
}

.link-row:focus {
    outline: 2px solid #007bff;
    outline-offset: 2px;
    text-decoration: none;
    color: inherit;
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
    background-color: #FFFFFF;
    padding: 12px;
    border-radius: 6px;
}
</style>

<cfset siteLinksService = createObject("component", "services.SiteLinksService")>
<cfset panelData = siteLinksService.getPanelData(dashboards.pnid)>
<cfset mylinks_user = panelData.links>
<cfset siteTypeDetails = panelData.details>
<cfset siteurl_list = panelData.urlList>

<cfif structKeyExists(siteTypeDetails, "sitetypeid")>
<cfoutput>
    <!--- MODALS (Defined once) --->
    <!--- Add Link Modal --->
    <cfsavecontent variable="modalContent">
        <cfset modalid = "addLinkModal_#siteTypeDetails.sitetypeid#">
        <cfset modaltitle = "Add #siteTypeDetails.sitetypename# Link">
        <cfinclude template="/include/modal_generic.cfm">
    </cfsavecontent>
    <cfoutput>#modalContent#</cfoutput>
    
    <!--- Update Link Modal --->
    <cfsavecontent variable="modalContent">
        <cfset modalid = "updateLinkModal_#siteTypeDetails.sitetypeid#">
        <cfset modaltitle = "Update #siteTypeDetails.sitetypename# Link">
        <cfinclude template="/include/modal_generic.cfm">
    </cfsavecontent>
    <cfoutput>#modalContent#</cfoutput>

    <!--- Delete Link Modal --->
    <cfsavecontent variable="modalContent">
        <cfset modalid = "deleteLinkModal_#siteTypeDetails.sitetypeid#">
        <cfset modaltitle = "Delete #siteTypeDetails.sitetypename# Link">
        <cfinclude template="/include/modal_generic.cfm">
    </cfsavecontent>
    <cfoutput>#modalContent#</cfoutput>

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
            <div id="linksContainer_#siteTypeDetails.sitetypeid#">
                <cfloop query="mylinks_user">
                    <a href="#mylinks_user.siteurl#" 
                       target="_blank" 
                       class="link-row d-flex align-items-center text-decoration-none" 
                       data-link-id="#mylinks_user.id#"
                       title="Visit #mylinks_user.sitename#">
                        
                        <div class="link-icon-container">
                            <img class="link-icon" src="#application.retinaIcons14Url#/#mylinks_user.siteicon#" alt="#mylinks_user.sitename#">
                        </div>
                        
                        <div class="flex-grow-1 link-content">
                            <div class="link-sitename">#mylinks_user.sitename#</div>
                        </div>
                        
                        <div class="link-actions">
                            <button class="btn btn-light border btn-xs edit-link-btn" 
                                    data-bs-toggle="modal" 
                                    data-bs-target="##updateLinkModal_#siteTypeDetails.sitetypeid#"
                                    data-link-id="#mylinks_user.id#"
                                    data-sitetype-id="#siteTypeDetails.sitetypeid#"
                                    title="Edit Link"
                                    onclick="event.preventDefault(); event.stopPropagation();">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="btn btn-light border btn-xs delete-link-btn" 
                                    data-bs-toggle="modal" 
                                    data-bs-target="##deleteLinkModal_#siteTypeDetails.sitetypeid#"
                                    data-link-id="#mylinks_user.id#"
                                    data-sitetype-id="#siteTypeDetails.sitetypeid#"
                                    title="Delete Link"
                                    onclick="event.preventDefault(); event.stopPropagation();">
                                <i class="fas fa-trash-alt"></i>
                            </button>
                        </div>
                    </a>
                </cfloop>
                
                <cfif mylinks_user.recordcount EQ 0>
                    <div class="links-empty">
                        <center>No active links</center>
                    </div>
                </cfif>
            </div>
        </div>
        
        <div class="card-footer bg-light d-flex justify-content-between align-items-center">
            <div>
                <cfif mylinks_user.recordcount gt 0>
                    <button onclick="openAllUrls('#siteurl_list#')" class="btn btn-sm btn-light border">
                        <i class="mdi mdi-open-in-new"></i> Open All
                    </button>
                <cfelse>
                    <span class="text-muted small">No links available</span>
                </cfif>
            </div>
            
            <div>
                <button class="btn btn-sm btn-light border add-link-btn" 
                   data-bs-toggle="modal" 
                   data-bs-target="##addLinkModal_#siteTypeDetails.sitetypeid#"
                   data-sitetype-id="#siteTypeDetails.sitetypeid#">
                    <i class="fe-plus-circle"></i> Add Link
                </button>
            </div>
        </div>
    </div>
</cfoutput>
<cfelse>
    <div class="alert alert-warning">Link panel could not be loaded. Panel details not found for PNID: #dashboards.pnid#</div>
</cfif>

<script>
$(document).ready(function() {
    // Use a more specific container if possible, otherwise document is fine.
    var container = $('#linksContainer_#siteTypeDetails.sitetypeid#').closest('.card');

    // EDIT LINK
    container.on('click', '.edit-link-btn', function(e) {
        e.preventDefault();
        var linkId = $(this).data('link-id');
        var sitetypeId = $(this).data('sitetype-id');
        var modalTarget = `#updateLinkModal_${sitetypeId}`;
        var url = `/include/remotelinkUpdate.cfm?userid=#userid#&new_id=${linkId}&target=dashboard_new`;
        
        // Load content into the modal body
        $(modalTarget).find('.modal-body').load(url, function() {
            $(modalTarget).modal('show');
        });
    });

    // DELETE LINK
    container.on('click', '.delete-link-btn', function(e) {
        e.preventDefault();
        var linkId = $(this).data('link-id');
        var sitetypeId = $(this).data('sitetype-id');
        var modalTarget = `#deleteLinkModal_${sitetypeId}`;
        var url = `/include/remoteDeleteFormLink.cfm?userid=#userid#&new_id=${linkId}&target=dashboard_new`;

        $(modalTarget).find('.modal-body').load(url, function() {
            $(modalTarget).modal('show');
        });
    });

    // ADD LINK
    container.on('click', '.add-link-btn', function(e) {
        e.preventDefault();
        var sitetypeId = $(this).data('sitetype-id');
        var modalTarget = `#addLinkModal_${sitetypeId}`;
        var url = `/include/remotelinkAdd.cfm?new_sitetypeid=${sitetypeId}&userid=#userid#&target=dashboard_new`;

        $(modalTarget).find('.modal-body').load(url, function() {
            $(modalTarget).modal('show');
        });
    });

    // Function to open all URLs
    window.openAllUrls = function(urls) {
        if (urls) {
            urls.split(',').forEach(function(url) {
                var trimmedUrl = url.trim();
                if (trimmedUrl) {
                    window.open(trimmedUrl, '_blank');
                }
            });
        }
    };
});
</script>
