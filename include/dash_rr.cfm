<!---
    PURPOSE: Dashboard Reminders Card - AJAX-driven with individual Complete/Skip buttons
    AUTHOR: Kevin King
    DATE: 2025-07-24
    DEPENDENCIES: services.NotificationService, /include/get_reminders.cfm, /include/complete_not_ajax.cfm
--->

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<cfset currentStartDate="#DateFormat(Now(),'yyyy-mm-dd')#" />
<cfinclude template="/include/qry/reminders_511_1.cfm" />

<style>
/* Dashboard Reminder Styles */
.reminder-row {
    border: 1px solid #e9ecef;
    border-radius: 6px;
    padding: 8px 12px;
    margin-bottom: 8px;
    background-color: #ffffff;
    transition: all 0.2s ease;
}

.reminder-row:hover {
    border-color: #adb5bd;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.reminder-contact {
    font-weight: 600;
    color: #495057;
    font-size: 14px;
}

.reminder-text {
    color: #6c757d;
    font-size: 12px;
    margin-top: 2px;
    line-height: 1.3;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    max-width: 200px;
}

.reminder-actions .btn {
    padding: 2px 6px;
    font-size: 11px;
    border-radius: 3px;
    margin-left: 4px;
}

.reminder-actions .btn i {
    font-size: 10px;
}

.dashboard-reminders-loading {
    text-align: center;
    padding: 20px;
    color: #6c757d;
}

.dashboard-reminders-empty {
    text-align: center;
    padding: 20px;
    color: #6c757d;
    font-style: italic;
}

#dashboardRemindersContainer {
    max-height: 300px;
    overflow-y: auto;
    overflow-x: hidden;
}

/* Ensure card body constrains content */
.dashboard-reminder-card .card-body {
    padding: 1rem;
    overflow: hidden;
    position: relative;
}

/* Ensure reminders don't break out of container */
.reminder-row {
    border: 1px solid #e9ecef;
    border-radius: 6px;
    padding: 8px 12px;
    margin-bottom: 8px;
    background-color: #ffffff;
    transition: all 0.2s ease;
    word-wrap: break-word;
    overflow: hidden;
    position: relative;
    z-index: 1;
}

/* Additional containment for the entire card */
.dashboard-reminder-card {
    overflow: hidden;
    position: relative;
    z-index: auto;
}
</style>

<cfoutput>
    <div class="card grid-item loaded dashboard-reminder-card" data-id="#dashboards.pnid#">
        <div class="card-header" id="heading_system_#dashboards.currentrow#">
            <h5 class="m-0">
                <a class="text-dark collapsed" data-bs-toggle="collapse" href="##collapse_system_#dashboards.currentrow#">
                    #dashboards.pnTitle# 
                    <span id="reminderCount" class="badge bg-primary"></span>
                </a>
            </h5>
        </div>
</cfoutput>

        <div class="card-body">
            <div id="dashboardRemindersContainer">
                <div class="dashboard-reminders-loading">
                    <i class="mdi mdi-loading mdi-spin"></i> Loading reminders...
                </div>
            </div>
            
            <div class="mt-3">
                <a href="/app/reminders/" 
                   class="badge badge-light text-dark" 
                   style="border: 1px solid #406E8E; outline: none; color: #406E8E; display: inline-block; padding: 6px 12px; text-decoration: none;">
                    <i class="mdi mdi-book-plus-multiple"></i> Open All
                </a>
            </div>
        </div><!--- card-body end --->
    </div><!--- end card --->

<script>
let dashboardSelectedReminder = {};

function loadDashboardReminders() {
    $.ajax({
        url: "/include/get_reminders.cfm",
        data: {
            showInactive: 0,
            currentid: 0,
            userid: <cfoutput>#userid#</cfoutput>,
            limit: 10  // Dashboard limit to 10 reminders
        },
        dataType: 'json',
        success: function(data) {
            renderDashboardReminders(data);
            updateReminderCount(data.length);
        },
        error: function() {
            $('#dashboardRemindersContainer').html(
                '<div class="dashboard-reminders-empty">Error loading reminders. Please refresh.</div>'
            );
        }
    });
}

function renderDashboardReminders(reminders) {
    const container = $('#dashboardRemindersContainer');
    
    if (reminders.length === 0) {
        container.html('<div class="dashboard-reminders-empty">You currently have no reminders!</div>');
        return;
    }
    
    let html = '';
    reminders.forEach(reminder => {
        html += `
            <div class="reminder-row d-flex justify-content-between align-items-center" data-reminder-id="${reminder.id}">
                <div class="flex-grow-1">
                    <div class="reminder-contact">
                        ${reminder.contactfullname}
                        <a href="/app/contact?contactid=${reminder.contactid}&t4=1" class="ms-1">
                            <i class="mdi mdi-eye-outline" style="font-size: 12px;"></i>
                        </a>
                    </div>
                    <div class="reminder-text">${reminder.reminder_text}</div>
                </div>
                <div class="reminder-actions">
                    <button class="btn btn-success btn-xs mark-complete" 
                            data-id="${reminder.id}" 
                            data-status="Completed" 
                            data-text="${reminder.reminder_text}" 
                            title="Mark Complete">
                        <i class="fas fa-check"></i>
                    </button>
                    <button class="btn btn-secondary btn-xs mark-skip" 
                            data-id="${reminder.id}" 
                            data-status="Skipped" 
                            data-text="${reminder.reminder_text}" 
                            title="Skip">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            </div>
        `;
    });
    
    container.html(html);
}

function updateReminderCount(count) {
    const countBadge = $('#reminderCount');
    if (count > 0) {
        countBadge.text(count).show();
    } else {
        countBadge.hide();
    }
}

function removeReminderFromDashboard(reminderId) {
    // Remove the completed reminder with animation
    const reminderRow = $(`[data-reminder-id="${reminderId}"]`);
    reminderRow.fadeOut(300, function() {
        $(this).remove();
        
        // Check if we need to load more reminders to maintain 10 visible
        const remainingCount = $('#dashboardRemindersContainer .reminder-row').length;
        if (remainingCount < 10) {
            loadDashboardReminders(); // Reload to potentially fill gaps
        }
    });
}

$(document).ready(function () {
    // Load reminders on page load
    loadDashboardReminders();

    // Handle Complete/Skip button clicks
    $('#dashboardRemindersContainer').on('click', '.mark-complete, .mark-skip', function () {
        dashboardSelectedReminder = {
            id: $(this).data('id'),
            status: $(this).data('status'),
            text: $(this).data('text')
        };

        $("#confirmReminderText").text(
            `Are you sure you want to mark "${dashboardSelectedReminder.text}" as ${dashboardSelectedReminder.status}?`
        );

        const confirmModal = new bootstrap.Modal(document.getElementById('confirmReminderModal'));
        confirmModal.show();
    });

    // Handle confirmation
    $('#confirmReminderButton').click(function () {
        $.post("/include/complete_not_ajax.cfm", {
            notid: dashboardSelectedReminder.id,
            notstatus: dashboardSelectedReminder.status
        }, function () {
            // Remove the reminder from dashboard and potentially backfill
            removeReminderFromDashboard(dashboardSelectedReminder.id);
            bootstrap.Modal.getInstance(document.getElementById('confirmReminderModal')).hide();
        });
    });
});
</script>

<!-- Confirmation Modal (reuse from reminder_pane.cfm) -->
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
