/* ==========================================================================
   packeryInit.js  --  Single source of truth for dashboard Packery layout
   ==========================================================================
   Depends on: jQuery, Packery, Draggabilly (desktop only), tao-toast.js
   ========================================================================== */

(function () {
    'use strict';

    /* ------------------------------------------------------------------
       Config constants — define once
       ------------------------------------------------------------------ */
    var GUTTER        = 10;
    var BREAKPOINT    = 768;
    var SAVE_DELAY    = 800;   // debounce ms before persisting order
    var SAVE_ENDPOINT = '/include/update_order.cfm';

    /* ------------------------------------------------------------------
       Save state — debounce + latest-write-wins
       ------------------------------------------------------------------ */
    var saveTimer   = null;
    var saveInFlight = false;
    var pendingOrder = null;

    function persistOrder(orderStr) {
        if (saveInFlight) {
            pendingOrder = orderStr;
            return;
        }

        saveInFlight = true;

        $.ajax({
            url: SAVE_ENDPOINT,
            type: 'POST',
            data: { order: orderStr },
            success: function () {
                saveInFlight = false;
                if (pendingOrder !== null) {
                    var next = pendingOrder;
                    pendingOrder = null;
                    persistOrder(next);
                }
            },
            error: function () {
                saveInFlight = false;
                pendingOrder = null;
                if (typeof window.taoToast === 'function') {
                    taoToast('Failed to save layout', 'error');
                }
            }
        });
    }

    function debouncedSave(orderStr) {
        if (saveTimer) { clearTimeout(saveTimer); }
        saveTimer = setTimeout(function () {
            saveTimer = null;
            persistOrder(orderStr);
        }, SAVE_DELAY);
    }

    /* ------------------------------------------------------------------
       Packery initialization
       ------------------------------------------------------------------ */
    function initializePackery() {
        var isMobile = window.matchMedia('(max-width: ' + BREAKPOINT + 'px)').matches;

        var packeryOptions = isMobile ? {
            itemSelector: '.grid-item',
            gutter: GUTTER,
            percentPosition: true
        } : {
            itemSelector: '.grid-item',
            gutter: GUTTER,
            fitWidth: true,
            resizable: true,
            columnWidth: '.grid-item',
            percentPosition: true
        };

        var $grid = $('.packery-grid').packery(packeryOptions);

        if (!isMobile) {
            $grid.find('.grid-item').each(function (i, gridItem) {
                var draggie = new Draggabilly(gridItem);
                $grid.packery('bindDraggabillyEvents', draggie);
            });

            $grid.on('dragItemPositioned', function () {
                var newOrder = [];
                $grid.packery('getItemElements').forEach(function (itemElem) {
                    var id = $(itemElem).attr('data-id');
                    newOrder.push(id);
                });
                debouncedSave(newOrder.join(','));
            });
        }
    }

    // Initialize on page load
    initializePackery();

    // Re-initialize on window resize
    $(window).resize(function () {
        initializePackery();
    });
})();
