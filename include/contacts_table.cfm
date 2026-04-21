<!--- Contacts DataTable: display and interactions, including importing, exporting, and managing tags and systems. --->

<div class="table-responsive" id="<cfoutput>#contacts_table#_container</cfoutput>">
    <table id="<cfoutput>#contacts_table#</cfoutput>" class="table display table-striped dataTable dt-checkboxes-select" style="width:100%;border-collapse: separate !important;">
        <thead>
            <tr>
                <th></th>
                <th>Name</th>
                <th>Tags</th>
                <th>Company</th>
                <th>Phone</th>
                <th>Email</th>
            </tr>
        </thead>
        <tfoot>
            <tr>
                <th></th>
                <th>Name</th>
                <th>Tags</th>
                <th>Company</th>
                <th>Phone</th>
                <th>Email</th>
            </tr>
        </tfoot>
    </table>
</div>

<cfinclude template="/include/qry/imports.cfm" />
<cfset defaultRowsValue = defrows />

<script type="text/javascript">
$(document).ready(function() {
    var tableId      = '<cfoutput>#contacts_table#</cfoutput>';
    var $tableEl     = $('#' + tableId);
    var $containerEl = $('#' + tableId + '_container');

    // Truncate-with-title render that HTML-escapes data (no innerHTML concatenation)
    function truncRender(max) {
        return function(data, type) {
            if (type !== 'display' || data == null) return data == null ? '' : data;
            var s = String(data);
            if (s.length <= max) {
                return $('<div>').text(s).html();
            }
            var span = $('<span>').attr('title', s).text(s.substring(0, max) + '...');
            return $('<div>').append(span).html();
        };
    }

    var table = $tableEl.DataTable({
        pageLength: <cfoutput>#defaultRowsValue#</cfoutput>,
        lengthMenu: [[10, 25, 50, 100, 500], [10, 25, 50, 100, 500]],
        searching: true,
        order: [[1, 'asc']],
        stateSave: false,
        dom: '<"row"<"col-sm-6"l><"col-sm-6"f>> <"row"<"col-sm-12"B>> <"row"rtip>',
        autoWidth: false,
        serverSide: true,
        processing: true,
        deferRender: true,
        responsive: {
            details: {
                type: 'inline',
                renderer: function(api, rowIdx, columns) {
                    var rows = $.map(columns, function(col) {
                        if (!col.hidden) return '';
                        var v = col.data;
                        if (v === null || v === undefined || String(v).trim() === '') return '';
                        // Strip any HTML from the column data (hlink for Name contains a link)
                        var plain = String(v).replace(/<[^>]*>/g, '').trim();
                        if (!plain) return '';
                        return '<tr><td class="pr-2"><strong>' +
                               $('<div>').text(col.title).html() +
                               ':</strong></td><td>' +
                               $('<div>').text(plain).html() +
                               '</td></tr>';
                    }).join('');
                    return rows ? $('<table class="table table-sm mb-0"/>').append(rows) : false;
                }
            }
        },
        ajax: {
            url: '/include/contacts_ss.cfm',
            type: 'POST',
            data: function(d) {
                d.contacts_table = tableId;
                d.bytag          = '<cfoutput>#JSStringFormat(bytag)#</cfoutput>';
                d.byimport       = '<cfoutput>#JSStringFormat(byimport)#</cfoutput>';
            }
        },
        buttons: [
            {
                text: 'Add',
                className: 'addrelationship',
                action: function() { $('#remoteAddName').modal('show'); }
            },
            {
                text: 'Search Tag',
                className: 'searchtag',
                action: function() { $('#searchTagModal').modal('show'); }
            },
            {
                text: 'Add/Delete Tag',
                className: 'updatetag',
                action: function() {
                    updateIdList('#myformtag');
                    $('#updateTagModal').modal('show');
                },
                enabled: false
            },
            {
                text: 'Add System',
                className: 'updatesystem',
                action: function() {
                    updateIdList('#myformsystem');
                    $('#addSystemModal').modal('show');
                },
                enabled: false
            },
            {
                text: 'Delete System',
                className: 'deletesystem',
                action: function() {
                    updateIdList('#myformsystemdelete');
                    $('#deleteSystemModal').modal('show');
                },
                enabled: false
            },
            {
                text: 'Import',
                className: 'import',
                action: function() { window.location = '/app/contacts-import-v3/'; }
            },
            <cfif #imports.recordcount# is not "0">
            {
                text: 'Import History',
                className: 'importhistory',
                action: function() { $('#importHistoryModal').modal('show'); }
            },
            </cfif>
            {
                text: 'Export',
                className: 'exportcontacts',
                action: function() {
                    updateIdList('#myformexport');
                    $('#exportContactsModal').modal('show');
                },
                enabled: false
            },
            {
                text: 'Delete',
                className: 'batchdelete',
                action: function() {
                    updateIdList('#myformdelete');
                    $('#batchDeleteModal').modal('show');
                },
                enabled: false
            }
        ],
        columnDefs: [
            {
                targets: 0, // checkbox - responsive priority 1 keeps it visible
                checkboxes: { selectRow: true },
                orderable: false,
                width: '40px',
                className: 'text-center',
                responsivePriority: 1
            },
            {
                targets: 1, // Name
                responsivePriority: 2,
                render: function(data, type, row) {
                    if (type !== 'display') return data;
                    var id = row[0];
                    var trashBtn = ' <a href="javascript:void(0);" class="btn btn-xs btn-danger ms-1" ' +
                                   'data-bs-toggle="modal" data-bs-target="#contactdelete" ' +
                                   'data-delete-id="' + id + '" title="Delete Relationship" ' +
                                   'onclick="event.stopPropagation();">' +
                                   '<i class="mdi mdi-trash-can-outline"></i></a>';
                    return (data == null ? '' : data) + trashBtn;
                }
            },
            {
                targets: 5, // Email
                responsivePriority: 3,
                render: truncRender(25)
            },
            {
                targets: 3, // Company
                orderable: false,
                responsivePriority: 4,
                render: truncRender(25)
            },
            {
                targets: 2, // Tags - first to collapse on narrow screens
                orderable: false,
                responsivePriority: 5
            },
            {
                targets: 4, // Phone
                responsivePriority: 6,
                className: 'text-nowrap',
                render: truncRender(15)
            }
        ],
        select: { style: 'multi' }
    });

    // Build comma-separated idlist from selected checkboxes and push it into the
    // modal form that is about to submit. Called right before each modal open.
    function updateIdList(formSelector) {
        var selectedIds = table.column(0).checkboxes.selected().toArray().join(',');
        var $form = $(formSelector);
        $form.find('input[name="idlist"]').remove();
        $form.append('<input type="hidden" name="idlist" value="' + selectedIds + '">');
    }
    // First instance wins the window-global fallback; sibling tabs overwrite their
    // own last-active id list via the per-table export above.
    window['updateIdList_' + tableId] = updateIdList;
    if (typeof window.updateIdList !== 'function') {
        window.updateIdList = updateIdList;
    }

    // Enable/disable batch buttons based on row selection (scoped to this table)
    $tableEl.on('select.dt deselect.dt', function() {
        var hasSelection = table.rows({ selected: true }).indexes().length > 0;
        table.buttons(['.exportcontacts', '.updatetag', '.updatesystem', '.deletesystem', '.batchdelete']).enable(hasSelection);
    });

    $containerEl.css('display', 'block');
    table.columns.adjust().draw();

    // Stop text-input clicks (search box etc.) from toggling row selection
    $containerEl.on('click', 'input[type="text"]', function(event) {
        event.stopPropagation();
        return false;
    });

    // Counter + floating batch button, scoped to THIS table so sibling tabs
    // (All / Target / Follow-Up / Maintenance) do not cross-count.
    var countChecked = function() {
        var n = table.rows({ selected: true }).indexes().length;
        $containerEl.find('#count').text(n + (n === 1 ? ' item' : ' items') + ' selected');
        var $btn = $('#batchbutton_' + tableId);
        if (n === 0) {
            if ($btn.is(':visible')) $btn.fadeOut();
        } else {
            if ($btn.is(':hidden')) $btn.fadeIn();
        }
    };
    countChecked();
    $tableEl.on('select.dt deselect.dt', countChecked);
});
</script>


<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), "\")#" />
