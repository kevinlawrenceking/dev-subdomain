<!--- This ColdFusion page displays version details and support tickets, including modals for updates and approvals. --->

<cfparam name="pgaction" default="view" />

<!--- Check if 'recid' is not defined and set it to 'verid' if true --->
<cfif not isdefined('recid')>
    <cfset recid = verid />
</cfif>

<!--- Include query for version details --->
<cfinclude template="/include/qry/vers_323_1.cfm" />

<!--- Loop through the results query to display modals for each record --->
<cfloop query="results">
    <cfoutput>
        <div id="approve#results.recid#" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" >

            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header" >
                        <h4 class="modal-title" id="standard-modalLabel">Testing No. 0000#results.recid# - #results.col4# </h4>
                        <button type="button" class="close" data-bs-dismiss="modal" >
x</button>
                    </div>
                    <div class="modal-body">
                    </div>
                </div>
                <!--- /.modal-content --->
            </div>
            <!--- /.modal-dialog --->
        </div>
    </cfoutput>    
</cfloop>

<!--- Output modal for remote ticket update --->
<cfoutput>
    <div id="remoteticketupdate" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header" >
                    <h4 class="modal-title" id="standard-modalLabel">Version Release</h4>
                    <button type="button" class="close" data-bs-dismiss="modal" >
</button>
                </div>
                <div class="modal-body">
                </div>
            </div>
        </div>
    </div>
</cfoutput>

<!--- Output modal for patch notes --->
<cfoutput>
    <div id="vermodal" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header" >
                    <h4 class="modal-title" id="standard-modalLabel">Patch Notes</h4>
                    <button type="button" class="close" data-bs-dismiss="modal" >
</button>
                </div>
                <div class="modal-body">
                </div>
            </div>
        </div>
    </div>
</cfoutput>

<script src="/app/assets/js/jquery.bootstrap-touchspin.js"></script>   
<cfset pgcol = 3 />

<!--- Check if the page action is "view" --->
<cfif #pgaction# is "view">
    <div class="row">
        <div class="col-12">
            <div class="card mb-3">
                <div class="card-body">
                    <h4 class="header-title">
                        <cfoutput> #details.vername# - #details.versiontype#</cfoutput>
                   
                    </h4>
                    
                    <div class="d-flex justify-content-between">
                        <div class="float-left">
                            <A HREF="/app/versions/" style="background-color: #406e8e; border: #406e8e;margin-bottom: 10px;" class="btn btn-xs btn-primary waves-effect mb-2 waves-light">
                                Back 
                            </A>
                        </div>
                        <div class="dropdown float-end">
                            <A HREF="<cfoutput>/app/version-update/?recid=#recid#</cfoutput>" style="background-color: #406e8e; border: #406e8e;margin-bottom: 10px;" class="btn btn-xs btn-primary waves-effect mb-2 waves-light">
                                Update 
                            </A>
                        </div>
                    </div>
                    
                    <div class="row">
                        <cfset n = 0 />
                        
                        <cfoutput query="details">
                            <script>
                                $(document).ready(function(){
                                    $("##vermodal").on("show.bs.modal", function(event){
                                        
                                        $(this).find(".modal-body").load("/include/patchnotes.cfm?recid=#details.verid#&oldverid=#details.verid#");
                                    });
                                });
                            </script>
                            
                            <h5 class="col-md-12">Release Information 
                                <a title="Edit" href="/include/patchnotes.cfm" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##vermodal">
                                    <i class="mdi mdi-square-edit-outline"></i>
                                </a>
                            </h5>
                            
                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Name</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">
                                            #details.vername#
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Status</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">
                                            #details.versionstatus#
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Hours Left</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">
                                            #numberformat(details.hoursleft,'999.99')# hours
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Total Tickets</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">
                                            #details.total_tickets# tickets
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Review Date</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">
                                            
                                                #this.formatDate(details.reviewDate)#
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Review Start Time</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">
                                            #timeformat(details.reviewtime)#
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Release Date</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">
                                            #this.formatDate(details.releasedate)#
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Release Time</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">
                                            #timeformat(details.releasetime)#
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-12">
                                <p>&nbsp;</p>
                            </div>
                        </cfoutput>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!--- Support Tickets Section --->
    <div class="row">
        <div class="col-12">
            <div class="card mb-3">
                <div class="card-body">
                    <h4 class="header-title">Support Tickets</h4>
                    <p class="text-muted font-13 mb-4"></p>
                    
                    <table id="basic-datatable" class="table dt-responsive nowrap w-100 table-striped" role="grid">
                        <thead>
                            <cfloop query="results" endrow="1">
                                <cfoutput>
                                    <cfif (Results.CurrentRow MOD 2) >
                                        <Cfset rowtype="Odd" />
                                    <cfelse>
                                        <Cfset rowtype="Even" />
                                    </cfif>

                                    <tr class="#rowtype#">
                                        
                                        <th>#head1#</th>
                                        <th>#head2#</th>
                                    
                                        <th>#head45#</th>
                                        <th>#head5#</th>
                                        <th>#head6#</th> 
                                        <th>#head7#</th>
                                        <th>Testing</th>
                                    </tr>
                                </cfoutput>
                            </cfloop>
                        </thead>
                        <tbody>
                            <cfloop query="results">
                                <!--- Include query for ticket details --->
                                <cfinclude template="/include/qry/versions_323_2.cfm" />
                                
                                <cfoutput>
                                    <div id="approve#results.recid#" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" >

                                        <div class="modal-dialog">
                                            <div class="modal-content">
                                                <div class="modal-header" >
                                                    <h4 class="modal-title" id="standard-modalLabel">Testing No. 0000#results.recid# - #results.col4# </h4>
                                                    <button type="button" class="close" data-bs-dismiss="modal" >
