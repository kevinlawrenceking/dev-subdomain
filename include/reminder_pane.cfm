<!-- reminder_pane.cfm -->

<cfparam name="url.showInactive" default="0">

<cfparam name="url.contactid" default="0">
 
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">


<cfset showInactive = url.showInactive>

<div class="card mt-3">
  <div class="card-header d-flex justify-content-between align-items-center">
    <h5 class="mb-0">Reminders</h5>
    <div class="form-check">
      <input class="form-check-input" type="checkbox" id="showInactive" value="1" <cfif showInactive EQ 1>checked</cfif>>
      <label class="form-check-label" for="showInactive">Show inactive records</label>
    </div>
  </div>
  <div class="card-body">
    <table class="table table-sm table-striped w-100" id="remindersTable">
      <thead>
        <tr>
          <th>Action</th>
          <th>Reminder</th>
          <th>Start Date</th>
          <th>Status</th>
          <th>Type</th>
        </tr>
      </thead>
      <tbody></tbody>
    </table>
  </div>
</div>

<script>
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
          injectReminderModals(json); // <- this is the key addition
          return json;
        }
      },
      columns: [
        {
          data: "id",
          render: function (data, type, row) {
            if (row.status === "Pending") {
              return `
                <button class="btn btn-success btn-sm mark-complete" data-id="${data}" title="Mark Complete">
                  <i class="fas fa-check"></i>
                </button>
                <button class="btn btn-secondary btn-sm mark-skip" data-id="${data}" title="Skip">
                  <i class="fas fa-circle-minus"></i>
                </button>
              `;
            } else {
              return "-";
            }
          }
        },
        {
          data: null,
          render: function (data, type, row) {
            const modalId = `action${row.id}-modal`;
            return `
              ${row.reminder_text}
              <a href="#" title="Click for details" data-bs-toggle="modal" data-bs-target="#${modalId}">
                <i class="fas fa-info-circle ms-2 text-info"></i>
              </a>
            `;
          }
        },
        { data: "due_date" },
        { data: "status" },
        { data: "system_type" }
      ]
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
      const id = $(this).data('id');
      const new_status = $(this).hasClass('mark-complete') ? "Completed" : "Skipped";

      $.post("/include/update_reminder_status.cfm", { reminder_id: id, new_status: new_status }, function () {
        loadReminders();
      });
    });
  });
</script>

<div id="modalContainer"></div>
