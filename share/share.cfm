<!---
    PURPOSE: Display shared contact information in a datatable (OPTIMIZED)
    AUTHOR: Updated by GitHub Copilot
    DATE: 2025-07-21
    PARAMETERS: userid, shares query
    DEPENDENCIES: remote_load_common.cfm
    OPTIMIZATIONS: Single JOIN query, Bootstrap 4.6 compliant, secure parameterization
--->

<!--- Include common variables and settings --->
<cfinclude template="remote_load_common.cfm">

<!--- Consolidated cfparam definitions --->
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
<cfparam name="auditions" default="true">

<!--- Set session pgaction if not defined --->
<cfif NOT structKeyExists(session, 'pgaction')>
  <cfset session.pgaction = "view">
</cfif>

<!--- OPTIMIZED QUERY: Single JOIN to get shares with event counts --->
<cfif structKeyExists(variables, 'new_userid') AND len(trim(new_userid))>
  <cfquery name="sharesWithEvents" datasource="#application.dsn#">
    SELECT DISTINCT 
      s.contactid,
      s.Name,
      s.Company,
      s.Title,
      s.Audition,
      s.WhereMet,
      s.WhenMet,
      s.NotesLog,
      s.userid,
      s.u,
      COALESCE(e.eventCount, 0) AS eventCount
    FROM sharez s
    LEFT JOIN (
      SELECT 
        contactid, 
        COUNT(eventid) AS eventCount
      FROM events 
      WHERE EventTypeName IN ('Meeting', 'Audition')
        AND isDeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit">
      GROUP BY contactid
    ) e ON s.contactid = e.contactid
    WHERE s.userid = <cfqueryparam value="#new_userid#" cfsqltype="cf_sql_integer">
    ORDER BY s.Name
  </cfquery>
<cfelse>
  <!--- Fallback empty query if no valid userid --->
  <cfquery name="sharesWithEvents" datasource="#application.dsn#">
    SELECT 0 as contactid, '' as Name, '' as Company, '' as Title, 
           '' as audition, '' as WhereMet, 
           <cfqueryparam value="#CreateODBCDate(Now())#" cfsqltype="cf_sql_timestamp"> as WhenMet, 
           '' as NotesLog, 0 as userid, '' as u, 0 as eventCount
    WHERE 1=0
  </cfquery>
</cfif>

