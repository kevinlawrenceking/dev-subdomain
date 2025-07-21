<!--- 
    PURPOSE: Main entry point for share directory
    AUTHOR: Updated by GitHub Copilot
    DATE: 2025-07-19
    NOTES: Updated to use a more secure shareToken system
--->
<Cfset debug="no">
<cfparam name="url.shareToken" default="706C2C9EBECE60DA9F779903AC3FFE79" />
<cfparam name="url.u" default="" />  <!--- Keep legacy parameter for backward compatibility --->
<cfparam name="url.uid" default="" /> <!--- Original legacy parameter --->
<cfinclude template="remote_load_common.cfm" />
<!--- Debug Helper Function --->
<cffunction name="debugDump" returntype="void" output="true">
    <cfargument name="label" type="string" required="true">
    <cfargument name="value" required="true">
    <cfif debug is "YES">
        <cfdump var="#arguments.value#" label="#arguments.label#">
        <hr>
    </cfif>
</cffunction>
<!--- Ensure application variables are set --->
<cfif not structKeyExists(application, "dsn")>
    <cfif debug is "YES"><cfoutput><p style="background:##ffe6e6;padding:5px;border:1px solid red">Application DSN not found, initializing...</p></cfoutput></cfif>
    <cfset onApplicationStart() />
</cfif>

<!--- Debug URL parameters --->
<cfif debug is "YES">
    <div style="background:##f0f8ff;padding:10px;margin:10px 0;border:1px solid ##add8e6;">
        <h3>URL Parameters</h3>
        <cfoutput>
            <ul>
                <li><strong>shareToken:</strong> #url.shareToken#</li>
                <li><strong>u:</strong> #url.u#</li>
                <li><strong>uid:</strong> #url.uid#</li>
            </ul>
        </cfoutput>
        
        <h3>Application Settings</h3>
        <cfdump var="#application#" label="Application Scope" expand="false">
    </div>
</cfif>

<!--- Handle new shareToken system --->
<cfif len(trim(url.shareToken)) gt 0>
    <cfif debug is "YES">
        <div style="background:##e6ffe6;padding:10px;margin:10px 0;border:1px solid ##90ee90;">
            <h3>Using New Token System</h3>
            <p>Token: <cfoutput>#url.shareToken#</cfoutput></p>
        </div>
    </cfif>
   
   
</cfif>

<!--- Legacy system handling --->
<cfif len(trim(url.u)) gt 0 OR len(trim(url.uid)) gt 0>
    <cfset session.userid = 0 />
    <cfparam name="refresh_yn" default="N" />
    <cfparam name="NEW_USERID" default="0" />
    <cfset legacy_token = len(trim(url.u)) gt 0 ? url.u : url.uid />
    
    <cfif debug is "YES">
        <div style="background:##fff8e6;padding:10px;margin:10px 0;border:1px solid ##ffd700;">
            <h3>Using Legacy Token System</h3>
            <p>Legacy token: <cfoutput>#legacy_token#</cfoutput></p>
            <p>Token source: <cfoutput>#len(trim(url.u)) gt 0 ? "u parameter" : "uid parameter"#</cfoutput></p>
            <p>Token length: <cfoutput>#len(legacy_token)#</cfoutput></p>
        </div>
    </cfif>
    <!--- Get user ID from legacy token --->
    <cfif debug is "YES">
        <div style="background:##e6e6ff;padding:10px;margin:10px 0;border:1px solid ##9370db;">
            <h3>SQL Query Information</h3>
            <p>Looking up user with token prefix: <cfoutput>#left(legacy_token,10)#</cfoutput></p>
            <code style="display:block;background:##f8f8f8;padding:10px;white-space:pre-wrap;">
                SELECT 
                    left(t.UUID,10) as default_u,
                    u.userid 
                FROM 
                    taousers u inner join thrivecart t on t.id = u.customerid
                WHERE 
                    left(t.UUID,10) = '<cfoutput>#left(legacy_token,10)#</cfoutput>'
            </code>
        </div>
    </cfif>
    
    <cfquery name="default" datasource="#application.dsn#" maxrows="1">
        SELECT 
            left(t.UUID,10) as default_u,
            u.userid 
        FROM 
            taousers u inner join thrivecart t on t.id = u.customerid
        WHERE 
            left(t.UUID,10) = <cfqueryparam value="#left(legacy_token,10)#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfif debug is "YES">
        <div style="background:##e6e6ff;padding:10px;margin:10px 0;border:1px solid ##9370db;">
            <h3>Query Result</h3>
            <p>Records found: <cfoutput>#default.recordCount#</cfoutput></p>
            <cfdump var="#default#" label="Default Query Result">
        </div>
    </cfif>

    <cfif default.recordCount eq 0>
        <cfif debug is "YES">
            <div style="background:##ffe6e6;padding:10px;margin:10px 0;border:1px solid ##ff0000;">
                <h3>Authentication Failed</h3>
                <p>No user found with the provided token: <cfoutput>#legacy_token#</cfoutput></p>
                <p>Redirecting to invalid token page...</p>
            </div>
        </cfif>
        <cfinclude template="invalid_token.cfm" />
        <cfabort>
    </cfif>
    
    <cfset u = default.default_u />
    <cfset new_userid = default.userid />
    
    <cfif debug is "YES">
        <div style="background:##e6ffe6;padding:10px;margin:10px 0;border:1px solid ##90ee90;">
            <h3>Authentication Successful</h3>
            <p>User ID: <cfoutput>#new_userid#</cfoutput></p>
            <p>Token (u): <cfoutput>#u#</cfoutput></p>
        </div>
    </cfif>
    
    <!--- Include legacy page --->
    <cfif debug is "YES">
        <div style="background:##f0f8ff;padding:10px;margin:10px 0;border:1px solid ##add8e6;">
            <h3>Including Legacy Page</h3>
            <p>Template: pgload.cfm</p>
            <p>User ID: <cfoutput>#new_userid#</cfoutput></p>
        </div>
    </cfif>
 
