<!--- This ColdFusion page handles the display and management of site links for a specific dashboard panel. --->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<style>
/* Link Styles - matching reminder format */
.link-row {
    border: 1px solid #e9ecef;
    border-radius: 6px;
    padding: 8px 12px;
    margin-bottom: 8px;
    background-color: #FFFFFF;
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

/* Initially hide edit buttons */
.link-actions {
    display: none;
}

/* Show edit buttons when edit mode is active */
.edit-mode .link-actions {
    display: block;
}

.links-empty {
    text-align: center;
    padding: 20px;
    color: #6c757d;
    font-style: italic;
}

/* Animation for successful link updates */
.link-row.updating {
    background-color: #d4edda;
    border-color: #c3e6cb;
    animation: pulseUpdate 0.5s ease-in-out;
}

@keyframes pulseUpdate {
    0% { background-color: #ffffff; }
    50% { background-color: #d4edda; }
    100% { background-color: #d4edda; }
}

#linksContainer {
    overflow: hidden;
    background-color: #FFFFFF;
    padding: 12px;
    border-radius: 6px;
}
</style>

<cfset siteLinksService = createObject("component", "services.SiteLinksService")>
<cfset mylinks_user = siteLinksService.getSiteLinksByPanelId(dashboards.pnid, userid)>
<cfset siteurl_list = siteLinksService.getAllUrlsByPanelId(dashboards.pnid, userid)>
<cfset siteTypeDetails = siteLinksService.getSiteTypeDetailsByPanelId(dashboards.pnid, userid)>
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
            <h5 class="m-0 d-flex justify-content-between align-items-center">
                <a class="text-dark collapsed" data-bs-toggle="collapse" href="##collapse_system_#dashboards.currentrow#">
                    #siteTypeDetails.sitetypename# Links
                </a>
                <cfif mylinks_user.recordcount gt 0>
                    <button id="editToggleBtn" onclick="toggleEditMode()" 
                            class="btn btn-sm btn-light border">
                        <i class="fas fa-edit"></i> Edit
                    </button>
                </cfif>
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

                        <!--- Link card row - entire card is clickable --->
                        <a href="#mylinks_user.siteurl#" 
                           target="_blank" 
                           class="link-row d-flex align-items-center text-decoration-none" 
                           data-link-id="#mylinks_user.id#"
                           title="Visit #mylinks_user.sitename#">
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
                                <!--- Edit button --->
                                <button class="btn btn-secondary btn-xs edit-link" 
                                        data-bs-toggle="modal" 
                                        data-bs-target="##updatelink_#mylinks_user.id#"
                                        data-id="#mylinks_user.id#" 
                                        data-sitename="#mylinks_user.sitename#" 
                                        title="Edit Link"
                                        onclick="event.preventDefault(); event.stopPropagation();">
                                    <i class="fas fa-edit"></i>
                                </button>
                            </div>
                        </a>
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
                            class="btn btn-sm btn-light border">
                        <i class="mdi mdi-open-in-new"></i> Open All
                    </button>
                <cfelse>
                    <span class="text-muted small">No links available</span>
                </cfif>
            </div>
            
            <!--- Add Link button on the right --->
            <div>
                <a class="btn btn-sm btn-light border" 
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

        // Handle form submission for link updates via AJAX
        $(document).on('submit', '[id^="updatelink_"] form', function(e) {
            e.preventDefault();
            
            var form = $(this);
            var formData = form.serialize();
            var modal = form.closest('.modal');
            var linkId = modal.attr('id').replace('updatelink_', '');
            
            // Show loading state
            form.find('button[type="submit"]').prop('disabled', true).text('Updating...');
            
            $.ajax({
                url: '/include/remotelinkUpdateUpdate.cfm',
                type: 'POST',
                data: formData,
                success: function(response) {
                    // Close the modal
                    modal.modal('hide');
                    
                    // Update the link in the DOM with green flash
                    updateLinkInDOM(linkId, formData);
                },
                error: function() {
                    alert('Error updating link. Please try again.');
                    form.find('button[type="submit"]').prop('disabled', false).text('Update');
                }
            });
        });

        // Function to update the specific link in the DOM
        function updateLinkInDOM(linkId, formData) {
            var linkRow = $('a[data-link-id="' + linkId + '"]');
            
            // Parse form data to get new values
            var params = new URLSearchParams(formData);
            var newSiteName = params.get('new_siteName');
            var newSiteURL = params.get('new_siteurl');
            
            if (linkRow.length > 0) {
                // Add visual feedback with green flash
                linkRow.addClass('updating');
                
                // Update the link URL
                if (newSiteURL) {
                    // Add https:// if not present
                    var correctedURL = newSiteURL;
                    if (!newSiteURL.startsWith('http://') && !newSiteURL.startsWith('https://')) {
                        correctedURL = 'https://' + newSiteURL;
                    }
                    linkRow.attr('href', correctedURL);
                    linkRow.attr('title', 'Visit ' + (newSiteName || linkRow.find('.link-sitename').text()));
                }
                
                // Update the site name if it's a custom link
                if (newSiteName) {
                    linkRow.find('.link-sitename').text(newSiteName);
                }
                
                // Remove the updating class after animation completes
                setTimeout(function() {
                    linkRow.removeClass('updating');
                }, 1000);
            }
        }

        // Function to show success message (REMOVED - using green flash instead)
        function showSuccessMessage(message) {
            // No longer needed - using green flash animation instead
        }

        // Open all URLs function
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

        // Toggle edit mode function
        window.toggleEditMode = function() {
            var linksContainer = $('#linksContainer');
            var editBtn = $('#editToggleBtn');
            
            if (linksContainer.hasClass('edit-mode')) {
                // Exit edit mode
                linksContainer.removeClass('edit-mode');
                editBtn.html('<i class="fas fa-edit"></i> Edit');
                editBtn.removeClass('btn-warning').addClass('btn-light');
            } else {
                // Enter edit mode
                linksContainer.addClass('edit-mode');
                editBtn.html('<i class="fas fa-times"></i> Done');
                editBtn.removeClass('btn-light').addClass('btn-warning');
            }
        };
    });
</script>