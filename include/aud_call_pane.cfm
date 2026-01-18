<!--- This ColdFusion page displays a list of results in a card format, including project details and a view link. --->
<cfinclude template="/include/qry/results_43_1.cfm" />

<div class="row">
    <div class="col-12">

        <cfset i = 0>
        <div class="row">

            <!--- Loop through the query results --->
            <cfloop query="results">
                <cfoutput>
                    <cfset i = #i# + 1 />
                    <div class="col-lg-4">
                        <div class="card ribbon-box">

                            <div class="card-header d-flex">
                                <center>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#this.formatDate("#results.col1#")#</center>
                                <span class="ms-auto text-muted">#results.col4#</span>
                            </div>

                            <div class="card-body">

                                <!--- Check if 'audstep' is not 'audition' and display the ribbon if true --->
                                <cfif #results.audstep# is not "audition">
                                    <div class="ribbon ribbon-info float-end">
                                        <i class="mdi mdi-access-point me-1"></i> #results.audstep#
                                    </div>
                                </cfif>
                                <h5 class="card-title">
                                    <cfif #results.col2# is "">Unknown Project</cfif>#results.col2#
                                </h5>
                                <p class="card-text"><strong>Source: </strong>#results.col3#</p>
                                <p class="card-text"><strong>Role: </strong>#results.col5#</p>
                                <a href="/app/audition/?audprojectid=#audprojectid#&eventid=#results.recid#" class="btn btn-primary waves-effect waves-light">View</a>
                            </div>
                        </div> <!--- end card --->
                    </div> <!--- end col --->

                    <!--- Check if the counter 'i' equals 3 to create a new row --->
                    <cfif #i# is "3">
                        </div>
                        <div class="row">
                            <cfset i = 0>
                    </cfif>

                </cfoutput>
            </cfloop>

        </div>
        <!--- end card body --->
    </div> <!--- end card --->

</div>

<!--- Default bootstrap modal example --->

<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), " \")#" />
