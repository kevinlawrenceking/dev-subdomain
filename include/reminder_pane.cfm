<!-- Filter Controls -->
<div class="form-check mb-2">
  <input class="form-check-input" type="checkbox" id="showInactive">
  <label class="form-check-label" for="showInactive">
    Show Inactive (Skipped / Completed)
  </label>
</div>
<div class="form-check mb-3">
  <input class="form-check-input" type="checkbox" id="hideCompleted">
  <label class="form-check-label" for="hideCompleted">
    Hide Completed Only
  </label>
</div>

<!-- Reminders Table -->
<cfoutput>
<table class="table table-bordered table-striped table-sm" id="remindersTable" data-contactid="#contactID#">
  <thead class="thead-light">
    <tr>
      <th scope="col">Action</th>
      <th scope="col">Due</th>
      <th scope="col">Status</th>
      <th scope="col">Controls</th>
    </tr>
  </thead>
  <tbody id="reminderRows">
    <!-- AJAX loaded -->
  </tbody>
</table>
</cfoutput>

<!-- Modal Container -->
<div id="modalContainer"></div>

<style>
.skipped-row td {
  text-decoration: line-through;
  color: #888;
}
</style>

<script>
function loadReminders(showInactive) {
  const contactid = $('#remindersTable').data('contactid') || 0;
  const hideCompleted = $('#hideCompleted').is(':checked') ? 1 : 0;

  $.get('/app/ajax/load_reminders.cfm', {
    showInactive: showInactive ? 1 : 0,
    contactid: contactid,
    HIDE_COMPLETED: hideCompleted
  }, function (html) {
    const parsed = $('<div>').html(html);
    const rows = parsed.find('#reminderRows').html();
    const modals = parsed.find('#modalContainer').html();

    $('#reminderRows').html(rows);
    $('#modalContainer').html(modals);
    bindReminderHandlers();
  });
}

function bindReminderHandlers() {
  $('.completeReminder').off('change').on('change', function () {
    let notID = $(this).data('id');
    if (confirm("Mark this reminder as complete?")) {
      $.post('/app/ajax/update_notification_status.cfm', {
        notificationID: notID,
        status: 'Completed'
      }, function () {
        if ($('#showInactive').is(':checked')) {
          $('#not_' + notID + ' td:eq(2)').text('Completed');
        } else {
          $('#not_' + notID).fadeOut(300, function () { $(this).remove(); });
        }
      });
    } else {
      $(this).prop('checked', false);
    }
  });

  $('.skipReminder').off('click').on('click', function () {
    let notID = $(this).data('id');
    if (confirm("Skip this reminder?")) {
      $.post('/app/ajax/update_notification_status.cfm', {
        notificationID: notID,
        status: 'Skipped'
      }, function () {
        if ($('#showInactive').is(':checked')) {
          $('#not_' + notID + ' td:eq(2)').text('Skipped');
          $('#not_' + notID).addClass('skipped-row');
        } else {
          $('#not_' + notID).fadeOut(300, function () { $(this).remove(); });
        }
      });
    }
  });
}

$(document).ready(function () {
  loadReminders($('#showInactive').is(':checked'));

  $('#showInactive, #hideCompleted').on('change', function () {
    loadReminders($('#showInactive').is(':checked'));
  });
});
</script>

<cfset script_name_include = "/include
