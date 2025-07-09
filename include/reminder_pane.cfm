<!-- reminder_pane.cfm -->

<cfparam name="url.showInactive" default="0">
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
    <table class="table table-sm table-striped" id="remindersTable">
      <thead>
        <tr>
          <th>Action</th>
          <th>Reminder</th>
          <th>Due</th>
          <th>Status</th>
          <th>Last Updated</th>
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
        data: { showInactive: showInactive },
        dataSrc: ""
      },
      columns: [
        {
          data: "id",
          render: function (data, type, row) {
            if (row.status === "Pending") {
              return `
                <button class="btn btn-sm btn-success mark-complete" data-id="${data}">Complete</button>
                <button class="btn btn-sm btn-warning mark-skip" data-id="${data}">Skip</button>
              `;
            } else {
              return "-";
            }
          }
        },
        { data: "reminder_text" },
        { data: "due_date" },
        { data: "status" },
        { data: "last_updated" }
      ]
    });
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
