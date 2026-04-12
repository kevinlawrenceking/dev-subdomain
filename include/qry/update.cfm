<cfinclude template="/include/perfcount.cfm" />
<!--- This ColdFusion page handles the retrieval and updating of RPG data based on specified criteria. --->

<cfset fieldset = valuelist(rpgupdate.fname) />

<cfinclude template="/include/rpg_load.cfm" />

<!--- Query to find the key based on pgid and updatename --->
<cfinclude template="/include/qry/FindKey_550_1.cfm" />

<!--- WO-5B: Validate RPG identifiers from metadata --->
<cfif NOT reFindNoCase("^[a-z_][a-z0-9_]{0,63}$", trim(rpg_compTable))>
    <cflog file="qry_update" text="BLOCKED: invalid table name rpg_compTable='#htmlEditFormat(rpg_compTable)#'" />
    <cfabort>
</cfif>
<cfif NOT reFindNoCase("^[a-z_][a-z0-9_]{0,63}$", trim(findkey.fname))>
    <cflog file="qry_update" text="BLOCKED: invalid column name findkey.fname='#htmlEditFormat(findkey.fname)#'" />
    <cfabort>
</cfif>

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
            <!--- WO-5B: Validate per-row identifiers --->
            <cfif len(trim(fname)) AND NOT reFindNoCase("^[a-z_][a-z0-9_]{0,63}$", trim(fname))><cfcontinue /></cfif>
            <cfif len(trim(comptableb)) AND NOT reFindNoCase("^[a-z_][a-z0-9_]{0,63}$", trim(comptableb))><cfcontinue /></cfif>
            <cfif len(trim(findresults.talias)) AND NOT reFindNoCase("^[a-z_][a-z0-9_]{0,63}$", trim(findresults.talias))><cfcontinue /></cfif>
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
            <!--- WO-5B: Validate join identifiers --->
            <cfif NOT reFindNoCase("^[a-z_][a-z0-9_]{0,63}$", trim(comptableb))><cfcontinue /></cfif>
            <cfif NOT reFindNoCase("^[a-z_][a-z0-9_]{0,63}$", trim(talias))><cfcontinue /></cfif>
            <cfif len(trim(fnameb)) AND NOT reFindNoCase("^[a-z_][a-z0-9_]{0,63}$", trim(fnameb))><cfcontinue /></cfif>
            <cfif len(trim(fname)) AND NOT reFindNoCase("^[a-z_][a-z0-9_]{0,63}$", trim(fname))><cfcontinue /></cfif>
            INNER JOIN #comptableb# #talias# ON #talias#.#fnameb# = t.#fname#
        </cfloop> 
        
    </cfoutput>
</cfsavecontent>

<!--- Validate recid to prevent SQL injection --->
<cfif findresults.ftype NEQ "text" AND NOT isNumeric(recid)>
    <cfset recid = 0 />
</cfif>
<cfset recid = replace(replace(recid, "'", "", "all"), ";", "", "all") />

<!--- Determine the WHERE clause based on the field type --->
<cfif #findresults.ftype# is "text">
    <cfset where = "WHERE t.#FindKey.fname# = '#recid#'" />
<cfelse>
    <cfset where = "WHERE t.#FindKey.fname# = #val(recid)#" />
</cfif>

<!--- Execute the update query using the generated results and where clause --->
<cfinclude template="/include/qry/update_550_4.cfm" />

