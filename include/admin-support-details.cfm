<!--- This ColdFusion page displays ticket information and a ticket log for a specific ticket record. --->
<cfparam name="pgaction" default="view" />
<cfparam name="oldverid" default="0" />
<cfset sel_search = "" />
<cfparam name="select_userid" default="%" />
<cfparam name="select_ticketstatus" default="%" />
<cfparam name="select_tickettype" default="%" />     
<cfparam name="select_pgid" default="%" />     

<cfset modalid = "remoteticketupdate" />
<cfset modaltitle = "Ticket Information" />
<cfinclude template="/include/modal.cfm" />

<!--- Page content display based on action --->
<cfif pgaction eq "view">
    <div class="row">
        <div class="col-12">
            <div class="card mb-3">
                <div class="card-body">
                    <h4 class="header-title">
                        <cfoutput>#pgHeading# for No. #ticketDetails.recid#: #ticketDetails.recordname#</cfoutput>
                   
                    </h4>

                    <div class="d-flex justify-content-between">
                        <!--- Determine back location based on old version ID --->
                        <cfif oldverid eq "0">
                            <cfset backloc = "/app/admin-support/" />
                        <cfelse>
                            <cfoutput>
                                <cfset backloc = "/app/version/?recid=#oldverid#" />
                            </cfoutput>
                        </cfif>

                        <div class="float-left">
                            <a href="<Cfoutput>#backloc#</cfoutput>" style="background-color: #406e8e; border: #406e8e; margin-bottom: 10px;" class="btn btn-xs btn-primary waves-effect mb-2 waves-light">
                                Back
                            </a>
                        </div>

                        <div class="dropdown float-end">
                            <a href="<Cfoutput>/app/admin-support-update/?recid=#recid#</cfoutput>" style="background-color: #406e8e; border: #406e8e; margin-bottom: 10px;" class="btn btn-xs btn-primary waves-effect mb-2 waves-light">
                                Update
                            </a>
                        </div>
                    </div>

                    <!--- Ticket Information Section --->
                    <div class="row">
                        <cfset n = 0 />
                        <cfoutput query="ticketDetails">
                            <h5 class="col-md-12">Ticket Information</h5>

                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Name</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">#ticketDetails.ticketname#</div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Page</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">#ticketDetails.pgname#</div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Username</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">#ticketDetails.username#</div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Created</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">#this.formatDate(createddate)# at #timeFormat(createddate)#</div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Status</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">#ticketDetails.ticketstatus#</div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Type</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">#ticketDetails.tickettype#</div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Environment</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">
                                            <cfif ticketDetails.environ eq "D">
                                                <span style="color:red;">Development</span>
                                            <cfelse>
                                                Production
                                            </cfif>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Priority</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">#ticketDetails.ticketpriority#</div>
                                    </div>
                                </div>
                            </div>

                            <cfif ticketDetails.ticketdetails neq "">
                                <div class="col-md-12">
                                    <p class="mt-2 mb-0 font-weight-bold">Details</p>
                                    <div class="media">
                                        <div class="media-body">
                                            <div class="mt-0 font-size-12">#ticketDetails.ticketdetails#</div>
                                        </div>
                                    </div>
                                </div>
                            </cfif>

                            <cfif ticketDetails.ticketresponse neq "">
                                <div class="col-md-12">
                                    <p class="mt-2 mb-0 font-weight-bold">Developer Response</p>
                                    <div class="media">
                                        <div class="media-body">
                                            <div class="mt-0 font-size-12">#ticketDetails.ticketresponse#</div>
                                        </div>
                                    </div>
                                </div>
                            </cfif>

                            <div class="col-md-12">
                                <p>&nbsp;</p>
                            </div>

                            <h5 class="col-md-12">Progress & Execution</h5>

                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Est. Hours</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">
                                            <cfif ticketDetails.esthours neq "">#ticketDetails.esthours#<cfelse>Unknown</cfif>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Assigned Release.</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">
                                            <cfif ticketDetails.verid neq "">
                                                #ticketDetails.major#.#ticketDetails.minor#.#ticketDetails.patch#.#ticketDetails.version#
                                            </cfif>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Est. Release Date</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">
                                            <cfif ticketDetails.releasedate neq "">#this.formatDate(ticketDetails.releasedate)#</cfif>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <p class="mt-2 mb-0 font-weight-bold">Implementation Date</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">
                                            <cfif ticketDetails.ticketCompletedDate neq "">#this.formatDate(ticketDetails.ticketCompletedDate)#</cfif>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-6">
                                <p class="mt-2 mb-0 font-weight-bold">Patch Note (Displays to users in Release History)</p>
                                <div class="media">
                                    <div class="media-body">
                                        <div class="mt-0 font-size-12">#ticketDetails.patchNote#</div>
                                    </div>
                                </div>
                            </div>

                            <cfif ticketDetails.testingscript neq "">
                                <div class="col-md-12">
                                    <p class="mt-2 mb-0 font-weight-bold">Testing Script</p>
                                    <div class="media">
                                        <div class="media-body">
                                            <div class="mt-0 font-size-12">#ticketDetails.testingscript#</div>
                                        </div>
                                    </div>
                                </div>
                            </cfif>

                            <cfif ticketDetails.customtestpagename neq "">
                                <div class="col-md-3">
                                    <p class="mt-2 mb-0 font-weight-bold">Custom Test Page Name (Optional)</p>
                                    <div class="media">
                                        <div class="media-body">
                                            <div class="mt-0 font-size-12">#ticketDetails.customtestpagename#</div>
                                        </div>
                                    </div>
                                </div>
                            </cfif>

                            <cfif ticketDetails.customtestpagelink neq "">
                                <div class="col-md-3">
                                    <p class="mt-2 mb-0 font-weight-bold">Custom Test Page Link (Optional)</p>
                                    <div class="media">
                                        <div class="media-body">
                                            <div class="mt-0 font-size-12">
                                                <a href="#ticketDetails.customtestpagelink#" target="test">#ticketDetails.customtestpagelink#</a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </cfif>

                            <div class="col-md-12">
                                <form action="/include/ticket_email_client.cfm">
                                    <input type="submit" value="Email Client" />
                                    <input type="hidden" name="recid" value="#recid#" />
                                </form>
                            </div>
                        </cfoutput>
                    </div>
                </div>
            </div>
        </div>
    </div>

