<!---
    PURPOSE: Display shared contact information in a datatable
    AUTHOR: Updated by GitHub Copilot
    DATE: 2025-07-20
    PARAMETERS: userid, shares query
    DEPENDENCIES: remote_load_common.cfm
--->

<!--- Include common variables and settings --->
<cfinclude template="remote_load_common.cfm">

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

<!--- Ensure shares query exists --->
<cfif NOT isDefined('shares')>
  <cfquery name="shares" datasource="#dsn#">
    SELECT 0 as contactid, '' as name, '' as Company, '' as Title, 
           '' as audition, '' as Wheremet, #CreateODBCDate(Now())# as whenmet, 
           '' as NotesLog
    WHERE 1=0
  </cfquery>
</cfif>

<!--- Page Content --->
<div class="container-fluid">
  <div class="row">
    <div class="col-12">
      <div class="card">
        <div class="card-body">
          <!--- Header --->
          <div class="row mb-3">
            <div class="col-md-12">
              <div class="media p-2">
                <cfoutput>
                  <figure class="text-center">
                    <img src="/media-#dsn#/users/#userid#/avatar.jpg?ver=#RandRange(1, 1000000)#" class="mr-3 rounded-circle gambar img-responsive img-thumbnail" style="height:80px;" alt="profile-image" id="item-img-output">
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
          </div>

          <!--- Table Container --->
          <div class="row">
            <div class="col-12">
              <div class="table-responsive">
                <table id="basic-datatable" class="table table-striped table-bordered" style="width:100%">
        <thead>
          <tr>
            <th></th>
            <th>Name</th>
            <cfif isDefined("auditions")>
              <th>Auditions</th>
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
          <!--- Pre-fetch all events for performance optimization --->
          <cfquery name="allEvents" datasource="#dsn#">
            SELECT contactid, COUNT(eventid) AS eventCount
            FROM events
            WHERE contactid IN (
                SELECT contactid FROM shares
            )
            AND EventTypeName IN ('Meeting', 'Audition')
            AND isDeleted = 0
            GROUP BY contactid
          </cfquery>
          
          <cfoutput query="shares">
            <!--- Get event count for this contact --->
            <cfset eventCount = 0>
            <cfquery name="getEventCount" dbtype="query">
              SELECT eventCount 
              FROM allEvents
              WHERE contactid = #shares.contactid#
            </cfquery>
            <cfif getEventCount.recordCount GT 0>
              <cfset eventCount = getEventCount.eventCount>
            </cfif>
            
            <tr>
              <!--- View Icon --->
              <td style="white-space: nowrap;">
                <a href="javascript:;" data-bs-toggle="modal" data-bs-target="##remoteShareViewC#shares.contactid#"
                   title="View Contact Info and Audition List">
                  <i class="fe-search"></i>
                </a>
              </td>

              <!--- Name + Badge --->
              <td style="white-space: nowrap;">
                #shares.name#
                <cfif eventCount GT 0>
                  <span class="badge badge-primary badge-pill">#eventCount#</span>
                </cfif>
              </td>

              <!--- Optional audition count --->
              <cfif isDefined("auditions")>
                <td style="white-space: nowrap;">#eventCount#</td>
              </cfif>

              <!--- Other Fields --->
              <td style="white-space: nowrap;">#shares.Company#</td>
              <td style="white-space: nowrap;">#shares.Title#</td>
              <td style="white-space: nowrap;">#shares.audition#</td>
              <td style="white-space: nowrap;">#shares.Wheremet#</td>
              <td style="white-space: nowrap;">
                <cfif isDate(shares.whenmet)>
                  #dateFormat(shares.whenmet, 'medium')#
                <cfelse>
                  &nbsp;
                </cfif>
              </td>

              <!--- Notes (wrapped) --->
              <cfset NotesLog2 = "">
              <cfif len(trim(shares.NotesLog))>
                <cfset NotesLog2 = replace(shares.NotesLog, "..", ".", "all")>
              </cfif>
              <td style="max-width: 400px; white-space: normal !important; word-break: break-word !important; overflow-wrap: break-word !important;">#NotesLog2#</td>
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

<!--- DataTables Script --->
<script>
  $(document).ready(function () {
    <cfif isDefined("auditions")>
      // Configuration with auditions column
      var columnDefs = [
        { targets: 0, width: "40px", orderable: false }, // View icon column
        { targets: 1, width: "150px" }, // Name column  
        { targets: 2, width: "80px", className: "text-nowrap" }, // Auditions column
        { targets: [3,4,5,6,7], width: "100px", className: "text-nowrap" }, // Other standard columns
        { targets: -1, width: "300px", className: "text-wrap" } // Notes column (last column)
      ];
    <cfelse>
      // Configuration without auditions column
      var columnDefs = [
        { targets: 0, width: "40px", orderable: false }, // View icon column
        { targets: 1, width: "150px" }, // Name column
        { targets: [2,3,4,5,6], width: "100px", className: "text-nowrap" }, // Other standard columns
        { targets: -1, width: "300px", className: "text-wrap" } // Notes column (last column)
      ];
    </cfif>
    
    $("#basic-datatable").DataTable({
      responsive: true,
      searching: true,
      autoWidth: false,
      scrollX: true,
      pageLength: 25,
      dom: 'Bfrtip',
      buttons: [
        'copy', 'csv', 'excel', 'pdf', 'print'
      ],
      columnDefs: columnDefs,
      language: {
        paginate: {
          previous: "<i class='mdi mdi-chevron-left'>",
          next: "<i class='mdi mdi-chevron-right'>"
        },
        search: "Filter Records:",
        emptyTable: "No contacts available"
      },
      drawCallback: function () {
        $(".dataTables_paginate > .pagination").addClass("pagination-rounded");
      }
    });
  });
</script>

<!--- Load modal views for contacts --->
<cfoutput>
  <div id="modal-container">
    <cfif shares.recordcount GT 0>
      <cfloop query="shares">
        <div class="modal fade" id="remoteShareViewC#shares.contactid#" tabindex="-1" role="dialog" aria-labelledby="shareModalLabel#shares.contactid#" aria-hidden="true">
          <div class="modal-dialog modal-lg">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title" id="shareModalLabel#shares.contactid#">Contact Details: #shares.name#</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-hidden="true"></button>
              </div>
              <div class="modal-body">
                <cfinclude template="share_contact_details.cfm">
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
              </div>
            </div>
          </div>
        </div>
      </cfloop>
    </cfif>
  </div>
</cfoutput>