<!--- Bootstrap 4.6 compliant layout --->
<div class="container-fluid">
  <div class="row">
    <div class="col-12">
      <div class="card shadow-sm">
        <div class="card-body">
          
          <!--- Header Section: User Info & Export --->
          <div class="row mb-4">
            <div class="col-12">
              <div class="d-flex align-items-center">
                <cfoutput>
                  <div class="flex-shrink-0 me-3">
                    <img src="/media-#application.dsn#/users/#new_userid#/avatar.jpg?ver=#RandRange(1, 1000000)#" 
                         class="rounded-circle img-thumbnail" 
                         style="width: 80px; height: 80px; object-fit: cover;" 
                         alt="User Avatar" 
                         onerror="this.src='/assets/images/default-avatar.png';">
                  </div>
                  <div class="flex-grow-1">
                    <h3 class="mb-1">
                      <cfif structKeyExists(variables, 'userfirstname') AND structKeyExists(variables, 'userlastname')>
                        #userfirstname# #userlastname#
                      <cfelse>
                        Shared Contact Report
                      </cfif>
                    </h3>
                    <p class="text-muted mb-2">
                      <strong>Report Date:</strong> #dateFormat(now(), 'medium')#
                      <span class="badge badge-info ms-2">#sharesWithEvents.recordCount# contacts</span>
                    </p>
                    <cfif structKeyExists(variables, 'u') AND len(trim(u))>
                      <a href="https://#host#.theactorsoffice.com/share/export.cfm?u=#u#" 
                         class="btn btn-primary btn-sm">
                        <i class="fe-download me-1"></i> Download Report
                      </a>
                    </cfif>
                  </div>
                </cfoutput>
              </div>
            </div>
          </div>

          <!--- Search Bar --->
          <div class="row mb-3">
            <div class="col-md-6">
              <div class="input-group">
                <input type="text" id="contactSearch" class="form-control" placeholder="Search contacts..." aria-label="Search contacts">
                <div class="input-group-append">
                  <span class="input-group-text"><i class="fe-search"></i></span>
                </div>
              </div>
            </div>
          </div>

          <!--- Responsive Table Container --->
          <div class="row">
            <div class="col-12">
              <div class="table-responsive">
                <table id="contactsTable" class="table table-striped table-hover" style="width: 100%;">
                  <thead class="thead-light">
                    <tr>
                      <th class="text-center" style="width: 50px;" aria-label="Actions">
                        <i class="fe-eye" title="View Details"></i>
                      </th>
                      <th>Name</th>
                      <cfif structKeyExists(variables, 'auditions') AND auditions>
                        <th class="text-center" style="width: 100px;">Events</th>
                      </cfif>
                      <th>Company</th>
                      <th>Title</th>
                      <th>Status</th>
                      <th>Where Met</th>
                      <th>When Met</th>
                      <th style="width: 300px;">Notes</th>
                    </tr>
                  </thead>
                  <tbody>
                    <cfoutput query="sharesWithEvents">
                      <tr>
                        <!--- View Details Button --->
                        <td class="text-center">
                          <button type="button" 
                                  class="btn btn-sm btn-outline-primary" 
                                  data-bs-toggle="modal" 
                                  data-bs-target="##contactModal#sharesWithEvents.contactid#"
                                  title="View Contact Details"
                                  aria-label="View details for #HTMLEditFormat(sharesWithEvents.Name)#">
                            <i class="fe-search"></i>
                          </button>
                        </td>

                        <!--- Name with Event Badge --->
                        <td>
                          <span class="fw-medium">#HTMLEditFormat(sharesWithEvents.Name)#</span>
                          <cfif sharesWithEvents.eventCount GT 0>
                            <span class="badge badge-primary badge-pill ms-1" 
                                  title="#sharesWithEvents.eventCount# events">
                              #sharesWithEvents.eventCount#
                            </span>
                          </cfif>
                        </td>

                        <!--- Optional Events Column --->
                        <cfif structKeyExists(variables, 'auditions') AND auditions>
                          <td class="text-center">
                            <span class="badge badge-secondary">#sharesWithEvents.eventCount#</span>
                          </td>
                        </cfif>

                        <!--- Company --->
                        <td>
                          <cfif len(trim(sharesWithEvents.Company))>
                            #HTMLEditFormat(sharesWithEvents.Company)#
                          <cfelse>
                            <span class="text-muted">-</span>
                          </cfif>
                        </td>

                        <!--- Title --->
                        <td>
                          <cfif len(trim(sharesWithEvents.Title))>
                            #HTMLEditFormat(sharesWithEvents.Title)#
                          <cfelse>
                            <span class="text-muted">-</span>
                          </cfif>
                        </td>

                        <!--- Audition Status --->
                        <td>
                          <cfif len(trim(sharesWithEvents.Audition))>
                            <span class="badge badge-info">#HTMLEditFormat(sharesWithEvents.Audition)#</span>
                          <cfelse>
                            <span class="text-muted">-</span>
                          </cfif>
                        </td>

                        <!--- Where Met --->
                        <td>
                          <cfif len(trim(sharesWithEvents.WhereMet))>
                            #HTMLEditFormat(sharesWithEvents.WhereMet)#
                          <cfelse>
                            <span class="text-muted">-</span>
                          </cfif>
                        </td>

                        <!--- When Met --->
                        <td>
                          <cfif isDate(sharesWithEvents.WhenMet)>
                            <time datetime="#dateFormat(sharesWithEvents.WhenMet, 'yyyy-mm-dd')#">
                              #dateFormat(sharesWithEvents.WhenMet, 'medium')#
                            </time>
                          <cfelse>
                            <span class="text-muted">-</span>
                          </cfif>
                        </td>

                        <!--- Notes with Truncation --->
                        <td>
                          <cfset cleanNotes = len(trim(sharesWithEvents.NotesLog)) ? 
                                             replace(sharesWithEvents.NotesLog, "..", ".", "all") : "">
                          <cfif len(cleanNotes) GT 100>
                            <span class="text-truncate d-inline-block" 
                                  style="max-width: 280px;" 
                                  title="#HTMLEditFormat(cleanNotes)#">
                              #HTMLEditFormat(left(cleanNotes, 100))#...
                            </span>
                          <cfelseif len(cleanNotes) GT 0>
                            #HTMLEditFormat(cleanNotes)#
                          <cfelse>
                            <span class="text-muted">No notes</span>
                          </cfif>
                        </td>
                      </tr>
                    </cfoutput>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>
  </div>
