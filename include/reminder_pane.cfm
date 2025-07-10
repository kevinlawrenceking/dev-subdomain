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
        dataSrc: ""
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
}
,
        { data: "reminder_text" },
        { data: "due_date" },
        { data: "status" },
        { data: "system_type" }
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
