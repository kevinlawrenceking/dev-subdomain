<cfcontent type="text/html; charset=utf-8">
<cfoutput>
<div class="card">
  <div class="card-header d-flex justify-content-between align-items-center">
    <h4 class="mb-0">Reminders</h4>
    <div class="form-check">
      <input class="form-check-input" type="checkbox" id="showInactive">
      <label class="form-check-label" for="showInactive">Show inactive records</label>
    </div>
  </div>
  <div class="card-body">
    <div id="reminderMsg" class="alert d-none" role="alert"></div>
    <table id="remindersTable" class="table table-striped table-bordered" style="width:100%">
      <thead>
        <tr>
          <th>Action</th>
          <th>Reminder Text</th>
          <th>Due Date</th>
          <th>Status</th>
          <th>Last Updated</th>
        </tr>
      </thead>
      <tbody></tbody>
    </table>
  </div>
</div>
</cfoutput>

<!-- DataTables & Dependencies -->
<link rel="stylesheet" href="/app/assets/css/datatables.min.css">
<script src="/app/assets/js/jquery-3.6.0.min.js"></script>
<script src="/app/assets/js/datatables.min.js"></script>

<script>
$(document).ready(function(){
  var table = $('#remindersTable').DataTable({
    ajax: {
      url: '/app/ajax/get_reminders.cfm',
      dataSrc: 'data',
      data: function(d){
        d.showInactive = $('#showInactive').prop('checked') ? 1 : 0;
      }
    },
    columns: [
      { data: null, orderable:false, render: function(data){
          return '<button class="btn btn-sm btn-success complete" data-id="'+data.id+'">Complete</button>'+
                 ' <button class="btn btn-sm btn-warning skip" data-id="'+data.id+'">Skip</button>';
        }
      },
      { data: 'reminder_text' },
      { data: 'due_date' },
      { data: 'status' },
      { data: 'last_updated' }
    ],
    order: [[2,'asc']]
  });

  $('#showInactive').on('change', function(){
    table.ajax.reload();
  });

  $('#remindersTable').on('click', '.complete', function(){
    updateStatus($(this).data('id'), 'Completed');
  });

  $('#remindersTable').on('click', '.skip', function(){
    updateStatus($(this).data('id'), 'Skipped');
  });

  function updateStatus(id, status){
    $.post('/app/ajax/update_reminder_status.cfm', {reminder_id:id, new_status:status}, function(resp){
      if(resp.success){
        $('#reminderMsg').removeClass('d-none alert-danger').addClass('alert-success').text('Status updated');
        table.ajax.reload(null,false);
      }else{
        $('#reminderMsg').removeClass('d-none alert-success').addClass('alert-danger').text(resp.error || 'Error updating');
      }
    }, 'json').fail(function(){
      $('#reminderMsg').removeClass('d-none alert-success').addClass('alert-danger').text('Error updating');
    });
  }
});
</script>
