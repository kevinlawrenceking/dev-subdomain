<cfparam name="select_userid" default="%" />
<cfparam name="select_ticketstatus" default="%" />
<cfparam name="select_tickettype" default="%" />
<cfparam name="select_ticketpriority" default="%" />
<cfparam name="select_pgid" default="%" />
<cfparam name="select_verid" default="%" />

<!--- Pre-fetch versions query outside the results loop for better performance --->
<cfquery name="all_versions" datasource="#dsn#" cachedwithin="#CreateTimeSpan(0,0,30,0)#">
    SELECT 
        v.verid AS id,
        v.major,
        v.minor,
        v.patch, 
        v.alphabeta,
        CONCAT(v.major,'.',v.minor,'.',v.patch,'-',v.alphabeta) as name,
        v.hoursavail,
        v.versionstatus,
        IFNULL((SELECT SUM(esthours) FROM tickets t WHERE verid = v.verid),0) AS hours_used,
        ((v.hoursavail) - IFNULL((SELECT SUM(esthours) FROM tickets t WHERE verid = v.verid),0)) AS hoursleft
    FROM taoversions v 
    WHERE v.versionstatus = 'Pending'
    ORDER BY major, minor, patch
</cfquery>

<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-body">
                <h4 class="header-title">Support Tickets</h4>
                
                <!--- Filter Form --->
                <form action="/app/admin-support/" method="get">
                    <div class="row">
                        <!--- User Filter --->
                        <div class="form-group col-md-4">
                            <label for="select_userid">User</label>
                            <select class="form-control" name="select_userid" id="select_userid" onchange="this.form.submit()">
                                <option value="%" <cfif select_userid is "%">selected</cfif>>All Users</option>
                                <cfoutput query="users">
                                    <option value="#users.userid#" <cfif users.userid is select_userid>selected</cfif>>#users.recordname# <cfif users.userrole is not "user">(#users.userrole#)</cfif></option>
                                </cfoutput>
                            </select>
                            <div class="invalid-feedback">Please select a User.</div>
                        </div>
                        
                        <!--- Status Filter --->
                        <div class="form-group col-md-4">
                            <label for="select_ticketstatus">Status</label>
                            <select class="form-control" name="select_ticketstatus" id="select_ticketstatus" onchange="this.form.submit()">
                                <option value="%" <cfif select_ticketstatus is "%">selected</cfif>>All</option>
                                <cfoutput query="statuses">
                                    <option value="#statuses.ticketstatus#" <cfif statuses.ticketstatus is select_ticketstatus>selected</cfif>>#statuses.ticketstatus#</option>
                                </cfoutput>
                            </select>
                            <div class="invalid-feedback">Please select a Status.</div>
                        </div>
                        
                        <!--- Type Filter --->
                        <div class="form-group col-md-4">
                            <label for="select_tickettype">Type</label>
                            <select class="form-control" name="select_tickettype" id="select_tickettype" onchange="this.form.submit()">
                                <option value="%" <cfif select_tickettype is "%">selected</cfif>>All Types</option>
                                <cfoutput query="types">
                                    <option value="#types.tickettype#" <cfif types.tickettype is select_tickettype>selected</cfif>>#types.tickettype#</option>
                                </cfoutput>
                            </select>
                            <div class="invalid-feedback">Please select a Type.</div>
                        </div>
                        
                        <!--- Pages Filter --->
                        <div class="form-group col-md-4">
                            <label for="select_pgid">Pages</label>
                            <select class="form-control" name="select_pgid" id="select_pgid" onchange="this.form.submit()">
                                <option value="%" <cfif select_pgid is "%">selected</cfif>>All Pages</option>
                                <cfoutput query="pages">
                                    <option value="#pages.pgid#" <cfif pages.pgid is select_pgid>selected</cfif>>#pages.pgname#</option>
                                </cfoutput>
                            </select>
                            <div class="invalid-feedback">Please select a Page.</div>
                        </div>
                        
                        <!--- Priority Filter --->
                        <div class="form-group col-md-4">
                            <label for="select_ticketpriority">Priority</label>
                            <select class="form-control" name="select_ticketpriority" id="select_ticketpriority" onchange="this.form.submit()">
                                <option value="%" <cfif select_ticketpriority is "%">selected</cfif>>All Priorities</option>
                                <cfoutput query="priorities">
                                    <option value="#priorities.name#" <cfif priorities.name is select_ticketpriority>selected</cfif>>#priorities.name#</option>
                                </cfoutput>
                            </select>
                            <div class="invalid-feedback">Please select a Priority.</div>
                        </div>
                        
                        <!--- Release Filter --->
                        <div class="form-group col-md-4">
                            <label for="select_verid">Release (hours left)</label>
                            <select class="form-control" name="select_verid" id="select_verid" onchange="this.form.submit()">
                                <option value="%" <cfif select_verid is "%">selected</cfif>>All Releases</option>
                                <option value="0" <cfif select_verid is "0">selected</cfif>>None</option>
                                <cfoutput query="vers">
                                    <option value="#vers.id#" <cfif vers.id is select_verid>selected</cfif>>#vers.name# (#numberformat(vers.hoursleft,'9.99')# hrs)</option>
                                </cfoutput>
                            </select>
                            <div class="invalid-feedback">Please select a Release.</div>
                        </div>
                    </div>
                </form>
                
                <!--- Results Table --->
                <table id="basic-datatable" class="table dt-responsive nowrap w-100 table-striped" role="grid">
                    <thead>
                        <cfif results.recordCount GT 0>
                            <cfoutput>
                                <tr>
                                    <th>Action</th>
                                    <th>#head1#</th>
                                    <th>#head2#</th>
                                    <cfif isdefined('safddfs')><th>#head3#</th></cfif>
                                    <cfif isdefined('safddfs')><th>#head4#</th></cfif>
                                    <th>#head45#</th>
                                    <th>#head5#</th>
                                    <th>#head6#</th>
                                    <th>#head7#</th>
                                    <th>Testing</th>
                                </tr>
                            </cfoutput>
                        </cfif>
                    </thead>
                    <tbody>
                        <cfloop query="results">
                            <!--- Filter versions for this ticket - avoid running a query in the loop --->
                            <cfset current_ticket_versions = []>
                            <cfloop query="all_versions">
                                <cfif 
                                    (all_versions.id NEQ results.verid AND 
                                     all_versions.hoursleft - numberformat(results.col6,'99999.99') GTE 0 AND
                                     all_versions.versionstatus EQ 'Pending')
                                     OR 
                                     all_versions.id EQ results.verid>
                                    <cfset arrayAppend(current_ticket_versions, {
                                        id = all_versions.id,
                                        name = all_versions.name,
                                        hoursleft = all_versions.hoursleft
                                    })>
                                </cfif>
                            </cfloop>
                            
                            <cfoutput>
                                <tr>
                                    <!--- Action Column --->
                                    <td>
                                        <cfif isdefined('sdfsdf')>
                                            <a href="remoteContent.cfm?recid=#results.recid#" data-remote="true" data-toggle="modal" data-target="##myModal#results.recid#">
                                                <i class="mdi mdi-square-edit-outline"></i>
                                            </a>
                                            &nbsp;
                                        </cfif>
                                        <a href="/include/deleteticket.cfm?recid=#results.recid#" class="delete-ticket" data-ticket-id="#results.recid#">
                                            <i class="mdi mdi-trash-can-outline mr-1"></i>
                                        </a>
                                    </td>
                                    
                                    <!--- Ticket ID Column --->
                                    <td>
                                        <a href="/app/admin-support-details/?recid=#results.recid#" title="#results.col4# - #results.col5#">#results.recid#</a>
                                    </td>
                                    
                                    <td>#results.col2#</td>
                                    <cfif isdefined('safddfs')><td>#results.col3#</td></cfif>
                                    <cfif isdefined('safddfs')><td>#results.col4#</td></cfif>
                                    <td>#results.col45#</td>
                                    
                                    <!--- Priority Column --->
                                    <td>
                                        <form class="ticket-update-form" id="updatever#results.recid#" method="post" action="/include/updatetickver2.cfm">
                                            <input type="hidden" name="ticketid" value="#results.recid#">
                                            <input type="hidden" name="old_verid" value="#results.verid#">
                                            <input type="hidden" name="old_ticketpriority" value="#results.col5#">
                                            
                                            <cfif results.col45 is not "closed" and results.col45 is not "Released">
                                                <select name="new_ticketpriority" id="new_ticketpriority_#results.recid#" onchange="this.form.submit()" required>
                                                    <cfloop query="priorities">
                                                        <option value="#priorities.id#" <cfif priorities.id is results.col5>selected</cfif>>#priorities.name#</option>
                                                    </cfloop>
                                                </select>
                                            <cfelse>
                                                #results.col5#
                                                <input type="hidden" name="new_ticketpriority" value="#results.col5#">
                                            </cfif>
                                    </td>
                                    
                                    <td>#results.col6#</td>
                                    
                                    <!--- Version Column --->
                                    <td>
                                        <cfif results.col45 is not "closed" and results.col45 is not "Released">
                                            <select name="new_verid" id="new_verid_#results.recid#" onchange="this.form.submit()" required>
                                                <option value="0" <cfif results.verid is "0">selected</cfif>>None</option>
                                                <cfloop array="#current_ticket_versions#" index="version">
                                                    <option value="#version.id#" <cfif version.id is results.verid>selected</cfif>>#version.name# (#numberformat(version.hoursleft,'9.99')# hrs)</option>
                                                </cfloop>
                                            </select>
                                        <cfelse>
                                            #results.col7#
                                            <input type="hidden" name="new_verid" value="#results.verid#">
                                        </cfif>
                                        </form>
                                    </td>
                                    
                                    <!--- Testing Column --->
                                    <td>
                                        <cfquery name="ticketusers" datasource="#dsn#">
                                            SELECT tu.id, tu.ticketid, tu.userid, u.recordname, tu.teststatus, tu.rejectnotes
                                            FROM tickettestusers tu
                                            INNER JOIN taousers u ON u.userid = tu.userid
                                            WHERE tu.ticketid = #results.recid#
                                        </cfquery>
                                        
                                        <cfloop query="ticketusers">
                                            <cfif ticketusers.teststatus is "Approved">
                                                <a href="##" title="#ticketusers.recordname#"> 
                                                    <i class="mdi mdi-thumb-up" style="color:darkseagreen;"></i>
                                                </a>
                                            <cfelse>
                                                <a href="##" title="#ticketusers.recordname#<cfif ticketusers.rejectnotes is not ""> - #ticketusers.rejectnotes#</cfif>"> 
                                                    <i class="mdi mdi-thumb-down" style="color:darkred;"></i>
                                                </a>
                                            </cfif>
                                        </cfloop>
                                    </td>
                                </tr>
                            </cfoutput>
                        </cfloop>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!--- Modal Containers --->