x</button>
                                                </div>
                                                <div class="modal-body">
                                                </div>
                                            </div>
                                            <!--- /.modal-content --->
                                        </div>
                                        <!--- /.modal-dialog --->
                                    </div>
                                    
                                    <script>
                                        $(document).ready(function(){
                                            $("##myModal#results.recid#").on("show.bs.modal", function(event){
                                                
                                                $(this).find(".modal-body").load("/include/remoteverticketupdate.cfm?recid=#results.recid#&oldverid=#details.verid#");
                                            });
                                        });
                                    </script>
                                    
                                    <script>
                                        $(document).ready(function(){
                                            $("##approve#results.recid#").on("show.bs.modal", function(event){
                                                
                                                $(this).find(".modal-body").load("/include/remoteapprove.cfm?recid=#results.recid#&oldverid=#details.verid#");
                                            });
                                        });
                                    </script>
                                    
                                    <tr>

<TD>
                                            <A href="/app/admin-support-details/?recid=#results.recid#&oldverid=#details.verid#" title="#results.col4# - #results.col5#">#results.recid#</A>
                                        </TD>
                                        
                                        <td>#results.col2#</td>

<td>#results.col45#</td>
                                        <form class="px-3 col-md-12" id="updatever#results.recid#" method="post" action="/include/updatetickver2.cfm">
                                            <td>
                                                <input type="hidden" name="ticketid" value="#results.recid#" />
                                                <input type="hidden" name="oldverid" value="#details.verid#" />
                                                <input type="hidden" name="old_verid" value="#details.verid#" />     
                                                <input type="hidden" name="old_ticketpriority" value="#results.col5#" />     
                                                <cfif #results.col45# is not "closed" and #results.col45# is not "Released">
                                                    <cfoutput>
                                                        <select onchange="javascript:this.form.submit()" name="new_ticketpriority" id="new_ticketpriority_#results.recid#" required>
                                                    </cfoutput>
                                                    <cfloop query="priorities">
                                                        <Cfoutput>
                                                            <option value="#priorities.id#" <cfif #priorities.id# is "#results.col5#"> selected </cfif>>#priorities.name#</option>
                                                        </Cfoutput>
                                                    </cfloop>
                                                    </select>                    
                                                <cfelse>
                                                    <Cfoutput>#results.col5# <input type="hidden" name="new_ticketpriority" value="#results.col5#" /></Cfoutput> 
                                                </cfif>
                                            </td> 
                                            <cfoutput>
                                                <td>#results.col6#</td> 
                                            </cfoutput>
                                            <td>
                                                <cfif #results.col45# is not "closed" and #results.col45# is not "Released">
                                                    <cfoutput>
                                                        <select onchange="javascript:this.form.submit()" name="new_verid" id="new_verid_#results.recid#" required>
                                                            <option value="0" <cfif #results.verid# is "0"> Selected </cfif>>None</option>
                                                    </cfoutput>
                                                    <cfloop query="versions">
                                                        <Cfoutput>
                                                            <option value="#versions.id#" <cfif #versions.id# is "#results.verid#"> Selected </Cfif>>#versions.name# (#numberformat(versions.hoursleft,'9.99')# hrs)</option>
                                                        </Cfoutput>
                                                    </cfloop>
                                                    </select> 
                                                <cfelse>
                                                    <cfoutput>#results.col7# <input type="hidden" name="new_verid" value="#results.verid#" /></cfoutput>
                                                </cfif>
                                            </td>
                                        </form>
                                        
                                        <td>
                                            <cfinclude template="/include/qry/ticketusers_323_3.cfm" /> 
                                            <cfinclude template="/include/qry/ticketme_323_4.cfm" />        
                                            
                                            <cfif #ticketme.recordcount# is "1">
                                                <cfoutput>
                                                    <cfif #ticketme.teststatus# is "Approved">
                                                        <a href="" title="#ticketme.recordname#"> <i class="mdi mdi-thumb-up" style="color:green;"></i></a>
                                                    <cfelse>
                                                        <a href="##" title="#ticketme.recordname#<cfif #ticketme.rejectnotes# is not "">#ticketme.rejectnotes#</cfif>"> <i class="mdi mdi-thumb-down" style="color: red;"></i></a>
                                                    </cfif>
                                                </cfoutput>
                                            </cfif>
                                            
                                            <cfif #ticketme.recordcount# is "0">
                                                <a href="" title="Me"> <i class="mdi mdi-thumb-up" style="color:lightgrey;"></i></a>
                                            </cfif>
                                            
                                            <Cfloop query="ticketusers">
                                                <cfoutput>
                                                    <cfif #ticketusers.teststatus# is "Approved">
                                                        <a href="##" title="#ticketusers.recordname#"> <i class="mdi mdi-thumb-up" style="color:darkseagreen;"></i></a>
                                                    <cfelse>
                                                        <a href="##" title="#ticketusers.recordname#<cfif #ticketusers.rejectnotes# is not "">#ticketusers.rejectnotes#</cfif>"> <i class="mdi mdi-thumb-down" style="color: darkred;"></i></a>
                                                    </cfif>
                                                </cfoutput>
                                            </Cfloop>  
                                        </td>
                                    </tr>
                                    <cfoutput> 
                                        <div id="myModal#results.recid#" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" >

                                            <div class="modal-dialog">
                                                <div class="modal-content">
                                                    <div class="modal-header" >
                                                        <h4 class="modal-title" id="standard-modalLabel">No. 0000#results.recid# - #results.col4# </h4>
                                                        <button type="button" class="close" data-bs-dismiss="modal" >
x</button>
                                                    </div>
                                                    <div class="modal-body">
                                                    </div>
                                                </div>
                                                <!--- /.modal-content --->
                                            </div>
                                            <!--- /.modal-dialog --->
                                        </div>
                                    </cfoutput>
                                </cfoutput>
                            </cfloop>
                            
                            <div id="remoteNewForm" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" >

                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <div class="modal-header" >
                                            <h4 class="modal-title" id="standard-modalLabel">Add</h4>
                                            <button type="button" class="close" data-bs-dismiss="modal" >
x</button>
                                        </div>
                                        <div class="modal-body">
                                        </div>
                                    </div>
                                    <!--- /.modal-content --->
                                </div>
                                <!--- /.modal-dialog --->
                            </div>
                        </tbody>
                    </table>
                </div>
                <!--- end card body--->
            </div> <!--- end card --->
        </div><!--- end col --->
    </div>

    <SCRIPT>
        $(document).ready(function() {
            $("#basic-datatable").DataTable({
                columnDefs: [
                    { targets: [0, 1, 2, 3, 4, 5, 6], searchable: true, visible: true }
                ],
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
</cfif>
