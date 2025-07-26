<!--- 
    PURPOSE: Display and manage a specific user link panel on the dashboard.
    AUTHOR: Kevin King
    DATE: 2025-07-26
    PARAMETERS: dashboards (query object containing panel info like pnid), userid
    DEPENDENCIES: services.SiteLinksService, /include/modal_generic.cfm
--->
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
    <!--- MODALS (Defined directly) --->
    <cfoutput>
        <!--- Add Link Modal --->
        <div class="modal fade" id="addLinkModal_#siteTypeDetails.sitetypeid#" tabindex="-1" aria-labelledby="addLinkModal_#siteTypeDetails.sitetypeid#Label" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="addLinkModal_#siteTypeDetails.sitetypeid#Label">Add #siteTypeDetails.sitetypename# Link</h5>
                        <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                             <i class="mdi mdi-close-thick"></i>
                        </button>
                    </div>
                    <div class="modal-body">
                        <!-- Content will be loaded here via JavaScript -->
                        <div class="text-center p-4">
                            <div class="spinner-border" role="status">
                                <span class="visually-hidden">Loading...</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!--- Update Link Modal --->
        <div class="modal fade" id="updateLinkModal_#siteTypeDetails.sitetypeid#" tabindex="-1" aria-labelledby="updateLinkModal_#siteTypeDetails.sitetypeid#Label" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="updateLinkModal_#siteTypeDetails.sitetypeid#Label">Update #siteTypeDetails.sitetypename# Link</h5>
                        <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                             <i class="mdi mdi-close-thick"></i>
                        </button>
                    </div>
                    <div class="modal-body">
                        <!-- Content will be loaded here via JavaScript -->
                        <div class="text-center p-4">
                            <div class="spinner-border" role="status">
                                <span class="visually-hidden">Loading...</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!--- Delete Link Modal --->
        <div class="modal fade" id="deleteLinkModal_#siteTypeDetails.sitetypeid#" tabindex="-1" aria-labelledby="deleteLinkModal_#siteTypeDetails.sitetypeid#Label" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="deleteLinkModal_#siteTypeDetails.sitetypeid#Label">Delete #siteTypeDetails.sitetypename# Link</h5>
                        <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                             <i class="mdi mdi-close-thick"></i>
                        </button>
                    </div>
                    <div class="modal-body">
                        <!-- Content will be loaded here via JavaScript -->
                        <div class="text-center p-4">
                            <div class="spinner-border" role="status">
                                <span class="visually-hidden">Loading...</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>

    <!--- Dashboard Card --->
    <cfoutput>
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
                    <div class="link-row d-flex align-items-center" data-link-id="#mylinks_user.id#">
                        
                        <div class="link-icon-container">
                            <img class="link-icon" src="#application.retinaIcons14Url#/#mylinks_user.siteicon#" alt="#mylinks_user.sitename#">
                        </div>
                        
                        <div class="flex-grow-1 link-content">
                            <a href="#mylinks_user.siteurl#" target="_blank" class="link-sitename text-decoration-none" title="Visit #mylinks_user.sitename#">
                                #mylinks_user.sitename#
                            </a>
                        </div>
                        
                        <div class="link-actions">
                            <button class="btn btn-light border btn-xs edit-link-btn" 
                                    data-link-id="#mylinks_user.id#"
                                    data-sitetype-id="#siteTypeDetails.sitetypeid#"
                                    title="Edit Link">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="btn btn-light border btn-xs delete-link-btn" 
                                    data-link-id="#mylinks_user.id#"
                                    data-sitetype-id="#siteTypeDetails.sitetypeid#"
                                    title="Delete Link">
                                <i class="fas fa-trash-alt"></i>
                            </button>
                        </div>
                    </div>
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
<cfoutput>
<script>
$(document).ready(function() {
    var container = $('##linksContainer_#siteTypeDetails.sitetypeid#').closest('.card');

    function handleModalLoad(e, url, modalTarget) {
        e.preventDefault();
        e.stopPropagation();
        
        $(modalTarget).find('.modal-body').html('<div class="text-center p-4"><div class="spinner-border" role="status"><span class="visually-hidden">Loading...</span></div></div>');
        $(modalTarget).modal('show');
        $(modalTarget).find('.modal-body').load(url, function() {
            // Handle form submission for update forms
            $(modalTarget).find('form').on('submit', function(e) {
                e.preventDefault();
                var form = $(this);
                var formData = form.serialize();
                
                $.ajax({
                    url: form.attr('action'),
                    type: 'POST',
                    data: formData,
                    success: function(response) {
                        $(modalTarget).modal('hide');
                        // Refresh the entire links container
                        refreshLinksPanel();
                    },
                    error: function() {
                        alert('Error updating link. Please try again.');
                    }
                });
            });
        });
    }

    function refreshLinksPanel() {
        // Simply reload the current page to refresh all panels
        // This is the safest approach since the panels are tightly integrated with the dashboard loop
        window.location.reload();
    }

    // EDIT LINK
    container.on('click', '.edit-link-btn', function(e) {
        var linkId = $(this).data('link-id');
        var sitetypeId = $(this).data('sitetype-id');
        var modalTarget = `##updateLinkModal_${sitetypeId}`;
        var url = `/include/remotelinkUpdate.cfm?userid=#session.userid#&new_id=${linkId}&target=dashboard_new`;
        handleModalLoad(e, url, modalTarget);
    });

    // DELETE LINK
    container.on('click', '.delete-link-btn', function(e) {
        var linkId = $(this).data('link-id');
        var sitetypeId = $(this).data('sitetype-id');
        var modalTarget = `##deleteLinkModal_${sitetypeId}`;
        var url = `/include/remoteDeleteFormLink.cfm?userid=#session.userid#&new_id=${linkId}&target=dashboard_new`;
        
        e.preventDefault();
        e.stopPropagation();
        
        $(modalTarget).find('.modal-body').html('<div class="text-center p-4"><div class="spinner-border" role="status"><span class="visually-hidden">Loading...</span></div></div>');
        $(modalTarget).modal('show');
        $(modalTarget).find('.modal-body').load(url, function() {
            // Handle delete form submission
            $(modalTarget).find('form').on('submit', function(e) {
                e.preventDefault();
                var form = $(this);
                var formData = form.serialize();
                
                $.ajax({
                    url: form.attr('action'),
                    type: 'POST',
                    data: formData,
                    success: function(response) {
                        $(modalTarget).modal('hide');
                        refreshLinksPanel();
                    },
                    error: function() {
                        alert('Error deleting link. Please try again.');
                    }
                });
            });
        });
    });

    // ADD LINK
    container.on('click', '.add-link-btn', function(e) {
        var sitetypeId = $(this).data('sitetype-id');
        var modalTarget = `##addLinkModal_${sitetypeId}`;
        var url = `/include/remotelinkAdd.cfm?new_sitetypeid=${sitetypeId}&userid=#session.userid#&target=dashboard_new`;
        
        e.preventDefault();
        e.stopPropagation();
        
        $(modalTarget).find('.modal-body').html('<div class="text-center p-4"><div class="spinner-border" role="status"><span class="visually-hidden">Loading...</span></div></div>');
        $(modalTarget).modal('show');
        $(modalTarget).find('.modal-body').load(url, function() {
            // Handle add form submission
            $(modalTarget).find('form').on('submit', function(e) {
                e.preventDefault();
                var form = $(this);
                var formData = form.serialize();
                
                $.ajax({
                    url: form.attr('action'),
                    type: 'POST',
                    data: formData,
                    success: function(response) {
                        $(modalTarget).modal('hide');
                        refreshLinksPanel();
                    },
                    error: function() {
                        alert('Error adding link. Please try again.');
                    }
                });
            });
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
</cfoutput>