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
      s.last_met,
      s.no_mtgs,
      s.lasteventtype,
      s.NotesLog,
      s.userid,
      s.userHash 
 
    FROM sharez s
    WHERE s.userid = <cfqueryparam value="#new_userid#" cfsqltype="cf_sql_integer">
    ORDER BY s.Name
  </cfquery>
<cfelse>
  <!--- Fallback empty query if no valid userid --->
  <cfquery name="sharesWithEvents" datasource="#application.dsn#">
    SELECT 0 as contactid, '' as Name, '' as Company, '' as Title, 
           '' as audition, '' as last_met, 0 as no_Mtgs, 
           <cfqueryparam value="#CreateODBCDate(Now())#" cfsqltype="cf_sql_timestamp"> as lasteventtype, 
           '' as NotesLog, 0 as userid, '' as userHash
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
              <div class="d-flex align-items-center py-4">
                <cfoutput>
                  <div class="flex-shrink-0 me-3">
                    <img src="/media-#application.dsn#/users/#new_userid#/avatar.jpg?ver=#RandRange(1, 1000000)#" 
                         class="rounded-circle img-thumbnail" 
                         style="width: 100px; height: 100px; object-fit: cover;" 
                         alt="User Avatar" 
                         onerror="this.src='/assets/images/default-avatar.png';">
                  </div>
                  <div class="flex-grow-1">
                    <h2 class="mb-2">
                      <cfif structKeyExists(variables, 'userfirstname') AND structKeyExists(variables, 'userlastname')>
                        #userfirstname# #userlastname#
                      <cfelse>
                        Shared Contact Report
                      </cfif>
                    </h2>
                    <p class="text-muted mb-3 lead">
                      <strong>Report Date:</strong> #dateFormat(now(), 'medium')#
                      <span class="badge badge-info ms-3 px-3 py-2">#sharesWithEvents.recordCount# contacts</span>
                    </p>
                    <cfif structKeyExists(variables, 'u') AND len(trim(u))>
                      <a href="https://#host#.theactorsoffice.com/share/export.cfm?u=#u#" 
                         class="btn btn-primary">
                        <i class="fe-download me-2"></i> Download Report
                      </a>
                    </cfif>
                  </div>
                </cfoutput>
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
                        <i class="mdi mdi-eye" title="View Details"></i>
                      </th>
                      <th style="white-space: nowrap;">Name</th>
                      <cfif structKeyExists(variables, 'auditions') AND auditions>
                        <th class="text-center" style="width: 100px;">Events</th>
                      </cfif>
                      <th style="white-space: nowrap;">Company</th>
                      <th style="white-space: nowrap;">Title</th>
                      <th style="white-space: nowrap;">Status</th>
                      <th style="white-space: nowrap;">Mtg. Type</th>
                      <th style="white-space: nowrap;">Last Met</th>
                      <th style="white-space: nowrap;">Total Mtgs.</th>
                    </tr>
                  </thead>
                  <tbody>
                    <cfoutput query="sharesWithEvents">
                      <tr>
                        <!--- View Details Button --->
                        <td class="text-center">
                          <button type="button" 
                                  class="btn btn-sm btn-outline-primary view-contact-btn" 
                                  data-toggle="modal" 
                                  data-target="##contactDetailsModal"
                                  data-contactid="#sharesWithEvents.contactid#"
                                  data-contactname="#HTMLEditFormat(sharesWithEvents.Name)#"
                                  data-notes="#HTMLEditFormat(len(trim(sharesWithEvents.NotesLog)) ? replace(sharesWithEvents.NotesLog, '.', '.', 'all') : '')#"
                                  title="View Contact Details"
                                  aria-label="View details for #HTMLEditFormat(sharesWithEvents.Name)#">
                            <i class="mdi mdi-eye"></i>
                          </button>
                        </td>

                        <!--- Name with Event Badge --->
                        <td>
                          <span class="fw-medium">#HTMLEditFormat(sharesWithEvents.Name)#</span>
                          <cfif sharesWithEvents.no_mtgs GT 0>
                            <span class="badge badge-primary badge-pill ms-1" 
                                  title="#sharesWithEvents.no_mtgs# events">
                              #sharesWithEvents.no_mtgs#
                            </span>
                          </cfif>
                        </td>

                        <!--- Optional Events Column --->
                        <cfif structKeyExists(variables, 'auditions') AND auditions>
                          <td class="text-center">
                            <span class="badge badge-secondary">#sharesWithEvents.no_mtgs#</span>
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

                        <!--- Meeting Type --->
                        <td>
                          <cfif len(trim(sharesWithEvents.lasteventtype))>
                            #HTMLEditFormat(sharesWithEvents.lasteventtype)#
                          <cfelse>
                            <span class="text-muted">-</span>
                          </cfif>
                        </td>


            <!--- Where Met --->
                        <td>
                          <cfif len(trim(sharesWithEvents.last_met))>
                            #HTMLEditFormat(sharesWithEvents.last_met)#
                          <cfelse>
                            <span class="text-muted">-</span>
                          </cfif>
                        </td>
     <!--- no_mtgs --->
                        <td>
                          <cfif len(trim(sharesWithEvents.no_mtgs))>
                            #sharesWithEvents.no_mtgs#
                          <cfelse>
                            <span class="text-muted">-</span>
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

