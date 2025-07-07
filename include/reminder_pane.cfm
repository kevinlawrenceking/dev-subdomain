<!-- Reminder Filters -->
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
<table class="table table-bordered table-striped table-sm" id="remindersTable" data-contactid="#contactid#">
  <thead class="thead-light">
    <tr>
      <th scope="col">Action</th>
      <th scope="col">Due</th>
      <th scope="col">Status</th>
      <th scope="col">Controls</th>
    </tr>
  </thead>
  <tbody id="reminderRows">
    <!-- Loaded via AJAX -->
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
<script>
function loadReminders(showInactive) {
  const contactid = $('#remindersTable').data('contactid') || 0;
  const hideCompleted = $('#hideCompleted').is(':checked') ? 1 : 0;

  console.log('[AJAX] Requesting reminders:', {
    showInactive,
    contactid,
    hideCompleted
  });

  $.get('/app/ajax/load_reminders.cfm', {
    showInactive: showInactive ? 1 : 0,
    contactid: contactid,
    HIDE_COMPLETED: hideCompleted
  }, function (html) {
    console.log('[AJAX] Raw HTML response:', html);

    const container = document.createElement('div');
    container.innerHTML = html;

    const newRows = container.querySelectorAll('#reminderRows > tr');
    const modalContent = container.querySelector('#modalContainer');

    if (newRows.length > 0) {
      $('#reminderRows').empty();
      newRows.forEach(row => $('#reminderRows').append(row));
      console.log(`[AJAX] Injected ${newRows.length} rows into #reminderRows`);
    } else {
      console.warn('[AJAX] No <tr> rows found in #reminderRows');
    }

    if (modalContent) {
      $('#modalContainer').html(modalContent.innerHTML);
      console.log('[AJAX] Modal container updated');
    } else {
      console.warn('[AJAX] Modal container NOT FOUND');
    }
    bindReminderHandlers();
  });
}



function bindReminderHandlers() {
  $('.completeReminder').off('change').on('change', function () {
    const notID = $(this).data('id');
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
    const notID = $(this).data('id');
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


<cfset script_name_include = "/include/#ListLast(GetCurrentTemplatePath(), " \")#">
