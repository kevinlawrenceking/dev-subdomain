<!--- This ColdFusion page manages user dashboards and handles batch notifications, including modal confirmations and dynamic grid layouts. --->

<cfparam name="batchlist" default="0"/>
<cfparam name="new_sitetypeid" default="0"/>
<cfparam name="quoteoftheday" default=""/>
<cfparam name="target_id" default="0">
<cfparam name="ctaction" default="view">
<cfparam name="pgaction" default="View"/>
<cfparam name="nots_total" default="0"/>

<cfset notificationService = createObject("component", "services.NotificationService")>

<!--- Check if the page action is batch and batchlist is not zero --->
<cfif pgaction is "batch" AND batchlist is not "0">
  <cfset cnotsconfirm = notificationService.getNotificationsByBatchlist(batchlist)>

  <div id="batchconfirm" class="modal fade" tabindex="-1" role="dialog" >

    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h4 class="modal-title">
            <cfoutput>Batch #batchtype# confirmation</cfoutput>
          </h4>
          <button type="button" class="close" data-bs-dismiss="modal" >

            <i class="mdi mdi-close-thick"></i>
          </button>
        </div>
        <div class="modal-body">
          <cfoutput>
            <form action="/include/batch#batchtype#.cfm">
              <input type="hidden" name="batchlist" value="#batchlist#"/>
              <center>You are about to #batchtype# #numberformat(cnotsconfirm.recordcount)# reminders.</center>
              <p>&nbsp;</p>
              <center><input type="submit" value="Confirm" class="btn btn-primary btn-sm"/></center>
            </form>
          </cfoutput>
        </div>
      </div>
    </div>
  </div>

  <cfset pgaction = "view"/>
</cfif>

<cfset modalid = "paneladd" />
<cfset modaltitle = "Custom Panel Add" />

<cfinclude template="/include/modal.cfm" />

<div class="packery-grid" data-packery='{ "itemSelector": ".grid-item", "gutter": 10 }'>
  <!--- Loop through dashboards and include their templates --->
  <cfloop query="dashboards">

    <cfinclude template="/include/#dashboards.pnFilename#"/>
  </cfloop>
</div>

<script>
console.log("Before Packery");

function initializePackery() {
  var isMobile = window.matchMedia("(max-width: 768px)").matches;
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

  if (!isMobile) {
    // Make all items draggable only if not mobile
    $grid.find('.grid-item').each(function(i, gridItem) {
      var draggie = new Draggabilly(gridItem);
      $grid.packery('bindDraggabillyEvents', draggie);
    });

    $grid.on('dragItemPositioned', function() {
      // Create an array to store the new order
      var newOrder = [];

      // Iterate over each item and push its data-id to the array
      $grid.packery('getItemElements').forEach(function(itemElem) {
        var id = $(itemElem).attr('data-id');
        newOrder.push(id);
      });

      // Send the new order to the server via AJAX
      $.ajax({
        url: '/include/update_order.cfm', // your ColdFusion script
        type: 'POST',
        data: { order: newOrder.join(',') }, // send as comma-separated list
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

// Initialize Packery on page load
initializePackery();

// Re-initialize Packery on window resize
$(window).resize(function() {
  initializePackery();
});
console.log("After Packery");
</script>

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

        // Increase delay for the next URL
        delay += 500; // 500ms delay between opening each URL
    });
}
</script>

