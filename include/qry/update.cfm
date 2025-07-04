<!--- This ColdFusion page handles the retrieval and updating of RPG data based on specified criteria. --->

<cfset fieldset = valuelist(rpgupdate.fname) />

<cfinclude template="/include/rpg_load.cfm" />

<!--- Query to find the key based on pgid and updatename --->
<cfinclude template="/include/qry/FindKey_550_1.cfm" />

<cfoutput>
    <cfset pg_comptable = "#rpg_compTable#" />
</cfoutput>

<cfset sql_start = "SELECT t.#findkey.fname# as recid" />

<!--- Query to find results based on various joins and conditions --->
<cfinclude template="/include/qry/FindResults_550_2.cfm" />

<!--- Query to find joins based on specific conditions --->
<cfinclude template="/include/qry/FindJoins_550_3.cfm" />

<!--- Generate SQL query dynamically based on results and joins --->
<cfsavecontent variable="resultsQuery">
    <cfoutput>
        #sql_start#
        
        <cfloop query="findresults">
            <cfif #comptableb# is  "">
                ,t.#fname# as col#currentrow#
            <cfelse>
                ,#Findresults.talias#.recordname as col#currentrow#
            </cfif>
            , '#updatename#' as head#currentrow# 
            , #FindResults.det_cols# as pgcol#currentrow#
        </cfloop>
        
        FROM #rpg_compTable# t
        
        <cfloop query="findjoins">
            <cfset talias = findjoins.talias />
            INNER JOIN #comptableb# #talias# ON #talias#.#fnameb# = t.#fname#
        </cfloop> 
        
    </cfoutput>
</cfsavecontent>

<!--- Determine the WHERE clause based on the field type --->
<cfif #findresults.ftype# is "text">
    <cfset where = "WHERE t.#FindKey.fname# = '#recid#'" />
<cfelse>
    <cfset where = "WHERE t.#FindKey.fname# = #recid#" />
</cfif>

<!--- Execute the update query using the generated results and where clause --->
<cfinclude template="/include/qry/update_550_4.cfm" />

