<cfparam name="url.showInactive" default="0">
<cfparam name="url.contactid" default="0">
<cfparam name="contactid" default="0">
<cfparam name="showContact" default="N">




<style>
  /* Override DataTables Select extension checkbox styling */
  #remindersTable th.select-checkbox::before,
  #remindersTable th.select-checkbox::after,
  #remindersTable td.select-checkbox::before,
  #remindersTable td.select-checkbox::after {
    display: none !important;
  }
  #remindersTable .dt-center {
    text-align: center;
  }
</style>
<cfset showInactive = url.showInactive>

<div id="modalContainer"></div>

<div class="card mt-3">
  <div class="card-header d-flex justify-content-between align-items-center">
    <h5 class="mb-0">Reminders</h5>
    <div class="d-flex gap-2 align-items-center">
      <div id="batchActions" style="display: none;">
        <button id="batchComplete" class="btn btn-success btn-sm">
          <i class="fe-check"></i> Complete Selected
        </button>
        <button id="batchSkip" class="btn btn-secondary btn-sm">
          <i class="fe-minus-circle"></i> Skip Selected
        </button>
        <span id="selectedCount" class="badge bg-primary ms-2">0 selected</span>
      </div>
      <div class="form-check">
        <input class="form-check-input" type="checkbox" id="showInactive" value="1" <cfif showInactive EQ 1>checked</cfif>>
        <label class="form-check-label" for="showInactive">Show action log</label>
      </div>
    </div>
  </div>
<Cfif showContact eq "N">
<Cfset contactVisible = "none"/>
<Cfset contactVisibilty = "false"/>
<cfelse>
<Cfset contactVisible = ""/>
<Cfset contactVisibilty = "true"/>
</cfif>

  <div class="card-body">
    <table id="remindersTable" class="table table-striped table-bordered table-sm w-100">
      <thead>
        <tr>
          <th style="width: 30px;">
            <input type="checkbox" id="selectAll" title="Select All">
          </th>
          <th style="white-space: nowrap;">Action</th>


          <th style="display:<cfoutput>#contactVisible#</cfoutput>;">Contact</th>

          <th style="white-space: nowrap;">Start Date</th>
          <th style="display: none;">End Date</th>
          <th>Reminder</th>
          <th style="white-space: nowrap;">Type</th>
          <th>Status</th>
        </tr>
      </thead>
    </table>
  </div>
</div>

