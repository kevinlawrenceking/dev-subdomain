<cfparam name="url.showInactive" default="0">
<cfset showInactive = url.showInactive>
<cfset dbug = "N">

<!-- Filter Checkbox -->
<cfoutput>
<div class="form-check mb-3">
  <input class="form-check-input" type="checkbox" id="showInactive" <cfif showInactive EQ "1">checked</cfif>>
  <label class="form-check-label" for="showInactive">
    Show Inactive (Skipped / Completed)
  </label>
</div>
</cfoutput>

<table class="table table-bordered table-striped table-sm" id="remindersTable">
  <thead class="thead-light">
    <tr>
      <th scope="col">Action</th>
      <th scope="col">Due</th>
      <th scope="col">Status</th>
      <th scope="col">Controls</th>
    </tr>
  </thead>
  <tbody id="reminderRows">
<cfloop query="sysActive">
  <cfinclude template="/include/qry/notsactive_510_1.cfm">
  <cfloop query="notsActive">
    <cfif notsActive.notstatus eq "Upcoming">
      <cfcontinue>
    </cfif>
    <cfif notsActive.notstatus eq "Pending" OR showInactive eq "1">
      <cfif (notsActive.notstatus eq "Completed" OR notsActive.notstatus eq "Skipped") AND showInactive eq "0">
        <cfcontinue>
      </cfif>
      <cfoutput>
      <tr id="not_#notsActive.notid#" class="#iif(notsActive.notstatus eq 'Skipped','skipped-row','')#">
        <td>
          <a href="" data-bs-toggle="modal" data-bs-target="##action#notsActive.notid#-modal" title="Click for details">
            <i class="fe-info font-14 mr-1"></i>
          </a>
          #notsActive.delstart# #notsActive.actiondetails# #notsActive.delend#
        </td>
        <td>#this.formatDate(notsActive.notstartdate)#</td>
        <td><cfif notsActive.notstatus eq 'Pending'>Pending<cfelse>#notsActive.notstatus#</cfif></td>
        <td>
          <cfif notsActive.notstatus eq 'Pending'>
            <input type="checkbox" class="completeReminder" data-id="#notsActive.notid#">
            <button class="btn btn-sm btn-link text-danger skipReminder" data-id="#notsActive.notid#">X</button>
          </cfif>
        </td>
      </tr>
      <tr style="display:none;">
        <td colspan="4">
          <div id="action#notsActive.notid#-modal" class="modal fade" tabindex="-1" role="dialog">
            <div class="modal-dialog">
              <div class="modal-content">
                <div class="modal-header">
                  <h4 class="modal-title">#notsActive.actiontitle#</h4>
                  <button type="button" class="close" data-bs-dismiss="modal">x</button>
                </div>
                <div class="modal-body">
                  <h5>#notsActive.actiondetails#</h5>
                  <p>#notsActive.actionInfo#</p>
                </div>
              </div>
            </div>
          </div>
        </td>
      </tr>
      </cfoutput>
    </cfif>
  </cfloop>
</cfloop>
</tbody>
</table>

<style>
.skipped-row td {
  text-decoration: line-through;
  color: #888;
}
</style>

<script>
$(document).ready(function () {
  // Completion Handler
  $('.completeReminder').on('change', function () {
    let notID = $(this).data('id');
    if (confirm("Mark this reminder as complete?")) {
      $.post('/app/ajax/update_notification_status.cfm', {
        notificationID: notID,
        status: 'Completed'
      }, function (res) {
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

  // Skip Handler
  $('.skipReminder').on('click', function () {
    let notID = $(this).data('id');
    if (confirm("Skip this reminder?")) {
      $.post('/app/ajax/update_notification_status.cfm', {
        notificationID: notID,
        status: 'Skipped'
      }, function (res) {
        if ($('#showInactive').is(':checked')) {
          $('#not_' + notID + ' td:eq(2)').text('Skipped');
          $('#not_' + notID).addClass('skipped-row');
        } else {
          $('#not_' + notID).fadeOut(300, function () { $(this).remove(); });
        }
      });
    }
  });

  // Filter Toggle
  $('#showInactive').on('change', function () {
    if (this.checked) {
      window.location.search = '?showInactive=1';
    } else {
      window.location.search = '?showInactive=0';
    }
  });
});
</script>

<cfset script_name_include = "/include/#ListLast(GetCurrentTemplatePath(), " \")#">
