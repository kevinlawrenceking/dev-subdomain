<!--- This ColdFusion page manages contact data display and interactions, including importing, exporting, and managing tags and systems. --->



<div class="table-responsive" id="<cfoutput>#contacts_table#_container</cfoutput>">
    <table id="<cfoutput>#contacts_table#</cfoutput>" class="table display nowrap table-striped dataTable dtr-inline dt-checkboxes-select dt-responsive" style="width:100%;border-collapse: separate !important;">
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
                <th class="min-phone-l">Tags</th>
                <th class="min-phone-l">Company</th>
                <th class="min-phone-l">Phone</th>
                <th class="min-phone-l">Email</th>
            </tr>
        </tfoot>
    </table>
</div>

<cfinclude template="/include/qry/imports.cfm" />
<cfset defaultRowsValue = defrows />

<script type="text/javascript">
$(document).ready(function() {
    var table = $('#<cfoutput>#contacts_table#</cfoutput>').DataTable({
        "pageLength": <cfoutput>#defaultRowsValue#</cfoutput>,
        "lengthMenu": [[10, 25, 50, 100, 500, 9999999], [10, 25, 50, 100, 500, "All"]],
        "searching": true,
        order: [[1, 'asc']],
        stateSave: false,
        dom: '<"row"<"col-sm-6"l><"col-sm-6"f>> <"row"<"col-sm-12"B>> <"row"rtip>',
        responsive: {
            details: {
                type: 'column'
            }
        },
        serverSide: true,
        ajax: {
            url: '/include/contacts_ss.cfm?contacts_table=<cfoutput>#contacts_table#</cfoutput>&userid=<cfoutput>#userid#</cfoutput>&bytag=<cfoutput>#bytag#</cfoutput>&byimport=<cfoutput>#byimport#</cfoutput>',
            type: 'post'
        },
       buttons: [
    {
        text: 'Add',
        className: 'addrelationship',
        action: function() {
            $('#remoteAddName').modal('show');
        }
    },
    {
        text: 'Search Tag',
        className: 'searchtag',
        action: function() {
            $('#exampleModal2').modal('show');
        }
    },
    {
        text: 'Add/Delete Tag',
        className: 'updatetag',
        action: function() {
            updateIdList('#myformtag');  // Ensure idlist is set
            $('#exampleModal4').modal('show');
        },
        enabled: false
    },
    {
        text: 'Add System',
        className: 'updatesystem',
        action: function() {
            updateIdList('#myformsystem');  // Ensure idlist is set
            $('#exampleModal3').modal('show');
        },
        enabled: false
    },
    {
        text: 'Delete System',
        className: 'deletesystem',
        action: function() {
            updateIdList('#myformsystemdelete');  // Ensure idlist is set
            $('#exampleModal99').modal('show');
        },
        enabled: false
    },
    {
        text: 'Import',
        className: 'import',
        action: function() {
            window.location = '/app/contacts-import/';
        }
    },
    <cfif #imports.recordcount# is not "0">
        {
            text: 'Import History',
            className: 'importhistory',
            action: function() {
                $('#exampleModal22').modal('show');
            }
        },
    </cfif>
    {
        text: 'Delete',
        className: 'batchdelete',
        action: function() {
            updateIdList('#myformdelete');  // Ensure idlist is set
            $('#exampleModaldelete').modal('show');
        },
        enabled: false
    },
    {
        text: 'Export',
        className: 'exportcontacts',
        action: function() {
            updateIdList('#myformexport');  // Ensure idlist is set
            $('#exampleModal5').modal('show');
        },
        enabled: false
    }
],

       columnDefs: [
    {
        targets: 0,
        checkboxes: {
            selectRow: true
        }
    },
    {
        targets: [2, 3],
        orderable: false
    }
],

        select: {
            style: 'multi'
        }
    });

    // Function to update idlist and log for debugging
function updateIdList(formSelector) {
    var selectedIds = table.column(0).checkboxes.selected().toArray().join(",");
    console.log("idlist: ", selectedIds);  // Debugging: log idlist to console

    var form = $(formSelector);

    // Remove any existing idlist input and ensure it's set inside the modal
    form.find('input[name="idlist"]').remove();
    form.append('<input type="hidden" name="idlist" value="' + selectedIds + '">');

    // Debugging: Confirm that the hidden input is updated in the modal
    console.log("Updated idlist in modal:", form.find('input[name="idlist"]').val());
}

    // Enable/disable buttons based on checkbox selection
    $('#<cfoutput>#contacts_table#</cfoutput>').on('select.dt deselect.dt', function() {
        var hasSelection = table.rows({ selected: true }).indexes().length > 0;
        table.buttons(['.exportcontacts', '.updatetag', '.updatesystem', '.deletesystem', '.batchdelete']).enable(hasSelection);
    });

    $('#<cfoutput>#contacts_table#_container</cfoutput>').css('display', 'block');
    table.columns.adjust().draw();

    // Stop event propagation for inputs inside table
    $('#<cfoutput>#contacts_table#_container</cfoutput>').on('click', 'input[type="text"]', function(event) {
        event.stopPropagation();
        return false;
    });

    // Checkbox count and batch button visibility
    var countChecked = function() {
        var n = $("input:checked").length;
        console.log("Checked count: ", n); // Debugging: log checkbox count
        $("#count").text(n + (n === 1 ? " is" : " zijn") + " aangevinkt!");
        if (n == 0) {
            $("#batchbutton_<cfoutput>#contacts_table#</cfoutput>:visible").fadeOut();
        } else {
            $("#batchbutton_<cfoutput>#contacts_table#</cfoutput>:hidden").fadeIn();
        }
    };
    countChecked();
    $("input[type=checkbox]").on("click", countChecked);
});

</script>

<script>
    // Count checked checkboxes and update UI
    var countChecked = function() {
        var n = $("input:checked").length; // n now contains the number of checked elements.
        $("#count").text(n + (n === 1 ? " is" : " zijn") + " aangevinkt!"); // show some text
        if (n == 0) {
            $("#batchbutton_<cfoutput>#contacts_table#</cfoutput>:visible").fadeOut(); // if there are none checked, hide only visible elements
        } else {
            $("#batchbutton_<cfoutput>#contacts_table#</cfoutput>:hidden").fadeIn(); // otherwise (some are selected) fadeIn - if the div is hidden.
        }
    };
    countChecked();

    $("input[type=checkbox]").on("click", countChecked);
</script>

<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), "\")#" />
