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
    transition: all 0.6s ease-out; /* Slower transition for smooth repositioning */
    word-wrap: break-word;
    overflow: hidden;
    position: relative;
    z-index: 1;
    opacity: 1;
    transform: translateY(0);
}

.reminder-row:hover {
    border-color: #adb5bd;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

/* Animation for new reminders */
.reminder-row.fade-in {
    animation: fadeInSlide 0.6s ease-out;
}

@keyframes fadeInSlide {
    0% {
        opacity: 0;
        transform: translateY(20px);
    }
    100% {
        opacity: 1;
        transform: translateY(0);
    }
}

/* Animation for completing reminders */
.reminder-row.completing {
    background-color: #d4edda;
    border-color: #c3e6cb;
    animation: pulseComplete 0.5s ease-in-out;
}

.reminder-row.skipping {
    background-color: #f8d7da;
    border-color: #f5c6cb;
    animation: pulseSkip 0.5s ease-in-out;
}

@keyframes pulseComplete {
    0% { background-color: #ffffff; }
    50% { background-color: #d4edda; }
    100% { background-color: #d4edda; }
}

@keyframes pulseSkip {
    0% { background-color: #ffffff; }
    50% { background-color: #f8d7da; }
    100% { background-color: #f8d7da; }
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
    height: 425px;
    overflow: hidden;
}

/* Ensure card body constrains content */
.dashboard-reminder-card .card-body {
    padding: 1rem;
    overflow: hidden;
    position: relative;
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
                    <!---<span id="reminderCount" class="badge bg-primary"></span> --->
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
                    <i class="mdi mdi-book-plus-multiple"></i> View All
                </a>
            </div>
        </div><!--- card-body end --->
    </div><!--- end card --->

<script>
let dashboardSelectedReminder = {};

function loadDashboardReminders() {
    $.ajax({
        url: "/include/get_dashboard_reminders.cfm",
        data: {
            showInactive: 0,
            currentid: 0,
            userid: <cfoutput>#userid#</cfoutput>,
            limit: 7  // Dashboard limit to 7 reminders (7 contacts)
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

function loadNewReminder() {
    // Load more reminders to find a truly new one (grouped by contact)
    $.ajax({
        url: "/include/get_dashboard_reminders.cfm",
        data: {
            showInactive: 0,
            currentid: 0,
            userid: <cfoutput>#userid#</cfoutput>,
            limit: 10  // Get more reminders to find new ones
        },
        dataType: 'json',
        success: function(data) {
            if (data.length > 0) {
                // Get currently displayed reminder IDs
                const existingIds = $('#dashboardRemindersContainer .reminder-row').map(function() {
                    return parseInt($(this).data('reminder-id'));
                }).get();
                
                // Find the first reminder that's not already displayed
                const newReminder = data.find(reminder => !existingIds.includes(parseInt(reminder.id)));
                
                if (newReminder) {
                    console.log('Adding new reminder:', newReminder.reminder_text);
                    addSingleReminder(newReminder);
                } else {
                    console.log('No new reminders available to add');
                }
            } else {
                console.log('No reminders returned from server');
            }
        },
        error: function() {
            console.log('Error loading new reminder');
        }
    });
}

function addSingleReminder(reminder) {
    const container = $('#dashboardRemindersContainer');
    const currentCount = container.find('.reminder-row').length;
    
    console.log('Current reminder count:', currentCount);
    console.log('Adding reminder for:', reminder.contactfullname);
    
    const newRow = $(`
        <div class="reminder-row d-flex justify-content-between align-items-center" 
             data-reminder-id="${reminder.id}" 
             style="opacity: 0; transform: translateY(20px); transition: all 0.6s ease-out;">
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
    `);
    
    container.append(newRow);
    
    // Trigger the fade-in animation
    setTimeout(() => {
        newRow.css({
            'opacity': '1',
            'transform': 'translateY(0)'
        });
        console.log('Animation triggered for new reminder');
    }, 100);
    
    // Update count
    const newCount = container.find('.reminder-row').length;
    console.log('New reminder count:', newCount);
    updateReminderCount(newCount);
}

function renderDashboardReminders(reminders) {
    const container = $('#dashboardRemindersContainer');
    
    if (reminders.length === 0) {
        container.html('<div class="dashboard-reminders-empty">You currently have no reminders!</div>');
        return;
    }
    
    let html = '';
    reminders.forEach((reminder, index) => {
        html += `
            <div class="reminder-row d-flex justify-content-between align-items-center fade-in" 
                 data-reminder-id="${reminder.id}" 
                 style="animation-delay: ${index * 0.1}s;">
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

function removeReminderFromDashboard(reminderId, status) {
    // Add visual feedback first
    const reminderRow = $(`[data-reminder-id="${reminderId}"]`);
    
    console.log('Removing reminder:', reminderId, 'Status:', status);
    
    // Add completion/skip animation class
    if (status === 'Completed') {
        reminderRow.addClass('completing');
    } else {
        reminderRow.addClass('skipping');
    }
    
    // Wait for the pulse animation, then slide up
    setTimeout(() => {
        // First, slide up and fade the completed reminder
        reminderRow.animate({
            height: 0,
            marginBottom: 0,
            paddingTop: 0,
            paddingBottom: 0,
            opacity: 0
        }, 800, 'swing', function() {
            $(this).remove();
            
            // Check if we need to load more reminders to maintain 7 visible
            const remainingCount = $('#dashboardRemindersContainer .reminder-row').length;
            console.log('Remaining count after removal:', remainingCount);
            
            if (remainingCount < 7) {
                console.log('Loading new reminder to fill gap...');
                // Add a slight delay before loading new reminder for better UX
                setTimeout(() => {
                    loadNewReminder();
                }, 200);
            } else {
                console.log('No need to load new reminder, still have 7');
            }
        });
    }, 500); // Wait for pulse animation to complete
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
            // Remove the reminder from dashboard with visual feedback
            removeReminderFromDashboard(dashboardSelectedReminder.id, dashboardSelectedReminder.status);
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