<script>
  let selectedReminder = {};
  let pendingConfirmAction = null;
  const _csrfMeta = document.querySelector('meta[name="csrf-token"]');
  const _csrfToken = _csrfMeta ? _csrfMeta.getAttribute('content') : '';

  function showConfirmModal(text, onConfirm) {
    $("#confirmReminderText").text(text);
    pendingConfirmAction = onConfirm;
    const el = document.getElementById('confirmReminderModal');
    const confirmModal = bootstrap.Modal.getOrCreateInstance(el);
    // If the modal is still hiding from a previous action, wait for it to finish
    if (el.classList.contains('show') || el.classList.contains('showing')) {
      confirmModal.hide();
      el.addEventListener('hidden.bs.modal', function onceHidden() {
        el.removeEventListener('hidden.bs.modal', onceHidden);
        confirmModal.show();
      });
    } else {
      confirmModal.show();
    }
  }

  function loadReminders() {
    const showInactive = $("#showInactive").is(":checked") ? 1 : 0;
    const enableFiltering = <cfoutput>'#ucase(showContact)#'</cfoutput> === 'Y';
    
    console.log('Loading reminders with showInactive:', showInactive);

    // Check if DataTable already exists
    if ($.fn.DataTable.isDataTable('#remindersTable')) {
      // Destroy and recreate the table when toggling showInactive
      // This ensures proper reinitialization of filters and empty message
      $('#remindersTable').DataTable().destroy();
      $('#filterRow').remove();
      console.log('Table destroyed, recreating...');
    }

    // Remove any existing filter row from previous table
    $('#filterRow').remove();

    $('#remindersTable').DataTable({
      ajax: {
        url: "/include/get_reminders.cfm?bypass=1",
        cache: false,
        data: function(d) {
          d.showInactive = $("#showInactive").is(":checked") ? 1 : 0;
          d.currentid = <cfoutput>#contactid#</cfoutput>;
          d.userid = <cfoutput>#userid#</cfoutput>;
        },
        dataSrc: function (json) {
          injectReminderModals(json);
          return json;
        }
      },
      columns: [
        {
          data: null,
          orderable: false,
          className: 'dt-center',
          render: function (data, type, row) {
            if (row.status === "Pending") {
              return `<input type="checkbox" class="reminder-checkbox" data-id="${row.id}" data-text="${row.reminder_text}">`;
            } else {
              return "";
            }
          }
        },
        {
          data: "id",
          render: function (data, type, row) {
            if (row.status === "Pending") {
              return `
                <button class="btn btn-success btn-sm mark-complete" data-id="${data}" data-status="Completed" data-text="${row.reminder_text}" title="Mark Complete">
                  <i class="fe-check"></i>
                </button>
                <button class="btn btn-secondary btn-sm mark-skip" data-id="${data}" data-status="Skipped" data-text="${row.reminder_text}" title="Skip">
                  <i class="fe-minus-circle"></i>
                </button>
              `;
            } else {
              return "-";
            }
          }
        },
        { 
          data: "contactfullname", 
          visible: <cfoutput>#contactVisibilty#</cfoutput>,
          render: function (data, type, row) {
            if (type === 'display' && row.hlink) {
              return `<a href="${row.hlink}" title="View contact details">${data}</a>`;
            }
            return data;
          }
        },
        { data: "notStartDatef" },
        { data: "notEndDatef", visible: false },
        { data: "reminder_text" },
        { data: "system_type" },
        { data: "status" }
      ],
      columnDefs: [
        {
          targets: [1, 3, 7], // Action, Start Date, Type columns (adjusted for checkbox)
          className: "text-nowrap"
        },
        {
          targets: 5, // Reminder column (adjusted for checkbox)
          render: function (data, type, row) {
            if (type === 'display') {
              const modalId = `action${row.id}-modal`;
              return `
                ${data}
                <a href="#" title="Click for details" data-bs-toggle="modal" data-bs-target="#${modalId}">
                  <i class="fe-info ms-2 text-info"></i>
                </a>
              `;
            }
            return data;
          }
        },
        {
          targets: 6, // Type column (adjusted for checkbox)
          render: function (data, type, row) {
            if (type === 'display') {
              const systemModalId = `system${row.suid}-modal`;
              return `
                ${data}
                <a href="#" title="Click for system details" data-bs-toggle="modal" data-bs-target="#${systemModalId}">
                  <i class="fe-info ms-2 text-muted"></i>
                </a>
              `;
            }
            return data;
          }
        }
      ],
      language: {
        emptyTable: showInactive ? "No completed or skipped reminders" : "You have no active reminders"
      },
      initComplete: function () {
        if (enableFiltering) {
          const api = this.api();
          setTimeout(function() {
            createFilterDropdowns(api);
          }, 100);
        }
      }
    });
  }

  function createFilterDropdowns(api) {
    // Remove existing filter row
    $('#filterRow').remove();
    
    // Get the actual number of visible columns
    const visibleColumns = api.columns(':visible').count();
    
    // Create filter row with cells only for visible columns
    let filterRow = '<tr id="filterRow">';
    for (let i = 0; i < visibleColumns; i++) {
      filterRow += '<th></th>';
    }
    filterRow += '</tr>';
    
    $('#remindersTable thead').append(filterRow);

    // Define which columns should have dropdowns based on visible columns
    let visibleColIndex = 0;
    const dropdownColumns = [];
    
    api.columns().every(function(index) {
      const column = this;
      if (column.visible()) {
        const headerText = $(column.header()).text().trim();
        
        // Add dropdown filters for Contact, Reminder, and Type columns
        if (headerText === 'Contact' || headerText === 'Reminder' || headerText === 'Type') {
          dropdownColumns.push({dataIndex: index, filterIndex: visibleColIndex});
        }
        visibleColIndex++;
      }
    });

    // Create the dropdown filters
    dropdownColumns.forEach(function (col) {
      const column = api.column(col.dataIndex);
      const th = $('#remindersTable thead tr:eq(1) th').eq(col.filterIndex);
      
      if (th.length > 0) {
        const select = $('<select class="form-select form-select-sm"><option value="">All</option></select>')
          .appendTo(th.empty())
          .on('change', function () {
            const val = $.fn.dataTable.util.escapeRegex($(this).val());
            column.search(val ? '^' + val + '$' : '', true, false).draw();
          });

        // Get unique values and populate dropdown
        const uniqueValues = [];
        column.data().each(function (d) {
          if (d && d.toString().trim() && uniqueValues.indexOf(d) === -1) {
            uniqueValues.push(d);
          }
        });
        
        // Sort and add options
        uniqueValues.sort().forEach(function(value) {
          const option = $('<option></option>').attr('value', value).text(value);
          select.append(option);
        });
      }
    });
  }

  function injectReminderModals(data) {
    let html = '';
    data.forEach(row => {
      html += `
        <div id="action${row.id}-modal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <h4 class="modal-title">${row.reminder_text}</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
              </div>
              <div class="modal-body">
                <h5>${row.action_details}</h5>
                <p>${row.action_info}</p>
              </div>
            </div>
          </div>
        </div>

        <div id="system${row.suid}-modal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <h4 class="modal-title">${row.recordname}</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
              </div>
              <div class="modal-body">
                <h5>Description</h5>
                <p>${row.systemdescript}</p>
                <p><strong>Start Date:</strong> ${row.sustartDate}</p>
                ${row.suenddate ? `<p><strong>Completed:</strong> ${row.suenddate}</p>` : ''}
              </div>
            </div>
          </div>
        </div>
      `;
    });
    $("#modalContainer").html(html);
  }

  $(document).ready(function () {
    loadReminders();

    $("#showInactive").change(function () {
      loadReminders();
    });

    $('#remindersTable').on('click', '.mark-complete, .mark-skip', function () {
      selectedReminder = {
        id: $(this).data('id'),
        status: $(this).data('status'),
        text: $(this).data('text')
      };

      showConfirmModal(
        `Are you sure you want to mark "${selectedReminder.text} reminder" as ${selectedReminder.status}?`,
        function() {
          console.log('Submitting reminder completion:', selectedReminder);

          $.ajax({
            url: "/include/complete_not_ajax.cfm?bypass=1",
            type: "POST",
            headers: { 'X-CSRF-Token': _csrfToken },
            data: {
              notid: selectedReminder.id,
              notstatus: selectedReminder.status
            },
            success: function(response) {
              console.log('Response from complete_not_ajax.cfm:', response);

              var resp = (typeof response === 'string') ? JSON.parse(response) : response;
              if (resp && resp.success === false) {
                console.error('Reminder completion failed:', resp.error);
                alert('Could not complete reminder: ' + (resp.error || 'Unknown error'));
              }

              if ($.fn.DataTable.isDataTable('#remindersTable')) {
                const table = $('#remindersTable').DataTable();
                table.ajax.reload(function(json) {
                  injectReminderModals(json);
                }, false);
              } else {
                setTimeout(function() { loadReminders(); }, 100);
              }
            },
            error: function(xhr, status, error) {
              console.error('Error completing reminder:', error);
              alert('Error completing reminder: ' + error);
            }
          });
        }
      );
    });

    $('#confirmReminderButton').click(function () {
      const el = document.getElementById('confirmReminderModal');
      const confirmModal = bootstrap.Modal.getOrCreateInstance(el);
      const action = pendingConfirmAction;
      pendingConfirmAction = null;
      // Hide modal, then execute the pending action after transition completes
      if (confirmModal) {
        el.addEventListener('hidden.bs.modal', function onceHidden() {
          el.removeEventListener('hidden.bs.modal', onceHidden);
          if (action) action();
        });
        confirmModal.hide();
      } else if (action) {
        action();
      }
    });

    // Batch operations
    function updateBatchUI() {
      const checkedBoxes = $('.reminder-checkbox:checked');
      const count = checkedBoxes.length;
      $('#selectedCount').text(count + ' selected');

      if (count > 0) {
        $('#batchActions').show();
      } else {
        $('#batchActions').hide();
      }
    }

    // Select all checkbox
    $('#remindersTable').on('change', '#selectAll', function() {
      const isChecked = $(this).is(':checked');
      $('.reminder-checkbox').prop('checked', isChecked);
      updateBatchUI();
    });

    // Individual checkbox change
    $('#remindersTable').on('change', '.reminder-checkbox', function() {
      const allChecked = $('.reminder-checkbox').length === $('.reminder-checkbox:checked').length;
      $('#selectAll').prop('checked', allChecked);
      updateBatchUI();
    });

    // Batch complete
    $('#batchComplete').click(function() {
      const selectedIds = [];
      const selectedTexts = [];

      $('.reminder-checkbox:checked').each(function() {
        selectedIds.push($(this).data('id'));
        selectedTexts.push($(this).data('text'));
      });

      if (selectedIds.length === 0) return;

      const confirmText = selectedIds.length === 1
        ? `Are you sure you want to mark "${selectedTexts[0]}" as Completed?`
        : `Are you sure you want to mark ${selectedIds.length} reminders as Completed?`;

      showConfirmModal(confirmText, function() {
        processBatchReminders(selectedIds, 'Completed');
      });
    });

    // Batch skip
    $('#batchSkip').click(function() {
      const selectedIds = [];
      const selectedTexts = [];

      $('.reminder-checkbox:checked').each(function() {
        selectedIds.push($(this).data('id'));
        selectedTexts.push($(this).data('text'));
      });

      if (selectedIds.length === 0) return;

      const confirmText = selectedIds.length === 1
        ? `Are you sure you want to skip "${selectedTexts[0]}"?`
        : `Are you sure you want to skip ${selectedIds.length} reminders?`;

      showConfirmModal(confirmText, function() {
        processBatchReminders(selectedIds, 'Skipped');
      });
    });

    function processBatchReminders(notIds, status) {
      console.log('Processing batch reminders:', notIds, status);

      $.ajax({
        url: "/include/complete_not_batch.cfm?bypass=1",
        type: "POST",
        headers: { 'X-CSRF-Token': _csrfToken },
        data: {
          notids: notIds.join(','),
          notstatus: status
        },
        success: function(response) {
          console.log('Batch response:', response);

          // Reload table
          if ($.fn.DataTable.isDataTable('#remindersTable')) {
            const table = $('#remindersTable').DataTable();
            table.ajax.reload(function(json) {
              injectReminderModals(json);
              // Reset checkboxes
              $('#selectAll').prop('checked', false);
              updateBatchUI();
            }, false);
          } else {
            setTimeout(function() {
              loadReminders();
            }, 100);
          }
        },
        error: function(xhr, status, error) {
          console.error('Error processing batch:', error);
          console.error('Response:', xhr.responseText);
          alert('Error processing batch reminders: ' + error);
        }
      });
    }
  });
</script>




<div class="modal fade" id="confirmReminderModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Confirm Action</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <p id="confirmReminderText">Are you sure you want to complete this reminder?</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="button" id="confirmReminderButton" class="btn btn-primary">Yes, do it</button>
      </div>
    </div>
  </div>
</div>
