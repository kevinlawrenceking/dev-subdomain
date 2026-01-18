<!--- This ColdFusion page processes data for a table, handling search, filtering, and outputting JSON format for front-end consumption. --->
<cfparam name="event_id" default="0" />

<cfcontent reset="true">
<cfset listColumns = "`contactid`,`col1`,`col2`,`col3`,`col4`,`col5`" />
<cfset sIndexColumn = "contactid" />
<cfparam name="draw" default="1" type="integer" />
<cfparam name="start" default="0" type="integer" />
<cfparam name="length" default="10" type="integer" />
<cfparam name="search" default="" type="string" />
<cfparam name="BYTAG" default="" type="string" />

<!--- Check if search value is provided --->

<cfif structKeyExists(form, "search[value]") and len(form["search[value]"]) gt 0>
    <cfset search = form["search[value]"]>
</cfif>

<!--- Data set after filtering --->
<cfinclude template="/include/qry/qFiltered_77_1.cfm" />

<!--- Total data set length --->
<cfinclude template="/include/qry/qCount_77_2.cfm" />

<!--- Determine total records based on filtered results --->
<cfif qFiltered.recordcount gt 0>
    <cfset recordsTotal = #qCount.total#>
<cfelse>
    <cfset recordsTotal = 0>
</cfif>

<!--- Output JSON response --->
{
    "draw": <cfoutput>#val(draw)#</cfoutput>,
    "recordsTotal": <cfoutput>#recordsTotal#</cfoutput>,
    "recordsFiltered": <cfoutput>#qFiltered.recordCount#</cfoutput>,
    "data": 
    <cfif qFiltered.recordcount gt 0>
    [
        <cfoutput query="qFiltered" startrow="#val(start + 1)#" maxrows="#val(length)#">
            <cfif currentRow gt (start + 1)>,</cfif>
            [
                "#SerializeJSON(qFiltered.contactid)#",
                #SerializeJSON(qFiltered.hlink)#,
                #SerializeJSON(qFiltered.col2)#,
                #SerializeJSON(qFiltered.col5)#,
                #SerializeJSON(qFiltered.col3)#,
                #SerializeJSON(qFiltered.col4)#
            ]
        </cfoutput>
    ]
    <cfelse>
        ""
    </cfif>
}
