<!--- Param defaults --->
<cfparam name="contact_expand" default="true">
<cfparam name="a" default="0">
<cfparam name="d" default="0">
<cfparam name="s" default="0">
<cfparam name="contactcheckvisible" default="false">
<cfparam name="maintenance_expand" default="false">
<cfparam name="bytag" default="">
<cfparam name="target_expand" default="false">
<cfparam name="followup_expand" default="false">
<cfparam name="all_expand" default="false">
<cfparam name="pgaction" default="view">
<cfif NOT isDefined('session.pgaction')>
  <cfset session.pgaction = "view">
</cfif>

<!--- Page Content --->
<div class="row">
  <div class="card w-100">
    <div class="card-body">
      <!-- Header -->
      <div class="col-md-12">
        <div class="media p-2">
          <cfoutput>
            <figure class="text-center">
              <img src="/media-#dsn#/users/#userid#/avatar.jpg?ver=#rand()#" class="mr-3 rounded-circle gambar img-responsive img-thumbnail" style="height:80px;" alt="profile-image" id="item-img-output">
              <figcaption></figcaption>
            </figure>
            <div class="media-body pl-2">
              <h3 class="mt-0 mb-0">#userfirstname# #userlastname#</h3>
              <p class="mt-1 mb-0 text-muted font-12">
                <strong>Report Date: #dateFormat(now(), 'medium')#</strong><br>
                <a href="https://#host#.theactorsoffice.com/share/export.cfm?u=#u#" class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: ##406e8e; border: ##406e8e;">
                  Download <i class="fe-download"></i>
                </a>
              </p>
            </div>
          </cfoutput>
        </div>
      </div>

      <!-- Table -->
      <table id="basic-datatable" class="table table-striped table-bordered w-100">
        <thead>
          <tr>
            <th></th>
            <th>Name</th>
            <cfif isDefined("auditions")>
              <th>Auditionz</th>
            </cfif>
            <th>Company</th>
            <th>Title</th>
            <th>Audition Status</th>
            <th>Where Met</th>
            <th>When Met</th>
            <th>Notes</th>
          </tr>
        </thead>
        <tbody>
          <cfloop query="shares">
            <cfquery name="events" datasource="#dsn#">
              SELECT eventid, eventTitle, eventDescription, eventLocation, eventstatus, eventcreation,
                     eventStart, eventStop, eventTypeName, userid, eventStartTime, eventStopTime,
                     recordname, contactid, isDeleted
              FROM events
              WHERE contactid = <cfqueryparam value="#shares.CONTACTID#" cfsqltype="cf_sql_integer">
              AND EventTypeName IN ('Meeting', 'Audition')
              ORDER BY eventCreation
            </cfquery>

            <cfoutput>
              <tr>
                <!-- View Icon -->
                <td style="white-space: nowrap;">
                  <a href="javascript:;" data-bs-toggle="modal" data-bs-target="##remoteShareViewC#shares.contactid#"
                     title="View Contact Info and Audition List">
                    <i class="fe-search"></i>
                  </a>
                </td>

                <!-- Name + Badge -->
                <td style="white-space: nowrap;">
                  #name#
                  <cfif events.recordcount GT 0>
                    <span class="badge badge-primary badge-pill">#events.recordcount#</span>
                  </cfif>
                </td>

                <!-- Optional audition count -->
                <cfif isDefined("auditions")>
                  <td style="white-space: nowrap;">#events.recordcount#</td>
                </cfif>

                <!-- Other Fields -->
                <td style="white-space: nowrap;">#Company#</td>
                <td style="white-space: nowrap;">#Title#</td>
                <td style="white-space: nowrap;">#audition#</td>
                <td style="white-space: nowrap;">#Wheremet#</td>
                <td style="white-space: nowrap;">#dateFormat(whenmet, 'medium')#</td>

                <!-- Notes (wrapped) -->
                <cfset NotesLog2 = replace(NotesLog, "..", ".", "all")>
<td style="max-width: 400px; white-space: normal !important; word-break: break-word !important; overflow-wrap: break-word !important;">#NotesLog2#</td>


              </tr>
            </cfoutput>
          </cfloop>
        </tbody>
      </table>
    </div>
  </div>
</div>

<!-- DataTables Script -->
<script>
  $(document).ready(function () {
    $("#basic-datatable").DataTable({
      responsive: false,
      searching: true,
      autoWidth: false,
      columnDefs: [
        { targets: 8, width: "400px", className: "text-wrap" }, // Notes column
        { targets: "_all", width: "1%", className: "text-nowrap" }
      ],
      language: {
        paginate: {
          previous: "<i class='mdi mdi-chevron-left'>",
          next: "<i class='mdi mdi-chevron-right'>"
        }
      },
      drawCallback: function () {
        $(".dataTables_paginate > .pagination").addClass("pagination-rounded");
      }
    });
  });
</script>
