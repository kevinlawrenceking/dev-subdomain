<!---
TAO Relationship System - Dashboard Management Interface
Purpose: Main dashboard interface for managing user notifications and dashboard panels
System Integration: Handles batch notification operations and dynamic grid layouts for dashboard widgets
Components: Notification management, panel organization, batch operations (complete/skip), URL management
Tables: funotifications, fusystemusers, fuactions, pgpanels_user, actionusers, notstatuses
Services: NotificationService for handling notification operations and batch processing
--->

<!--- Parameter Definitions for Dashboard State --->
<cfparam name="batchlist" default="0" />
<cfparam name="pgaction" default="View" />
<cfparam name="nots_total" default="0" />

<!--- Parameter Definitions for Panel Management --->
<cfparam name="new_sitetypeid" default="0" />
<cfparam name="target_id" default="0" />
<cfparam name="ctaction" default="view" />
<cfparam name="quoteoftheday" default="" />

<!--- Initialize Services --->
<cfset notificationService = createObject("component", "services.NotificationService") />

<!--- Batch Notification Processing Logic --->
<cfif pgaction is "batch" AND batchlist is not "0">
    <cfset cnotsconfirm = notificationService.getNotificationsByBatchlist(batchlist) />

    <!--- Batch Confirmation Modal --->
    <div id="batchconfirm" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title">
                        <cfoutput>Batch #batchtype# confirmation</cfoutput>
                    </h4>
                    <button type="button" class="close" data-bs-dismiss="modal">
                        <i class="mdi mdi-close-thick"></i>
                    </button>
                </div>
                <div class="modal-body">
                    <cfoutput>
                        <form action="/include/batch#batchtype#.cfm">
                            <input type="hidden" name="batchlist" value="#batchlist#" />
                            <center>
                                You are about to #batchtype# #numberformat(cnotsconfirm.recordcount)# reminders.
                            </center>
                            <p>&nbsp;</p>
                            <center>
                                <input type="submit" value="Confirm" class="btn btn-primary btn-sm" />
                            </center>
                        </form>
                    </cfoutput>
                </div>
            </div>
        </div>
    </div>

    <!--- Reset page action after modal display --->
    <cfset pgaction = "view" />
</cfif>

<!--- Panel Add Modal Configuration --->
<cfset modalid = "paneladd" />
<cfset modaltitle = "Custom Panel Add" />
<cfinclude template="/include/modal.cfm" />

<!--- Dashboard Grid Layout --->
<style>
/* Ensure all dashboard panels have solid white backgrounds */
.grid-item {
    background-color: #FFFFF0 !important;
}
</style>

<div class="packery-grid" data-packery='{ "itemSelector": ".grid-item", "gutter": 10 }'>
    <!--- Dynamic Dashboard Panel Loading --->
    <cfloop query="dashboards">
        <cfinclude template="/include/#dashboards.pnFilename#" />
    </cfloop>
</div>

<!--- Packery Grid JavaScript for Dashboard Layout Management --->
<script>
    console.log("Before Packery");

    function initializePackery() {
        var isMobile = window.matchMedia("(max-width: 768px)").matches;
        
        <!--- Configure Packery options based on device type --->
        var packeryOptions = isMobile ? {
            itemSelector: '.grid-item',
            gutter: 10,
            percentPosition: true
        } : {
            itemSelector: '.grid-item',
            gutter: 10,
            fitWidth: true,
            resizable: true,
            columnWidth: '.grid-item',
            percentPosition: true
        };

        var $grid = $('.packery-grid').packery(packeryOptions);

        <!--- Enable drag-and-drop only for non-mobile devices --->
        if (!isMobile) {
            $grid.find('.grid-item').each(function(i, gridItem) {
                var draggie = new Draggabilly(gridItem);
                $grid.packery('bindDraggabillyEvents', draggie);
            });

            <!--- Save dashboard layout changes via AJAX --->
            $grid.on('dragItemPositioned', function() {
                var newOrder = [];
                
                $grid.packery('getItemElements').forEach(function(itemElem) {
                    var id = $(itemElem).attr('data-id');
                    newOrder.push(id);
                });

                $.ajax({
                    url: '/include/update_order.cfm',
                    type: 'POST',
                    data: { order: newOrder.join(',') },
                    success: function(response) {
                        console.log('Updated successfully:', response);
                    },
                    error: function() {
                        console.log('Failed to update order');
                    }
                });
            });
        }
    }

    <!--- Initialize Packery on page load --->
    initializePackery();

    <!--- Re-initialize Packery on window resize --->
    $(window).resize(function() {
        initializePackery();
    });
    
    console.log("After Packery");
</script>

<!--- Utility Function for Batch URL Opening --->
<script>
    function openAllUrls(siteurl_list) {
        const urls = siteurl_list.split(',');
        console.log(`Attempting to open ${urls.length} URLs`);
        
        let delay = 0;

        urls.forEach((url, index) => {
            const trimmedUrl = url.trim();
            console.log(`Queuing URL ${index + 1}: ${trimmedUrl}`);

            setTimeout(() => {
                console.log(`Opening URL ${index + 1}: ${trimmedUrl}`);
                try {
                    const newWindow = window.open(trimmedUrl, '_blank');
                    if (newWindow === null) {
                        console.warn(`Failed to open ${trimmedUrl}`);
                    } else {
                        console.log(`Successfully opened ${trimmedUrl}`);
                    }
                } catch (e) {
                    console.error(`An error occurred while trying to open ${trimmedUrl}: ${e.message}`);
                }
            }, delay);

            <!--- Increase delay for the next URL to prevent popup blocking --->
            delay += 500;
        });
    }
</script>