<cfloop query="results">
    <cfoutput>
        <div id="myModal#results.recid#" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header" style="background-color: ##f3f7f9;">
                        <h4 class="modal-title" id="standard-modalLabel">No. #numberformat(results.recid, '0000')# - #results.tickettype#</h4>
                        <button type="button" class="close" data-bs-dismiss="modal" aria-hidden="true">x</button>
                    </div>
                    <div class="modal-body"></div>
                </div>
            </div>
        </div>
    </cfoutput>
</cfloop>

<div id="remoteNewForm" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header" style="background-color: ##f3f7f9;">
                <h4 class="modal-title" id="standard-modalLabel">Add</h4>
                <button type="button" class="close" data-bs-dismiss="modal" aria-hidden="true">x</button>
            </div>
            <div class="modal-body"></div>
        </div>
    </div>
</div>

<!--- Consolidated JavaScript --->
<script>
    $(document).ready(function() {
        // Initialize DataTable with optimized options
        $("#basic-datatable").DataTable({
            "iDisplayLength": 100,
            "pageLength": 100,
            "stateSave": true,
            "processing": true,
            "language": {
                "paginate": {
                    "previous": "<i class='mdi mdi-chevron-left'>",
                    "next": "<i class='mdi mdi-chevron-right'>"
                },
                "emptyTable": "No tickets found with the current filter settings"
            },
            "drawCallback": function() {
                $(".dataTables_paginate > .pagination").addClass("pagination-rounded");
            }
        });
        
        // Modal loading handlers - consolidated into a single function
        function setupModalHandlers(selector, url) {
            $(selector).on("show.bs.modal", function(event) {
                $(this).find(".modal-body").load(url);
            });
        }
        
        // Setup modal handlers for ticket details
        <cfloop query="results">
            setupModalHandlers("##myModal#results.recid#", "/include/remotecontent.cfm?recid=#results.recid#");
        </cfloop>
        
        // Setup modal handler for new form
        setupModalHandlers("##remoteNewForm", "/include/RemoteNewForm.cfm?rpgid=36");
        
        // Add confirmation dialog for delete actions
        $(".delete-ticket").on("click", function(e) {
            if (!confirm("Are you sure you want to delete this ticket?")) {
                e.preventDefault();
            }
        });
    });
</script>

<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), '\')#" />
<cfinclude template="/include/bigbrotherinclude.cfm" />