</div>

<!--- Contact Detail Modals (Generated Once) --->
<cfoutput>
  <cfloop query="sharesWithEvents">
    <div class="modal fade" 
         id="contactModal#sharesWithEvents.contactid#" 
         tabindex="-1" 
         role="dialog" 
         aria-labelledby="contactModalLabel#sharesWithEvents.contactid#" 
         aria-hidden="true">
      <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="contactModalLabel#sharesWithEvents.contactid#">
              Contact Details: #HTMLEditFormat(sharesWithEvents.Name)#
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <div class="spinner-border text-primary" role="status" aria-hidden="true">
              <span class="sr-only">Loading...</span>
            </div>
            <span class="ms-2">Loading contact details...</span>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          </div>
        </div>
      </div>
    </div>
  </cfloop>
</cfoutput>

<!--- Optimized DataTables Configuration --->
<script>
$(document).ready(function() {
  // Remove loading spinner from body
  $('body').removeClass('loading');
  
  // Configure column definitions based on auditions column
  <cfif structKeyExists(variables, 'auditions') AND auditions>
    var columnDefs = [
      { targets: 0, width: "50px", orderable: false, searchable: false, className: "text-center" },
      { targets: 1, width: "200px", className: "fw-medium" },
      { targets: 2, width: "80px", orderable: false, className: "text-center" },
      { targets: [3,4,5,6,7], width: "120px" },
      { targets: 8, width: "300px", orderable: false }
    ];
  <cfelse>
    var columnDefs = [
      { targets: 0, width: "50px", orderable: false, searchable: false, className: "text-center" },
      { targets: 1, width: "200px", className: "fw-medium" },
      { targets: [2,3,4,5,6], width: "120px" },
      { targets: 7, width: "300px", orderable: false }
    ];
  </cfif>
  
  // Initialize DataTable with optimized settings
  var table = $('#contactsTable').DataTable({
    responsive: true,
    searching: true,
    autoWidth: false,
    pageLength: 25,
    lengthMenu: [[10, 25, 50, 100], [10, 25, 50, 100]],
    dom: '<"row"<"col-sm-12 col-md-6"l><"col-sm-12 col-md-6"f>>' +
         '<"row"<"col-sm-12"tr>>' +
         '<"row"<"col-sm-12 col-md-5"i><"col-sm-12 col-md-7"p>>',
    columnDefs: columnDefs,
    order: [[1, 'asc']], // Sort by name by default
    language: {
      search: "Search contacts:",
      lengthMenu: "Show _MENU_ contacts per page",
      info: "Showing _START_ to _END_ of _TOTAL_ contacts",
      emptyTable: "No contacts available",
      zeroRecords: "No contacts match your search criteria",
      paginate: {
        previous: '<i class="fe-chevron-left"></i>',
        next: '<i class="fe-chevron-right"></i>'
      }
    },
    drawCallback: function() {
      // Add Bootstrap styling to pagination
      $('.dataTables_paginate > .pagination').addClass('pagination-sm');
    }
  });
  
  // Connect custom search input to DataTable
  $('#contactSearch').on('keyup', function() {
    table.search(this.value).draw();
  });
  
  // AJAX Modal Loading
  <cfoutput query="sharesWithEvents">
    $('#contactModal#sharesWithEvents.contactid#').on('show.bs.modal', function(event) {
      var modal = $(this);
      var modalBody = modal.find('.modal-body');
      
      // Load contact details via AJAX
      modalBody.load('share_contact_details.cfm?contactid=#sharesWithEvents.contactid#', function(response, status) {
        if (status === "error") {
          modalBody.html('<div class="alert alert-danger">Error loading contact details. Please try again.</div>');
        }
      });
    });
  </cfloop>
  
  // Reset modal content when hidden
  $('.modal').on('hidden.bs.modal', function() {
    $(this).find('.modal-body').html(
      '<div class="spinner-border text-primary" role="status" aria-hidden="true">' +
      '<span class="sr-only">Loading...</span></div>' +
      '<span class="ms-2">Loading contact details...</span>'
    );
  });
});
</script>
