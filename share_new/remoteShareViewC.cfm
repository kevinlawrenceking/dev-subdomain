<cfset ShareService = createObject("component", "services.ShareService")>
<cfset details = ShareService.GetShareDetails(contactid=contactid)>

<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>
<cfset events = auditionProjectService.getProjectsByContact(contactid=contactid)>

<cfoutput query="details">

  <p>
    <cfif #Title# is not "">
      #Title#</cfif>
    <cfif #Company# is not "">
      <cfif #title# is not "">
        <BR>
        </cfif>
        #Company#</cfif>

    </p>
  </cfoutput>

  <cfif #events.recordcount# is not "0">
    <hr>
      <p>
        Audition History</p>

      <table id="contactview<cfoutput>#contactid#</cfoutput>" class="table dt-responsive nowrap w-100 table-striped" role="grid">
        <thead>
          <tr>

            <th>
              Date</th>
            <th>
              Project</th>
            <th>
              Audition Status</th>
          </tr>
        </thead>
        <cfloop query="events">
          <cfoutput>

            <tr>
              <td>
                #dateformat('#col1#','medium')#</td>
              <td>
                #col2#</td>
              <td>
                #col3#</td>
            </tr>
          </cfoutput>
        </cfloop>
      </table>
    </div>
  </div>
</div>

<SCRIPT>
  $(document).ready(function () {
    $("#<cfoutput>contactview#contactid#</cfoutput>").DataTable({
      "searching": true,

      language: {
        paginate: {
          previous: "<i class='mdi mdi-chevron-left'>",
          next: "<i class='mdi mdi-chevron-right'>"
        }
      },
      drawCallback: function () {
        $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
      }
    });
    var a = $("#datatable-buttons").DataTable({
      lengthChange: !1,
      language: {
        paginate: {
          previous: "<i class='mdi mdi-chevron-left'>",
          next: "<i class='mdi mdi-chevron-right'>"
        }
      },
      drawCallback: function () {
        $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
      }
    });
  });
</SCRIPT>
</cfif>