<!--- Single Reusable Contact Detail Modal --->
<div class="modal fade" 
     id="contactDetailsModal" 
     tabindex="-1" 
     role="dialog" 
     aria-labelledby="contactDetailsModalLabel" 
     aria-hidden="true">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="contactDetailsModalLabel">
          Contact Details
        </h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <div class="spinner-border text-primary" role="status" aria-hidden="true">
          <span class="sr-only">Loading...</span>
        </div>
        <span class="ml-2">Loading contact details...</span>
        
        <!--- Notes Section (will be shown after AJAX loads) --->
        <div id="notesSection" style="display: none;">
          <hr class="my-4">
          <h6 class="mb-3"><i class="mdi mdi-note-text mr-2"></i>Notes</h6>
          <div id="notesContent">
            <!--- Notes content will be populated dynamically --->
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>

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
      { targets: [3,4,5,6,7], width: "150px" }
    ];
  <cfelse>
    var columnDefs = [
      { targets: 0, width: "50px", orderable: false, searchable: false, className: "text-center" },
      { targets: 1, width: "200px", className: "fw-medium" },
      { targets: [2,3,4,5,6], width: "150px" }
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
  
  // Single Modal AJAX Loading
  $('#contactDetailsModal').on('show.bs.modal', function(event) {
    var button = $(event.relatedTarget); // Button that triggered the modal
    var contactId = button.data('contactid');
    var contactName = button.data('contactname');
    var contactNotes = button.data('notes');
    
    var modal = $(this);
    var modalBody = modal.find('.modal-body');
    var modalTitle = modal.find('.modal-title');
    
    // Update modal title
    modalTitle.text(contactName);
    
    // Reset modal content to loading state
    modalBody.html(
      '<div class="spinner-border text-primary" role="status" aria-hidden="true">' +
      '<span class="sr-only">Loading...</span></div>' +
      '<span class="ml-2">Loading contact details...</span>' +
      '<div id="notesSection" style="display: none;">' +
      '<hr class="my-4">' +
      '<h6 class="mb-3"><i class="mdi mdi-note-text mr-2"></i>Notes</h6>' +
      '<div id="notesContent"></div>' +
      '</div>'
    );
    
    // Load contact details via AJAX
    modalBody.load('share_contact_details.cfm?contactid=' + contactId, function(response, status) {
      if (status === "error") {
        modalBody.html('<div class="alert alert-danger">Error loading contact details. Please try again.</div>');
      } else {
        // Populate and show the notes section
        var notesHtml = '';
        if (contactNotes && contactNotes.trim() !== '') {
          notesHtml = '<div class="alert alert-light border"><p class="mb-0">' + contactNotes + '</p></div>';
        } else {
          notesHtml = '<div class="alert alert-light border text-muted"><p class="mb-0"><em>No notes available for this contact.</em></p></div>';
        }
        
        $('#notesContent').html(notesHtml);
        $('#notesSection').show();
      }
    });
  });
  
  // Reset modal content when hidden
  $('#contactDetailsModal').on('hidden.bs.modal', function() {
    var modalBody = $(this).find('.modal-body');
    var modalTitle = $(this).find('.modal-title');
    
    // Reset title
    modalTitle.text('Contact Details');
    
    // Reset content to loading state
    modalBody.html(
      '<div class="spinner-border text-primary" role="status" aria-hidden="true">' +
      '<span class="sr-only">Loading...</span></div>' +
      '<span class="ml-2">Loading contact details...</span>' +
      '<div id="notesSection" style="display: none;">' +
      '<hr class="my-4">' +
      '<h6 class="mb-3"><i class="mdi mdi-note-text mr-2"></i>Notes</h6>' +
      '<div id="notesContent"></div>' +
      '</div>'
    );
  });
});
</script>
