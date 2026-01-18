<!---
    PURPOSE: Display shared contact information in a datatable (OPTIMIZED)
    AUTHOR: Updated by GitHub Copilot
    DATE: 2025-07-21
    PARAMETERS: userid, shares query
    DEPENDENCIES: remote_load_common.cfm
    OPTIMIZATIONS: Single JOIN query, Bootstrap 4.6 compliant, secure parameterization
--->

 

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

 
<!--- OPTIMIZED QUERY: Single JOIN to get shares with event counts --->
<cfif structKeyExists(variables, 'new_userid') AND len(trim(new_userid))>
  <cfquery name="sharesWithEvents" datasource="#dsn#" cachedwithin="#CreateTimeSpan(0,0,15,0)#">
SELECT DISTINCT 
      s.contactid,
      s.Name,
      s.Company,
      s.Title,
      s.Audition,
      s.last_met,
      s.no_mtgs,
      s.lasteventtype,
      s.userid,
      s.userHash 
    FROM sharezz s
    WHERE s.userid = <cfqueryparam value="#new_userid#" cfsqltype="cf_sql_integer">
    ORDER BY s.Name
  </cfquery>
<cfelse>
  <!--- Fallback empty query if no valid userid --->
  <cfquery name="sharesWithEvents" datasource="#dsn#">
    SELECT 0 as contactid, '' as Name, '' as Company, '' as Title, 
           '' as audition, '' as last_met, 0 as no_Mtgs, 
           <cfqueryparam value="#CreateODBCDate(Now())#" cfsqltype="cf_sql_timestamp"> as lasteventtype, 
           0 as userid, '' as userHash
    WHERE 1=0
  </cfquery>
</cfif>

<!--- Bootstrap 4.6 compliant layout --->
<div class="container-fluid">
  <div class="row">
    <div class="col-12">
      <div class="card shadow-sm">
        <div class="card-body">
          
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
                          <a href="contact.cfm?shareID=#URLEncodedFormat(variables.shareID)#&contactID=#sharesWithEvents.contactid#" 
                             class="btn btn-sm btn-outline-primary view-contact-btn"
                             title="View Contact Details"
                             aria-label="View details for #HTMLEditFormat(sharesWithEvents.Name)#">
                            <i class="mdi mdi-eye"></i>
                          </a>
                        </td>

                        <!--- Name with Event Badge --->
                        <td style="white-space: nowrap;">
                          <span class="fw-medium">#HTMLEditFormat(sharesWithEvents.Name)#</span>
                       
                        </td>

                        <!--- Optional Events Column --->
                        <cfif structKeyExists(variables, 'auditions') AND auditions>
                          <td class="text-center">
                            <span class="badge badge-secondary">#sharesWithEvents.no_mtgs#</span>
                          </td>
                        </cfif>

                        <!--- Company --->
                        <td  style="white-space: nowrap;">
                          <cfif len(trim(sharesWithEvents.Company))>
                            #HTMLEditFormat(sharesWithEvents.Company)#
                          <cfelse>
                            <span class="text-muted">-</span>
                          </cfif>
                        </td>

                        <!--- Title --->
                        <td  style="white-space: nowrap;">
                          <cfif len(trim(sharesWithEvents.Title))>
                            #HTMLEditFormat(sharesWithEvents.Title)#
                          <cfelse>
                            <span class="text-muted">-</span>
                          </cfif>
                        </td>

                        <!--- Audition Status --->
                        <td>
                          <cfif len(trim(sharesWithEvents.Audition))>
                            <!--- Check if the field already contains HTML markup --->
                            <cfif findNoCase("<span", sharesWithEvents.Audition) OR findNoCase("<badge", sharesWithEvents.Audition)>
                              <!--- Output HTML directly without escaping --->
                              #sharesWithEvents.Audition#
                            <cfelse>
                              <!--- Create badge for plain text status --->
                              <cfset statusLower = lcase(trim(sharesWithEvents.Audition))>
                              <cfset statusClass = "status-badge">
                              <cfset statusIcon = "">
                              
                              <!--- Determine status-specific styling --->
                              <cfif statusLower eq "callback">
                                <cfset statusClass = statusClass & " status-callback">
                                <cfset statusIcon = "mdi mdi-phone-incoming">
                              <cfelseif statusLower eq "redirect">
                                <cfset statusClass = statusClass & " status-redirect">
                                <cfset statusIcon = "mdi mdi-swap-horizontal">
                              <cfelseif statusLower eq "audition">
                                <cfset statusClass = statusClass & " status-audition">
                                <cfset statusIcon = "mdi mdi-microphone">
                              <cfelseif statusLower eq "booking">
                                <cfset statusClass = statusClass & " status-booking">
                                <cfset statusIcon = "mdi mdi-thumb-up">
                              <cfelse>
                                <cfset statusClass = statusClass & " badge-info">
                                <cfset statusIcon = "mdi mdi-information">
                              </cfif>
                              
                              <span class="#statusClass#">
                                <cfif len(statusIcon)>
                                  <i class="#statusIcon#"></i>
                                </cfif>
                                #HTMLEditFormat(sharesWithEvents.Audition)#
                              </span>
                            </cfif>
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
                          <cfif sharesWithEvents.no_mtgs GT 0>
                            <span class="badge badge-secondary badge-pill ml-1" 
                                  title="#sharesWithEvents.no_mtgs# events">
                              #sharesWithEvents.no_mtgs#
                            </span>
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