<cfelse>
    <cfif debug is "YES">
        <div style="background:##ffe6e6;padding:10px;margin:10px 0;border:1px solid ##ff0000;">
            <h3>No Token Provided</h3>
            <p>Redirecting to main site...</p>
        </div>
    </cfif>
    <!--- No token provided - redirect to main site --->
    <cflocation url="https://theactorsoffice.com" addtoken="false" />
</cfif>

<cfif debug is "YES">
    <div style="background:##e6e6ff;padding:10px;margin:10px 0;border:1px solid ##9370db;">
        <h3>Shares Query</h3>
        <code style="display:block;background:##f8f8f8;padding:10px;white-space:pre-wrap;">
            SELECT `contactid`,`Name`,`Company`,`Title`,`Audition`,`WhereMet`,`WhenMet`,`NotesLog`,`userid`,`u`
            FROM sharez where userid = <cfoutput>#new_userid#</cfoutput>
        </code>
    </div>
</cfif>

<cfquery name="shares" datasource="#application.dsn#" maxrows="1">
SELECT `contactid`,`Name`,`Company`,`Title`,`Audition`,`WhereMet`,`WhenMet`,`NotesLog`,`userid`,`u`
FROM sharez where userid = #new_userid#
</cfquery>

<cfif debug is "YES">
    <div style="background:##e6e6ff;padding:10px;margin:10px 0;border:1px solid ##9370db;">
        <h3>Shares Query Result</h3>
        <p>Records found: <cfoutput>#shares.recordCount#</cfoutput></p>
        <cfdump var="#shares#" label="Shares Query Result">
    </div>
</cfif>








<cfparam name="TAOVERSION" default="0" />
<!DOCTYPE html>
<html lang="en">

<head>
    <cfoutput>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <title>#appName# #shares.recordcount#| #pgTitle#</title>

    </cfoutput>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Source+Sans+Pro:wght@300&display=swap');
    </style>
    <!--- Include styles and scripts from FindLinksT query --->
    <cfif isDefined("FindLinksT") AND isQuery(FindLinksT)>
        <cfloop query="FindLinksT">
            <cfoutput>
                <cfif FindLinksT.linktype is "script">
                    <script src="#FindLinksT.linkurl#"></script>
                </cfif>

                <cfif FindLinksT.linktype is "script_include">
                    <script>
                        <cfinclude template = "#FindLinksT.linkurl#?rev=#RandRange(1, 1000000)#" >
                    </script>
                </cfif>
                <cfif FindLinksT.linktype is "css" or FindLinksT.linktype is "text/css" or FindLinksT.linktype is "ico">
                    <link href="#FindLinksT.linkurl#?rev=#RandRange(1, 1000000)#" 
                    <cfif len(trim(FindLinksT.rel))>rel="#FindLinksT.rel#"</cfif>
                    type="text/css" 
                    <cfif len(trim(FindLinksT.hrefid))>id="#FindLinksT.hrefid#"</cfif> />
                </cfif>
            </cfoutput>
        </cfloop>
    <cfelse>
        <!--- Fallback if FindLinksT query is not defined --->
        <link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/js/bootstrap.bundle.min.js"></script>
    </cfif>
    
    <style>
  .spinner {
    display: inline-block;
    width: 80px;
    height: 80px;
    border: 8px solid #f3f3f3;
    border-radius: 50%;
    border-top: 8px solid #3498db;
    animation: spin 2s linear infinite;
  }

  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }

  .loading {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 100%;
    height: 100vh;
    position: absolute;
    top: 0;
    left: 0;
    background: rgba(255, 255, 255, 0.8);
    z-index: 9999;
  }
</style>

</head>

