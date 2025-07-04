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
