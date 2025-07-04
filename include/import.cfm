<!--- This ColdFusion page displays import details and a list of relationship contacts that were imported. --->

<div class="row">
    <div class="col-12">
        <div class="card mb-3">
            <div class="card-body">
                <h4 class="header-title">Import Details</h4>

                <div class="d-flex justify-content-between">
                    <div class="float-left">
                        <a title="View All" href="/app/contacts-import/">
                            <i class="mdi mdi-eye-outline"></i> View All
                        </a>
                    </div>
                    <div class="dropdown float-end">
                    </div>
                </div>

                <div class="row">
                    <cfoutput query="details">
                        <div class="col-3">
                            <p class="mt-2 mb-0 font-weight-bold">Batch ID</p>
                            <div class="media">
                                <div class="media-body">
                                    <div class="mt-0 font-size-12">
                                        #details.uploadid#
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-3">
                            <p class="mt-2 mb-0 font-weight-bold">Date</p>
                            <div class="media">
                                <div class="media-body">
                                    <div class="mt-0 font-size-12">
                                        #this.formatDate(details.timestamp)#
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-3">
                            <p class="mt-2 mb-0 font-weight-bold">Time</p>
                            <div class="media">
                                <div class="media-body">
                                    <div class="mt-0 font-size-12">
                                        #timeformat(details.timestamp)#
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-3">
                            <p class="mt-2 mb-0 font-weight-bold">Status</p>
                            <div class="media">
                                <div class="media-body">
                                    <div class="mt-0 font-size-12">
                                        #details.uploadstatus#
                                    </div>
                                </div>
                            </div>
                        </div>
                    </cfoutput>
                </div>
            </div>
        </div>
    </div>
</div>

<cfinclude template="/include/qry/results_142_1.cfm" />

<div class="row">
    <div class="col-12">
        <div class="card mb-3">
            <div class="card-body">
                <h6>
                    <cfoutput>#results.recordcount# relationship contacts were imported. Click on a name to view details.</cfoutput>
                </h6>
                <table id="basic-datatable" class="table display dt-responsive nowrap w-100 table-striped" role="grid">
                    <thead>
                        <cfoutput query="results" maxrows="1">
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
                                <th>#head5#</th>
                                <th>#head6#</th>
                            </tr>
                        </cfoutput>
                    </thead>
                    <tbody>
                        <cfloop query="results">
                            <cfset phonenumber = results.col3 />
                            <cfset cleanPhoneNumber = reReplace(phoneNumber, "[^0-9]", "", "ALL")>

                            <cfif "#len(cleanPhoneNumber)#" is "10">
                                <cfoutput>
                                    <cfset formatPhoneNumber = "(#left(cleanPhoneNumber, 3)#) #mid(cleanPhoneNumber, 4, 3)#-#right(cleanPhoneNumber, 4)#" />
                                    <cfset anchorPhoneNumber = "#left(cleanPhoneNumber, 3)#-#mid(cleanPhoneNumber, 4, 3)#-#right(cleanPhoneNumber, 4)#" />
                                </cfoutput>
                            <cfelse>
                                <cfoutput>
                                    <cfset formatPhoneNumber = "#phoneNumber#*" /> 
                                    <cfset anchorPhoneNumber = "#cleanPhoneNumber#*" /> 
                                </cfoutput>
                            </cfif>

                            <cfoutput>
                                <cfset cur_link="/app/contact/index.cfm?contactid=#results.contactid#" />
                                <tr role="row">
                                    <th>
                                        <a href="#cur_link#" class="text-body font-weight-semibold">
                                            #results.col1#
                                        </a>
                                    </th>
                                    <td>#col2#</td>
                                    <td><a href="tel:#anchorPhoneNumber#">#formatPhoneNumber#</a></td>
                                    <td>#col4#</td>
                                    <td>#col5#</td>
                                    <td>
                                        <cfif #status# is not "Added">
                                            <font color="red">#status#</font>
                                        <cfelse>
                                            #status#
                                        </cfif>
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
