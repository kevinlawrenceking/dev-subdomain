<cfparam name="url.showInactive" default="0">
<cfparam name="url.contactid" default="0">
<cfparam name="contactid" default="0">
<cfparam name="showContact" default="N">
<!--- here --->



<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<cfset showInactive = url.showInactive>

<div class="card mt-3">
  <div class="card-header d-flex justify-content-between align-items-center">
    <h5 class="mb-0">Notifications</h5>
    <div class="form-check">
      <input class="form-check-input" type="checkbox" id="showInactive" value="1" <cfif showInactive EQ 1>checked</cfif>>
      <label class="form-check-label" for="showInactive">Show action log</label>
    </div>
  </div>
<Cfif showContact eq "N">
<Cfset contactVisible = "none"/>
<Cfset contactVisibilty = "false"/>
<cfelse>
<Cfset contactVisible = ""/>
<Cfset contactVisibilty = "true"/>
</cfif>

  <div class="card-body">
    <table id="NotificationsTable" class="table table-striped table-bordered table-sm w-100">
      <thead>
        <tr>
          <th style="white-space: nowrap;">Date Received</th>
          <th>From</th>
          <th>Subject</th>
          <th>Message</th>
        </tr>
      </thead>
    </table>
  </div>
</div>

<script>
  function loadNotifications() {
    const showInactive = $("#showInactive").is(":checked") ? 1 : 0;
    
    console.log('Loading Notifications with showInactive:', showInactive);

    // Check if DataTable already exists
    if ($.fn.DataTable.isDataTable('#NotificationsTable')) {
      // Just reload the data instead of destroying the whole table
      const table = $('#NotificationsTable').DataTable();
      const newAjaxData = {
        showInactive: showInactive,
        currentid: <cfoutput>#contactid#</cfoutput>,
        userid: <cfoutput>#userid#</cfoutput>
      };
      
      // Update the ajax data and reload
      table.ajax.url("/include/get_notifications.cfm?bypass=1").load();
      
      // Update the ajax data for future requests
      table.ajax.data(newAjaxData);
      return;
    }

    $('#NotificationsTable').DataTable({
      ajax: {
        url: "/include/get_notifications.cfm?bypass=1",
        data: {
          showInactive: showInactive,
          currentid: <cfoutput>#contactid#</cfoutput>,
          userid: <cfoutput>#userid#</cfoutput>
        },
        dataSrc: function (json) {
          return json;
        }
      },
      columns: [
        { 
          data: "date_received",
          className: "text-nowrap"
        },
        { 
          data: "from"
        },
        { 
          data: "subject"
        },
        { 
          data: "message",
          render: function (data, type, row) {
            if (type === 'display' && data && data.length > 100) {
              return data.substring(0, 100) + '...';
            }
            return data;
          }
        }
      ],
      language: {
        emptyTable: showInactive ? "No notifications found" : "No unread notifications"
      },
      pageLength: 25,
      responsive: false, // Disable green icon 
      order: [[0, 'desc']] // Order by Date Received descending
    });
  }

  $(document).ready(function () {
    loadNotifications();

    $("#showInactive").change(function () {
      loadNotifications();
    });
  });
</script>
