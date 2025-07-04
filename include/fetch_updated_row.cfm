<!--- This ColdFusion page displays audition project results with links and error handling. --->

<cfparam name="url.id" default="">

<!--- Include query results and error templates --->
<cfinclude template="/include/qry/results_125_1.cfm" />
<cfinclude template="/include/qry/errs_125_2.cfm" />

<!--- Create a list of error messages from the error query --->
<cfset err_list = valuelist(errs.error_msg)>

<cfoutput>
    <td>
        <!--- Display audition project date with a link --->
        <a href="/app/audition/?audprojectid=#results.audprojectid#" class="text-body font-weight-semibold">
            <cfset myDateTime = results.col1b>
            <cfset myFormattedDateTime = this.formatDate(myDateTime)>
            #myFormattedDateTime#
        </a>
    </td>
    <td>
        <!--- Check if audition project ID exists and display accordingly --->
        <cfif len(results.audprojectid)>
            <a href="/app/audition/?audprojectid=#results.audprojectid#">#col2#</a>
        <cfelse>
            #col2#
        </cfif>
    </td>
    <td>
        <!--- Display category --->
        #col3# <!--- Category should be correctly displayed here --->
    </td>
    <td>#col4#</td>
    <td>#col5#</td>
    <td>
        <!--- Check if column 6 indicates an invalid state and display appropriate link/button --->
        <cfif col6 EQ "invalid">
            <a href="javascript:void(0);" data-toggle="modal" data-target="##fixModal" onclick="loadForm(#results.id#)" title="#err_list#">
                <font color="red">Invalid <i class="fe-search"></i></font>
                <button type="button" class="btn btn-sm btn-warning" onclick="loadForm(#results.id#)">Fix</button>
            </a>
        <cfelse>
            #col6#
        </cfif>
    </td>
</cfoutput>
