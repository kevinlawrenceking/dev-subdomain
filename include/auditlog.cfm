<!--- This ColdFusion page displays user activity in a table format with data fetched from a query. --->
<div class="row">
    <div class="col-12">
        <div class="card mb-3">
            <div class="card-body">
                <h4 class="header-title">User Activity</h4>
                <p class="text-muted font-13 mb-4"></p>
                <table id="basic-datatable" class="table dt-responsive nowrap w-100 table-striped" role="grid">
                    <thead>
                        <!--- Loop through the results to create table headers --->
                        <cfloop query="results" endrow="1">
                            <cfoutput>
                                <cfif (Results.CurrentRow MOD 2)>
                                    <Cfset rowtype="Odd" />
                                <cfelse>
                                    <Cfset rowtype="Even" />
                                </cfif>
                                <tr class="#rowtype#">
                                    <th>#head1#</th>
                                    <th>#head2#</th>
                                    <th>#head3#</th>
                                    <th>#head4#</th>
                                    <th>#head6#</th>
                                    <th>#head7#</th>
                                </tr>
                            </cfoutput>
                        </cfloop>
                    </thead>
                    <tbody>
                        <!--- Loop through the results to create table rows --->
                        <cfloop query="results">
                            <cfoutput>
                                <tr>
                                    <td>#results.col1#</td>
                                    <td>#this.formatDate(results.col2)#</td>
                                    <td>#TimeFormat("#results.col3#", "medium")#</td>
                                    <td>#results.col4#</td>
                                    <td>#results.col6#</td>
                                    <td>#results.col7#</td>
                                </tr>
                            </cfoutput>
                        </cfloop>
                    </tbody>
                </table>
            </div>
            <!--- end card body --->
        </div>
        <!--- end card --->
    </div>
    <!--- end col --->
</div>

<SCRIPT>
    $(document).ready(function() {
        
        $("#basic-datatable").DataTable({
            "iDisplayLength": 100,
            language: {
                paginate: {
                    previous: "<i class='mdi mdi-chevron-left'>",
                    next: "<i class='mdi mdi-chevron-right'>"
                }
            },
            drawCallback: function() {
                $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
            }
        });

        var a = $("#datatable-buttons").DataTable({
            lengthChange: !1,
            buttons: [{
                extend: "copy",
                className: "btn-light"
            }, {
                extend: "print",
                className: "btn-light"
            }, {
                extend: "pdf",
                className: "btn-light"
            }],
            language: {
                paginate: {
                    previous: "<i class='mdi mdi-chevron-left'>",
                    next: "<i class='mdi mdi-chevron-right'>"
                }
            },
            drawCallback: function() {
                $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
            }
        });
    });
</SCRIPT>

<!--- Default bootstrap modal example --->