<body class="loading">
    

    
    
    <div id="wrapper">
        <cfif #host# is "dev">
            <div class="navbar-custom" style="background-color: #8b0000 !important;">
                <cfelse>
                    <div class="navbar-custom" style="background-color: <cfoutput>#colorTopBar#</cfoutput> !important;">
        </cfif>
        <div class="container-fluid">
            <cfinclude template="topmenu_main.cfm" />
             <div class="logo-box">
            <a href="/app/" class="logo logo-dark text-center">
                <span class="logo-sm">
                    <img src="/assets/images/logo-sm.png" alt="" height="30">
                    <!--- <span class="logo-lg-text-light">UBold</span> --->
                </span>
                <span class="logo-lg">
                    <img src="/assets/images/logo-sm.png" alt="" height="30">
                    <!--- <span class="logo-lg-text-light">U</span> --->
                </span>
            </a>
    
            <a href="/app/" class="logo logo-light text-center">
                <span class="logo-sm">
                    <img src="/assets/images/logo-sm.png" alt="" height="30">
                </span>
                <span class="logo-lg">
                    <img src="/assets/images/logo-light.png" alt="" height="30">
                </span>
            </a>
        </div>
    
        </div>
        <div class="content-pag">
            <div class="content" STYLE="margin-top:35px;">
                <div class="container-fluid">
     
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

                </div>
            </div>
            <cfparam name="pgdir" default="">
                <cfparam name="pgid" default="0" />
        </div>
    </div>
    <cfif isDefined("FindLinksB") AND isQuery(FindLinksB)>
        <cfloop query="FindLinksB">
            <cfoutput>
                <cfif FindLinksB.linktype is "script">
                    <script src="#FindLinksB.linkurl#?ver=#RandRange(1, 1000000)#"></script>
                </cfif>
                <cfif FindLinksB.linktype is "script_include">
                    <script>
                        <cfinclude template = "#FindLinksB.linkurl#?rev=#RandRange(1, 1000000)#" >
                    </script>
                </cfif>
                <cfif FindLinksB.linktype is "css" or FindLinksB.linktype is "text/css" or FindLinksB.linktype is "ico">
                    <link href="#FindLinksB.linkurl#?rev=#RandRange(1, 1000000)#" 
                          <cfif len(trim(FindLinksB.rel))>rel="#FindLinksB.rel#"</cfif>
                          type="text/css"
                                                    <cfif len(trim(FindLinksB.hrefid))>id="#FindLinksB.hrefid#"</cfif> />
                </cfif>
            </cfoutput>
        </cfloop>
    </cfif>
    
    <!--- Process shares modal views --->
    <cfif isDefined("shares") AND isQuery(shares)>
        <!--- Modal handlers for each contact --->
        <cfoutput>
        <script>
        $(document).ready(function() {
            // Remove loading spinner
            $('body').removeClass('loading');
            
            <cfloop query="shares">
                $("##remoteShareViewC#shares.contactid#").on("show.bs.modal", function(event) {
                    $(this).find(".modal-body").load("remoteShareViewC.cfm?contactid=#shares.contactid#");
                });
            </cfloop>
        });  
        </script>
        </cfoutput>
        
        <!--- Modal HTML structures --->
        <cfoutput>
        <cfloop query="shares">
            <div id="remoteShareViewC#shares.contactid#" class="modal modal-lg fade" tabindex="-1" role="dialog" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h4 class="modal-title">#shares.name#</h4>
                            <button type="button" class="close" data-bs-dismiss="modal" aria-hidden="true"><i class="mdi mdi-close-thick"></i></button>
                        </div>
                        <div class="modal-body">
                            <!--- Content will be loaded via AJAX --->
                        </div>
                    </div>
                </div>
            </div>
        </cfloop>
        </cfoutput>
    <cfelse>
        <!--- If no shares, still remove loading spinner --->
        <script>
        $(document).ready(function() {
            $('body').removeClass('loading');
        });
        </script>
    </cfif>

    <cfif debug is "YES">
        <div style="background:##f0f8ff;padding:20px;margin:20px 0;border:1px solid ##add8e6;">
            <h2>Debug Information Summary</h2>
            
            <h3>URL Parameters</h3>
            <cfdump var="#url#" label="URL Scope">
            
            <h3>Form Parameters</h3>
            <cfdump var="#form#" label="Form Scope">
            
            <h3>Cookie Values</h3>
            <cfdump var="#cookie#" label="Cookie Scope">
            
            <h3>Session Values</h3>
            <cfdump var="#session#" label="Session Scope" expand="false">
            
            <h3>CGI Variables</h3>
            <cfdump var="#cgi#" label="CGI Scope" expand="false">
            
            <h3>Server Information</h3>
            <cfdump var="#server#" label="Server Scope" expand="false">
            
            <h3>Application Settings</h3>
            <cfdump var="#application#" label="Application Scope" expand="false">
            
            <hr>
            <p>Debug mode is enabled. Set debug="NO" at the top of the page to disable.</p>
        </div>
    </cfif>


</body>

</html>