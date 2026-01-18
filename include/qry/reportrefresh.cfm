<cfset ReportsRefreshService = createObject("component", "services.ReportsRefreshService")>
<cfparam name="new_audcatid" default="1">
<cfparam name="new_audsourceid" default="0">
<cfparam name="new_audsourceidb" default="1">
<cfparam name="rangestart" default="2022-01-01">
<cfparam name="rangeend" default="2500-12-31">
<cfset rangestart = rangeselected.rangestart />
<cfset rangeend = rangeselected.rangeend />
<cfset rangeid = rangeselected.rangeid />
<cfif isdefined('form.new_audcatid')>
    <cfset new_audcatid = form.new_audcatid />
</cfif>

<!--- Initialize summary array --->
<cfset reportSummaries = []>

<!--- Report Calls --->
<cfset reportFunctions = [
    {id=2, fn="report_2", params={userid=userid, rangestart=rangestart, rangeend=rangeend, new_audcatid=new_audcatid}},
    {id=3, fn="report_3", params={userid=userid, rangestart=rangestart, rangeend=rangeend}},
    {id=4, fn="report_4", params={userid=userid, rangestart=rangestart, rangeend=rangeend}},
    {id=5, fn="report_5", params={userid=userid, rangestart=rangestart, rangeend=rangeend}},
      {id=6, fn="report_6", params={userid=userid, rangestart=rangestart, rangeend=rangeend, new_audsourceidb=new_audsourceidb}},
    {id=7, fn="report_7", params={userid=userid, rangestart=rangestart, rangeend=rangeend, new_audcatid=new_audcatid}},
    {id=8, fn="report_8", params={userid=userid, rangestart=rangestart, rangeend=rangeend, new_audcatid=new_audcatid}},
    {id=9, fn="report_9", params={userid=userid, rangestart=rangestart, rangeend=rangeend}},
    {id=10, fn="report_10", params={userid=userid, new_rangestart=rangestart, new_rangeend=rangeend}},
    {id=11, fn="report_11", params={userid=userid, rangestart=rangestart, rangeend=rangeend}},
    {id=12, fn="report_12", params={userid=userid, rangestart=rangestart, rangeend=rangeend}},
    {id=13, fn="report_13", params={userid=userid, rangestart=rangestart, rangeend=rangeend}},
    {id=17, fn="report_17", params={userid=userid, rangestart=rangestart, rangeend=rangeend}},
    {id=18, fn="report_18", params={userid=userid, rangestart=rangestart, rangeend=rangeend, new_audsourceid=new_audsourceid}}
]>

<!--- Execute and collect summaries --->
<cfloop array="#reportFunctions#" index="report">
    <cftry>
        <!--- Dynamically invoke the function using its name --->
        <cfset result = invoke(ReportsRefreshService, report.fn, report.params)>
        
        <!--- Append the report summary --->
        <cfset arrayAppend(reportSummaries, {
            reportId = report.id,
            totalSelected = result.totalSelected,
            totalInserted = result.totalInserted
        })>
    <cfcatch>
        <!--- Handle errors and add error info to summaries --->
        <cfset arrayAppend(reportSummaries, {
            reportId = report.id,
            totalSelected = "Error",
            totalInserted = "Error"
        })>
        <cfoutput><p>Error in Report ID #report.id#: #cfcatch.message#</p>

        <ul>
        <li><strong>Message:</strong> #cfcatch.message#</li>
        <li><strong>Detail:</strong> #cfcatch.detail#</li>
        <li><strong>Error Code:</strong> #cfcatch.errorCode#</li>
        <li><strong>Type:</strong> #cfcatch.type#</li>
        <li><strong>Stack Trace:</strong> <pre>#cfcatch.stackTrace#</pre></li>
    </ul>

    </cfoutput>
    </cfcatch>
    </cftry>
</cfloop>

<!--- Display Report Summaries --->
<div>
<H1>CURRENTLY TESTING!</H1>
    <h3>Report Summaries</h3>
    <table border="1">
        <thead>
            <tr>
                <th>Report ID</th>
                <th>Total Selected</th>
                <th>Total Inserted</th>
            </tr>
        </thead>
        <tbody>
            <cfloop array="#reportSummaries#" index="summary"><cfoutput>
                <tr>
                    <td>#summary.reportId#</td>
                    <td>#summary.totalSelected#</td>
                    <td>#summary.totalInserted#</td>
                </tr></cfoutput>
            </cfloop>
        </tbody>
    </table>
</div> 