<!--- Cleaned up ColdFusion page - PART 1 & 2 with nesting fix --->
<cfparam name="select_userid" default="%" />
<cfparam name="select_ticketstatus" default="%" />
<cfparam name="select_tickettype" default="%" />
<cfparam name="select_ticketpriority" default="%" />
<cfparam name="select_pgid" default="%" />
<cfparam name="select_verid" default="%" />

<cfparam name="select_userid" default="%">
<cfparam name="select_ticketstatus" default="%">
<cfparam name="select_ticketpriority" default="%">
<cfparam name="select_tickettype" default="%">
<cfparam name="select_pgid" default="%">
<cfparam name="select_verid" default="%">


<cfquery name="results" >
  SELECT 
    'ID' AS head1, 
    'Details' AS head2, 
    'Page' AS head3, 
    'Type' AS head4, 
    'Status' AS head45, 
    'Priority' AS head5, 
    'Hours' AS head6, 
    'Release' AS head7, 
    t.ticketID AS col1, 
    t.ticketID AS recid, 
    t.ticketName AS col2, 
    p.pgname AS col3, 
    t.tickettype AS col4, 
    t.ticketstatus AS col45, 
    t.ticketpriority AS col5, 
    t.esthours AS col6, 
    CONCAT(v.major, '.', v.minor, '.', v.patch, '.', v.version, '.', v.build) AS col7,
    t.verid,
    p.pgname,
    p.pgdir
  FROM tickets t
  LEFT JOIN taousers_tbl u ON u.userid = t.userid
  LEFT JOIN pgpages p ON p.pgid = t.pgid
  LEFT JOIN taoversions v ON v.verid = t.verid
  WHERE t.ticketActive = 'Y'

  <!--- Dynamic filters using <cfqueryparam> for safety --->
  <cfif isNumeric(select_userid) AND select_userid GT 0>
    AND t.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#select_userid#">
  </cfif>

  <cfif len(trim(select_ticketstatus)) AND select_ticketstatus NEQ "%">
    AND t.ticketstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_ticketstatus#">
  </cfif>

  <cfif len(trim(select_ticketpriority)) AND select_ticketpriority NEQ "%">
    AND t.ticketpriority = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_ticketpriority#">
  </cfif>

  <cfif len(trim(select_tickettype)) AND select_tickettype NEQ "%">
    AND t.tickettype = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_tickettype#">
  </cfif>

  <cfif isNumeric(select_pgid) AND select_pgid GT 0>
    AND p.pgid = <cfqueryparam cfsqltype="cf_sql_integer" value="#select_pgid#">
  </cfif>

  <cfif isNumeric(select_verid) AND select_verid GT 0>
    AND t.verid = <cfqueryparam cfsqltype="cf_sql_integer" value="#select_verid#">
  </cfif>

  ORDER BY t.ticketCreatedDate DESC
</cfquery>



<div class="row">
  <div class="col-12">
    <div class="card">
      <div class="card-body">
        <h4 class="header-title">Support Tickets</h4>
        <form action="/app/admin-support/">
          <div class="row">
            <!-- BEGIN FILTER CONTROLS -->
<!-- User Filter -->
<div class="form-group col-md-4">
  <label for="select_userid">User</label>
  <select class="form-control" name="select_userid" id="select_userid" onchange="this.form.submit()">
    <option value="%" <cfif select_userid EQ "%">selected</cfif>>All Users</option>
    <cfoutput query="users">
      <option value="#userid#" <cfif userid EQ select_userid>selected</cfif>>#recordname# <cfif userrole NEQ "user">(#userrole#)</cfif></option>
    </cfoutput>
  </select>
</div>
<!-- Status Filter -->
<div class="form-group col-md-4">
  <label for="select_ticketstatus">Status</label>
  <select class="form-control" name="select_ticketstatus" id="select_ticketstatus" onchange="this.form.submit()">
    <option value="%" <cfif select_ticketstatus EQ "%">selected</cfif>>All</option>
    <cfoutput query="statuses">
      <option value="#ticketstatus#" <cfif ticketstatus EQ select_ticketstatus>selected</cfif>>#ticketstatus#</option>
    </cfoutput>
  </select>