<!--- Ticket Log Table Section --->
    <div class="row">
        <div class="col-12">
            <div class="card mb-3">
                <div class="card-body">
                    <h4 class="header-title">Ticket Log</h4>
                    <p class="text-muted font-13 mb-4"></p>
                    <table id="basic-datatable" class="table dt-responsive nowrap w-100 table-striped" role="grid">
                        <thead>
                            <cfloop query="ticketLog" endrow="1">
                                <cfoutput>
                                    <cfif (ticketLog.CurrentRow MOD 2)>
                                        <cfset rowtype = "Odd" />
                                    <cfelse>
                                        <cfset rowtype = "Even" />
                                    </cfif>

                                    <tr class="#rowtype#">
                                        <th>#head2#</th>
                                        <th>#head5#</th>
                                        <th>#head4#</th>
                                    </tr>
                                </cfoutput>
                            </cfloop>
                        </thead>
                        <tbody>
                            <cfloop query="ticketLog">
                                <cfoutput>
                                    <tr>
                                        <td nowrap="nowrap">#datetimeFormat(ticketLog.col2, "short")#</td>
                                        <td nowrap="nowrap">#ticketLog.col5#</td>
                                        <td class="wrapit">#ticketLog.col1# #ticketLog.col4#</td>
                                    </tr>
                                </cfoutput>
                            </cfloop>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</cfif>

<script>
    $(document).ready(function () {
        <cfoutput>
            setupModalLoading("remoteticketupdate", "/include/remotelinkAdd.cfm", "id=#recid#");
        </cfoutput>
    });
</script>
