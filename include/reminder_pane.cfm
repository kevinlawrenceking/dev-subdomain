<cfparam name="url.showInactive" default="0">
<cfparam name="url.contactid" default="0">
<cfparam name="contactid" default="0">
<cfparam name="showContact" default="N">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<cfset showInactive = url.showInactive>

<div class="card mt-3">
  <div class="card-header d-flex justify-content-between align-items-center">
    <h5 class="mb-0">Reminders</h5>
    <div class="form-check">
      <input class="form-check-input" type="checkbox" id="showInactive" value="1" <cfif showInactive EQ 1>checked</cfif>>
      <label class="form-check-label" for="showInactive">Show action log</label>
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
          <th style="white-space: nowrap;">Action</th>
   
        
          <th style="display:<cfoutput>#contactVisible#</cfoutput>;">Contact</th>
     
          <th style="white-space: nowrap;">Start Date</th>
          <th style="display: none;">End Date</th>
          <th>Reminder</th>
          <th style="display: none;">Status</th>
          <th style="white-space: nowrap;">Type</th>
        </tr>
      </thead>
    </table>
  </div>
</div>

<script>
  let selectedReminder = {};

  function loadReminders() {
    const showInactive = $("#showInactive").is(":checked") ? 1 : 0;
    const enableFiltering = <cfoutput>'#ucase(showContact)#'</cfoutput> === 'Y';
    
    console.log('Loading reminders with showInactive:', showInactive);

    // Destroy existing DataTable if it exists
    if ($.fn.DataTable.isDataTable('#remindersTable')) {
      $('#remindersTable').DataTable().destroy();
    }

    $('#remindersTable').DataTable({
      ajax: {
        url: "/include/get_reminders.cfm?bypass=1",
        data: {
          showInactive: showInactive,
          currentid: <cfoutput>#contactid#</cfoutput>,
          userid: <cfoutput>#userid#</cfoutput>
        },
        dataSrc: function (json) {
          injectReminderModals(json);
          return json;
        }
      },
      columns: [
        {
          data: "id",
          render: function (data, type, row) {
            if (row.status === "Pending") {
              return `
                <button class="btn btn-success btn-sm mark-complete" data-id="${data}" data-status="Completed" data-text="${row.reminder_text}" title="Mark Complete">
                  <i class="fas fa-check"></i>
                </button>
                <button class="btn btn-secondary btn-sm mark-skip" data-id="${data}" data-status="Skipped" data-text="${row.reminder_text}" title="Skip">
                  <i class="fas fa-circle-minus"></i>
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
            if (type === 'display') {
              return `
                ${data}
                <a href="/app/contact/?contactid=${row.contactid}" class="ms-1" title="View Contact Details">
                  <i class="mdi mdi-eye-outline" style="font-size: 12px;"></i>
                </a>
              `;
            }
            return data;
          }
        },
        { data: "notStartDatef" },
        { data: "notEndDatef", visible: false },
        { data: "reminder_text" },
        { data: "status", visible: false },
        { data: "system_type" }
      ],
      columnDefs: [
        {
          targets: [0, 2, 6], // Action, Start Date, Type columns
          className: "text-nowrap"
        },
        {
          targets: 4, // Reminder column
          render: function (data, type, row) {
            if (type === 'display') {
              const modalId = `action${row.id}-modal`;
              return `
                ${data}
                <a href="#" title="Click for details" data-bs-toggle="modal" data-bs-target="#${modalId}">
                  <i class="fas fa-info-circle ms-2 text-info"></i>
                </a>
              `;
            }
            return data;
          }
        },
        {
          targets: 6, // Type column
          render: function (data, type, row) {
            if (type === 'display') {
              const systemModalId = `system${row.suid}-modal`;
              return `
                ${data}
                <a href="#" title="Click for system details" data-bs-toggle="modal" data-bs-target="#${systemModalId}">
                  <i class="fas fa-info-circle ms-2 text-muted"></i>
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
        if (!enableFiltering) return;

        const api = this.api();
        
        // Check if filter row already exists, if so remove it first
        $('#filterRow').remove();
        
        // Create filter row with cells only for visible columns
        let filterRow = '<tr id="filterRow">';
        // Action column - no filter
        filterRow += '<th></th>';
        // Contact column - dropdown filter (only if visible)
        filterRow += <cfoutput>'#contactVisible#'</cfoutput> === 'none' ? '' : '<th></th>';
        // Start Date column - no filter
        filterRow += '<th></th>';
        // Reminder column - dropdown filter
        filterRow += '<th></th>';
        // Type column - dropdown filter
        filterRow += '<th></th>';
        filterRow += '</tr>';
        
        $('#remindersTable thead').append(filterRow);

        // Define which visible columns should have dropdowns
        const dropdownColumns = [];
        let visibleColIndex = 0;
        
        // Action column (index 0) - no filter
        visibleColIndex++;
        
        // Contact column (index 1) - add filter if visible
        if (<cfoutput>'#contactVisible#'</cfoutput> !== 'none') {
          dropdownColumns.push({dataIndex: 1, filterIndex: visibleColIndex});
          visibleColIndex++;
        }
        
        // Start Date column (index 2) - no filter
        visibleColIndex++;
        
        // Reminder column (index 4) - add filter
        dropdownColumns.push({dataIndex: 4, filterIndex: visibleColIndex});
        visibleColIndex++;
        
        // Type column (index 6) - add filter
        dropdownColumns.push({dataIndex: 6, filterIndex: visibleColIndex});

        dropdownColumns.forEach(function (col) {
          const column = api.column(col.dataIndex);
          const th = $('#remindersTable thead tr:eq(1) th').eq(col.filterIndex);
          const select = $('<select class="form-select form-select-sm"><option value="">All</option></select>')
            .appendTo(th.empty())
            .on('change', function () {
              const val = $.fn.dataTable.util.escapeRegex($(this).val());
              column.search(val ? '^' + val + '$' : '', true, false).draw();
            });

          column.data().unique().sort().each(function (d) {
            if (d) {
              select.append('<option value="' + d + '">' + d + '</option>');
            }
          });
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
      
      console.log('Selected reminder for action:', selectedReminder);

      $("#confirmReminderText").text(
        `Are you sure you want to mark "${selectedReminder.text}" as ${selectedReminder.status}?`
      );

      const confirmModal = new bootstrap.Modal(document.getElementById('confirmReminderModal'));
      confirmModal.show();
    });

    $('#confirmReminderButton').click(function () {
      console.log('Submitting reminder completion:', selectedReminder);
      console.log('Posting data:', { notid: selectedReminder.id, notstatus: selectedReminder.status });
      
      $.ajax({
        url: "/include/complete_not_ajax.cfm?bypass=1",
        type: "POST",
        data: {
          notid: selectedReminder.id,
          notstatus: selectedReminder.status
        },
        success: function(response) {
          console.log('Response from complete_not_ajax.cfm:', response);
          
          // Parse the JSON response if it's a string
          let parsedResponse;
          try {
            parsedResponse = typeof response === 'string' ? JSON.parse(response) : response;
            console.log('Parsed response:', parsedResponse);
          } catch (e) {
            console.error('Error parsing response:', e);
            parsedResponse = response;
          }
          
          // Close modal first
          bootstrap.Modal.getInstance(document.getElementById('confirmReminderModal')).hide();
          
          // Show brief success message then refresh the page
          if (parsedResponse.success) {
            console.log(`Successfully ${parsedResponse.status} reminder ${parsedResponse.notid}`);
            // Refresh the page to show updated reminders
            setTimeout(function() {
              window.location.reload();
            }, 500); // Small delay to let modal close
          } else {
            // Fallback if no success property
            setTimeout(function() {
              window.location.reload();
            }, 500);
          }
        },
        error: function(xhr, status, error) {
          console.error('Error completing reminder:', error);
          console.error('Status:', status);
          console.error('Response:', xhr.responseText);
          alert('Error completing reminder: ' + error + '\nStatus: ' + status + '\nResponse: ' + xhr.responseText);
        }
      });
    });
  });
</script>




<div id="modalContainer"></div>

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
