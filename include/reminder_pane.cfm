<cfparam name="url.showInactive" default="0">
<cfparam name="url.contactid" default="0">

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
  <div class="card-body">
    <table id="remindersTable" class="table table-striped table-bordered table-sm w-100">
      <thead>
        <tr>
          <th>Actionx</th>
          <th>ID</th>
          <th>Contact</th>
               <th>Start Date</th>
                     <th>End Date</th>
          <th>Reminderx</th>
      
     
    
          <th>Statusx</th>
          <th>Typex</th>
        </tr>
      </thead>
    </table>
  </div>
</div>

<script>
  let selectedReminder = {};

  function loadReminders() {
    const showInactive = $("#showInactive").is(":checked") ? 1 : 0;

    $('#remindersTable').DataTable({
      destroy: true,
      ajax: {
        url: "/include/get_reminders.cfm",
        data: {
          showInactive: showInactive,
          currentid: <cfoutput>#contactid#</cfoutput>
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
        { data: "contactid", visible: false },
        { data: "contactfullname", visible: false },
        {
          data: "reminder_text",
          render: function (data, type, row) {
            const modalId = `action${row.id}-modal`;
            return `
              ${data}
              <a href="#" title="Click for details" data-bs-toggle="modal" data-bs-target="#${modalId}">
                <i class="fas fa-info-circle ms-2 text-info"></i>
              </a>
            `;
          }
        },
         { data: "status" },
{
          data: null,
          render: function (data, type, row) {
            const systemModalId = `system${row.suid}-modal`;
            return `
              ${row.system_type}
              <a href="#" title="Click for system details" data-bs-toggle="modal" data-bs-target="#${systemModalId}">
                <i class="fas fa-info-circle ms-2 text-muted"></i>
              </a>
            `;
          }
        },
        { data: "status" },
        {
          data: null,
          render: function (data, type, row) {
            const systemModalId = `system${row.suid}-modal`;
            return `
              ${row.system_type}
              <a href="#" title="Click for system details" data-bs-toggle="modal" data-bs-target="#${systemModalId}">
                <i class="fas fa-info-circle ms-2 text-muted"></i>
              </a>
            `;
          }
        },
        { data: "due_date" },
        { data: "notenddate" },
        
      ],
      language: {
        emptyTable: showInactive
          ? "No completed or skipped reminders"
          : "You have no active reminders"
      },
      initComplete: function () {
        $('#remindersTable thead th:eq(1), #remindersTable thead th:eq(2)').hide();
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

      $("#confirmReminderText").text(
        `Are you sure you want to mark "${selectedReminder.text} reminder" as ${selectedReminder.status}?`
      );

      const confirmModal = new bootstrap.Modal(document.getElementById('confirmReminderModal'));
      confirmModal.show();
    });

    $('#confirmReminderButton').click(function () {
      $.post("/include/complete_not_ajax.cfm", {
        notid: selectedReminder.id,
        notstatus: selectedReminder.status
      }, function () {
        loadReminders();
        bootstrap.Modal.getInstance(document.getElementById('confirmReminderModal')).hide();
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
