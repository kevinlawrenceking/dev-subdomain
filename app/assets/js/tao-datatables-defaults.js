// TAO global DataTables defaults
//
// MIGRATE: in Go/Flutter rebuild, table defaults move to a Flutter widget config.
// TECH-DEBT: duplicated to /share/assets/tao-datatables-defaults.js matching the
// existing site convention; consolidate when /share/assets/ is unified with /app/assets/js/.
//
// Loaded by:
//   - include/core.cfm        (main /app/ tree)
//   - share/index.cfm         (share entry)
//   - share/share.cfm         (share content)
//   - share/remoteShareViewC.cfm
//   - share/relationships_shared.cfm
//
// The IIFE guard makes this a no-op on pages where DataTables isn't loaded,
// so it is safe to include unconditionally.

(function () {
    if (!window.jQuery || !jQuery.fn || !jQuery.fn.dataTable) return;

    jQuery.extend(true, jQuery.fn.dataTable.defaults, {
        scrollX: true,
        autoWidth: false,
        responsive: false,
        pageLength: 25,
        lengthMenu: [[25, 50, 100, -1], [25, 50, 100, 'All']]
    });

    // Modal-hosted tables: recalc column widths after a Bootstrap modal opens
    // so headers and bodies align inside the modal viewport. visible:true scopes
    // the adjust to tables that just became visible.
    jQuery(document).on('shown.bs.modal', function () {
        if (jQuery.fn.dataTable && jQuery.fn.dataTable.tables) {
            jQuery.fn.dataTable.tables({ visible: true, api: true }).columns.adjust();
        }
    });
})();
