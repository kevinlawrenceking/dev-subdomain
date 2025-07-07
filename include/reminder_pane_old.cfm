<!--- Get DSN --->
<cfset host = ListFirst(cgi.server_name, ".")>
<cfif host EQ "app">
  <cfset dsn = "abo">
<cfelse>
  <cfset dsn = "abod">
</cfif>


<!--- Get Contact ID --->
<cfparam name="contactid" default="0">

<!--- Determine user_id --->
<cfif structKeyExists(session, "user_id")>
  <cfset sessionUserId = session.user_id>
<cfelse>
  <!-- Fallback if session is lost or not available -->
  <cfquery name="findUser" >
    SELECT userid FROM contactdetails WHERE contactid = <cfqueryparam value="#contactid#" cfsqltype="cf_sql_integer">
  </cfquery>
  <cfif findUser.recordCount>
    <cfset sessionUserId = findUser.userid>
  <cfelse>
    <cfoutput><div class="alert alert-danger">No user session and unable to find user from contact ID #contactid#.</div></cfoutput>
    <cfabort>
  </cfif>
</cfif>






<cfif NOT structKeyExists(variables, "sysActiveSuid")>
  <cfquery name="getSu" >
    SELECT suid
    FROM fusystemusers
    WHERE contactid = <cfqueryparam value="#contactid#" cfsqltype="cf_sql_integer">
      AND userid = <cfqueryparam value="#session.user_id#" cfsqltype="cf_sql_integer">
      AND sustatus = 'Active'
  </cfquery>

  <cfif getSu.recordCount>
    <cfset sysActiveSuid = getSu.suid>
  <cfelse>
    <cfoutput><div class="alert alert-warning">No active system user found for this contact.</div></cfoutput>
    <cfabort>
  </cfif>
</cfif>


<!--- Reminder Filters (disabled since no AJAX) --->
<div class="form-check mb-2">
  <input class="form-check-input" type="checkbox" id="showInactive" disabled>
  <label class="form-check-label" for="showInactive">
    Show Inactive (Skipped / Completed)
  </label>
</div>
<div class="form-check mb-3">
  <input class="form-check-input" type="checkbox" id="hideCompleted" disabled>
  <label class="form-check-label" for="hideCompleted">
    Hide Completed Only
  </label>
</div>

<!--- Reminders Table --->
<cfquery name="qReminders" >
  SELECT
    n.notID,
    n.notStatus,
    n.notStartDate,
    a.actionTitle,
    a.actionDetails,
    a.actionInfo
  FROM funotifications n
  INNER JOIN fusystemusers f ON f.suID = n.suID
  INNER JOIN fuactions a ON a.actionID = n.actionID
  INNER JOIN notstatuses ns ON ns.notstatus = n.notStatus
  WHERE f.contactID = <cfqueryparam value="#contactid#" cfsqltype="cf_sql_integer">
    AND f.suID = <cfqueryparam value="#sysActiveSuid#" cfsqltype="cf_sql_integer">
    AND n.notStartDate IS NOT NULL
    AND n.notStartDate <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
    AND n.notStatus = 'Pending'
  ORDER BY 
    FIELD(n.notStatus, 'Pending', 'Completed', 'Skipped'),
    n.notStartDate
</cfquery>

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
    <cfoutput query="qReminders">
      <tr id="not_#notID#" class="#iif(notStatus EQ 'Skipped', 'skipped-row', '')#">
        <td>
          <a href="##" data-bs-toggle="modal" data-bs-target="##action#notID#-modal" title="Click for details">
            <i class="fe-info font-14 mr-1"></i>
          </a>
          #actionDetails#
        </td>
        <td>#dateformat(notStartDate, "mm/dd/yyyy")#</td>
        <td>#notStatus#</td>
        <td>
          <input type="checkbox" class="completeReminder" data-id="#notID#">
          <button class="btn btn-sm btn-link text-danger skipReminder" data-id="#notID#">X</button>
        </td>
      </tr>
    </cfoutput>
  </tbody>
</table>

<!--- Modals --->
<div id="modalContainer">
  <cfoutput query="qReminders">
    <div id="action#notID#-modal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">#actionTitle#</h4>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <h5>#actionDetails#</h5>
            <p>#actionInfo#</p>
          </div>
        </div>
      </div>
    </div>
  </cfoutput>
</div>

<style>
.skipped-row td {
  text-decoration: line-through;
  color: #888;
}
</style>

<script>
  // Optional: still enable button functionality without AJAX
  function bindReminderHandlers() {
    $('.completeReminder').off('change').on('change', function () {
      const notID = $(this).data('id');
      if (confirm("Mark this reminder as complete?")) {
        $.post('/app/ajax/update_notification_status.cfm', {
          notificationID: notID,
          status: 'Completed'
        }, function () {
          $('#not_' + notID + ' td:eq(2)').text('Completed');
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
          $('#not_' + notID + ' td:eq(2)').text('Skipped');
          $('#not_' + notID).addClass('skipped-row');
        });
      }
    });
  }

  $(document).ready(function () {
    bindReminderHandlers();
  });
</script>