</div>
<!-- Type Filter -->
<div class="form-group col-md-4">
  <label for="select_tickettype">Type</label>
  <select class="form-control" name="select_tickettype" id="select_tickettype" onchange="this.form.submit()">
    <option value="%" <cfif select_tickettype EQ "%">selected</cfif>>All Types</option>
    <cfoutput query="types">
      <option value="#tickettype#" <cfif tickettype EQ select_tickettype>selected</cfif>>#tickettype#</option>
    </cfoutput>
  </select>
</div>
<!-- Page Filter -->
<div class="form-group col-md-4">
  <label for="select_pgid">Pages</label>
  <select class="form-control" name="select_pgid" id="select_pgid" onchange="this.form.submit()">
    <option value="%" <cfif select_pgid EQ "%">selected</cfif>>All Pages</option>
    <cfoutput query="pages">
      <option value="#pgid#" <cfif pgid EQ select_pgid>selected</cfif>>#pgname#</option>
    </cfoutput>
  </select>
</div>
<!-- Priority Filter -->
<div class="form-group col-md-4">
  <label for="select_ticketpriority">Priority</label>
  <select class="form-control" name="select_ticketpriority" id="select_ticketpriority" onchange="this.form.submit()">
    <option value="%" <cfif select_ticketpriority EQ "%">selected</cfif>>All Priorities</option>
    <cfoutput query="priorities">
      <option value="#name#" <cfif name EQ select_ticketpriority>selected</cfif>>#name#</option>
    </cfoutput>
  </select>
</div>
<!-- Version Filter -->
<div class="form-group col-md-4">
  <label for="select_verid">Release (hours left)</label>
  <select class="form-control" name="select_verid" id="select_verid" onchange="this.form.submit()">
    <option value="%" <cfif select_verid EQ "%">selected</cfif>>All Releases</option>
    <option value="0" <cfif select_verid EQ "0">selected</cfif>>None</option>
    <cfoutput query="vers">
      <option value="#id#" <cfif id EQ select_verid>selected</cfif>>#name# (#numberformat(hoursleft, '9.99')# hrs)</option>
    </cfoutput>
  </select>
</div>
<!-- END FILTER CONTROLS -->
          </div>
        </form>

        <!-- Table Output -->
        <table id="basic-datatable" class="table table-striped table-bordered dt-responsive nowrap w-100">
          <thead>
            <tr>
              <th>Action</th>
              <th>ID</th>
              <th>Details</th>
         
              <th>Type</th>
              <th>Status</th>
              <th>Priority</th>
              <th>Hours</th>
              <th>Release</th>
              <th>Testing</th>
            </tr>
          </thead>
          <tbody>
            <cfoutput query="results">
              <tr>
                <td>
                  <a href="/app/admin-support-details/?recid=#recid#" title="Edit Ticket"><i class="mdi mdi-square-edit-outline"></i></a>
                  &nbsp;
                  <a href="/include/deleteticket.cfm?recid=#recid#" title="Delete Ticket"><i class="mdi mdi-trash-can-outline"></i></a>
                </td>
                <td>#recid#</td>
                <td>#left(col2,50)#</td>
              
                <td>#col4#</td>
                <td>#col45#</td>
                <td>#col5#</td>
                <td>#col6#</td>
                <td>#col7#</td>
                <td>
                  <cfquery name="ticketusers" >
                    SELECT tu.id, tu.ticketid, tu.userid, u.recordname, tu.teststatus, tu.rejectnotes
                    FROM tickettestusers tu
                    INNER JOIN taousers u ON u.userid = tu.userid
                    WHERE tu.ticketid = #recid#
                  </cfquery>
                  <cfloop query="ticketusers">
                    <cfif teststatus EQ "Approved">
                      <i class="mdi mdi-thumb-up" style="color:darkseagreen;" title="#recordname#"></i>
                    <cfelse>
                      <i class="mdi mdi-thumb-down" style="color:darkred;" title="#recordname# #rejectnotes#"></i>
                    </cfif>
                  </cfloop>
                </td>
              </tr>
            </cfoutput>
          </tbody>
        </table>

        <!-- DataTables Script -->
<script>
  $(document).ready(function () {
    $('#basic-datatable').DataTable({
      responsive: false, <!--- disables the green plus icon --->
      pageLength: 100,
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

      </div>
    </div>
  </div>
</div>