<!--- Optimized DataTables Configuration --->
<style>
/* Layout polish */
.card {
  border: none;
  border-radius: 18px;
  box-shadow: 0 22px 48px rgba(39, 70, 98, 0.16);
  background: #ffffff;
}

.card-body {
  padding: 2.5rem 2.75rem 2rem;
}

.table thead th {
  text-transform: uppercase;
  font-size: 0.78rem;
  letter-spacing: 0.08em;
  color: #697b8f;
  border-bottom: 2px solid #e3ecf4;
  background: #f9fbfd;
}

.table tbody td {
  vertical-align: middle;
  color: #2f3c4a;
  border-color: #eef2f7;
}

.table tbody tr:hover {
  background: #f2f7fb;
}

.badge-secondary {
  background-color: #d0e4f6;
  color: #274562;
  font-weight: 600;
}

.view-contact-btn {
  border-radius: 999px;
  padding: 0.35rem 0.75rem;
  transition: all 0.2s ease-in-out;
  border-color: rgba(64, 110, 142, 0.4);
  color: #406E8E;
}

.view-contact-btn:hover {
  background-color: #406E8E !important;
  color: #fff;
  box-shadow: 0 8px 18px rgba(64, 110, 142, 0.25);
}

#contactsTable_filter input {
  border-radius: 999px;
  border: 1px solid #cdd9e4;
  padding: 0.45rem 1.1rem;
  box-shadow: none;
}

#contactsTable_filter input:focus {
  border-color: #406E8E;
  box-shadow: 0 0 0 0.2rem rgba(64, 110, 142, 0.25);
}

#contactsTable_length select {
  border-radius: 12px;
  border: 1px solid #cdd9e4;
  padding: 0.4rem 0.75rem;
}

.dataTables_paginate .pagination .page-item .page-link {
  border-radius: 10px;
  border: none;
  margin: 0 0.1rem;
  color: #406E8E;
}

.dataTables_paginate .pagination .page-item.active .page-link,
.dataTables_paginate .pagination .page-item .page-link:hover {
  background-color: #406E8E;
  color: #fff;
  box-shadow: 0 8px 16px rgba(64, 110, 142, 0.2);
}



/* Status Badge Styling */
.status-badge {
  padding: 0.375rem 0.85rem;
  border-radius: 999px;
  font-size: 0.82rem;
  font-weight: 600;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.status-callback {
  background-color: rgba(161, 217, 236, 0.35) !important;
  color: #246078 !important;
  border: 1px solid rgba(161, 217, 236, 0.55) !important;
}

.status-redirect {
  background-color: rgba(116, 192, 252, 0.35) !important;
  color: #134d7c !important;
  border: 1px solid rgba(116, 192, 252, 0.55) !important;
}

.status-audition {
  background-color: rgba(64, 110, 142, 0.2) !important;
  color: #2a4f6c !important;
  border: 1px solid rgba(64, 110, 142, 0.45) !important;
}

.status-booking {
  background-color: rgba(40, 167, 69, 0.18) !important;
  color: #1b5e34 !important;
  border: 1px solid rgba(40, 167, 69, 0.45) !important;
}

/* Generic brand color overrides */
.badge-primary {
  background-color: #406e8e !important;
  color: #fff !important;
  border: 1px solid #406e8e !important;
}

.text-primary {
  color: #406e8e !important;
}

.btn-outline-primary {
  color: #406e8e !important;
  border-color: rgba(64, 110, 142, 0.4);
}

.btn-outline-primary:hover {
  color: #fff;
  background-color: #406e8e !important;
  border-color: #406e8e !important;
}

</style>

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
      { targets: [2,3,4,5,6,7], width: "150px" }
    ];
  </cfif>
  
  // Initialize DataTable with optimized settings
  var table = $('#contactsTable').DataTable({
    responsive: true,
    searching: true,
    autoWidth: false,
    pageLength: 10,
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
  

});
</script>
