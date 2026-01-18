<cfset dbug = "n" />
<!--- Include fields query template --->
<cfinclude template="/include/qry/FindFields_188_7.cfm" />
<cfset fieldset = valuelist(FindFields.fname) />
<cfparam name="filter" default="" />
<cfparam name="dbug" default="N" />

<!--- Check if the page ID is 29 and set the filter accordingly --->
<cfif #pgid# is "29">
    <cfset filter = "#filter# ORDER BY t.catOrder" />
</cfif>

<!--- Check if the page ID is 25 and set the filter accordingly --->
<cfif #pgid# is "25">
    <cfset filter = "#filter# ORDER BY t.actionNo" />
</cfif>

<!--- Query to find the key based on page ID --->
<cfinclude template="/include/qry/FindKey_526_1.cfm" />

<cfset sql_start = "SELECT t.#findkey.fname# as recid" />

<!--- Query to find results based on various joins and conditions --->
<cfinclude template="/include/qry/FindResults_526_2.cfm" />

<!--- Query to find joins based on conditions --->
<cfinclude template="/include/qry/FindJoins_526_3.cfm" />

<!--- Save the content of the results query --->
<cfsavecontent variable="resultsQuery">
    <cfoutput>
        #sql_start#
        <cfloop query="findresults">
            <cfif #comptableb# is "">
                ,t.#fname# as col#currentrow#, '#findresults.updatetype#' as updatetype#currentrow#, '#findresults.fname#' as fname#currentrow#
            <cfelse>
                ,#Findresults.talias#.recordname as col#currentrow#, 'recordname' as updatetype#currentrow#, 'recordname' as fname#currentrow#
            </cfif>
            , '#updatename#' as head#currentrow# 
        </cfloop>
        from #comptable# t
        <cfloop query="findjoins">
            <cfset talias = findjoins.talias />
            INNER JOIN #comptableb# #talias# on #talias#.#fnameb# = t.#fname#
        </cfloop> 
    </cfoutput>
</cfsavecontent>

<!--- Final query to get results based on the constructed query --->
<cfinclude template="/include/qry/results_526_4.cfm" />

