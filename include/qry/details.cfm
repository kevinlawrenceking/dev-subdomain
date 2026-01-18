<!--- This ColdFusion page retrieves and processes data from various database tables based on a given pgid, preparing results for further use. --->
<cfinclude template="/include/qry/FindFields_188_7.cfm" />
<cfset fieldset = valuelist(FindFields.fname) />

<cfset hh = 4 />

<!--- Query to find the key based on pgid and updatename --->
<cfinclude template="/include/qry/FindKey_466_1.cfm" />

<cfoutput>
    <cfset pg_comptable = "#comptable#" />
</cfoutput>

<!--- Debugging output if dbug is defined --->
<cfif #isdefined('dbug')#>
    <cfoutput>
        SELECT * 
        FROM pgfields 
        WHERE pgid = #pgid# 
        AND updatename = 'ID'<BR>
        SELECT recordname, #comptable#.#findkey.fname# as recid<BR>
        sql_start = "SELECT recordname, #comptable#.#findkey.fname# as recid"<BR>
        FIND RESULTS: SELECT      
        
        f.fname,
        f.fieldid,
        f.pgid,
        f.ftype,
        f.ftypefull,
        f.update_yn,
        f.updatename,
        f.updatetype,
        f.fkey,
        f.det_cols,
        c2.comptable as comptableb,
        c.comptable
        FROM pgpages p
        INNER JOIN pgcomps c ON c.compID = p.compID
        INNER JOIN pgapps a ON a.appID = c.appid
        INNER JOIN pgfields f ON f.pgid = p.pgid
        LEFT JOIN pgfields f2 ON f.fkey = f2.fieldid
        LEFT JOIN pgpages p2 ON p2.pgid = f2.pgid
        LEFT JOIN pgcomps c2 ON c2.compid = p2.compid
        WHERE p.pgid = #pgid# 
        AND f.details_yn = 'Y'
        ORDER BY f.displayOrder<BR>
    </cfoutput>
    <cfabort>
</cfif>

<cfset sql_start = "SELECT t.recordname, t.#findkey.fname# as recid" />

<!--- Query to find results based on pgid and details_yn --->
<cfinclude template="/include/qry/FindResults_466_2.cfm" />

<!--- Query to find joins based on pgid and details_yn --->
<cfinclude template="/include/qry/FindJoins_466_3.cfm" />

<!--- Save content of results query --->
<cfsavecontent variable="resultsQuery">
    <cfoutput>
        #sql_start#
        
        <cfloop query="findresults">
            <cfset ftype = "#findresults.ftype#" />
            <cfif #comptableb# is  "">
                , t.#fname# as col#currentrow#
            <cfelse>
                , #Findresults.talias#.recordname as col#currentrow#
            </cfif>
            , '#updatename#' as head#currentrow# 
            , #FindResults.det_cols# as pgcol#currentrow#
        </cfloop>
        FROM #comptable# t
        
        <cfloop query="findjoins">
            <cfset talias = findjoins.talias />
            INNER JOIN #comptableb# #talias# ON #talias#.#fnameb# = t.#fname#
        </cfloop> 
        
    </cfoutput>
</cfsavecontent>

<!--- Determine the WHERE clause based on ftype --->
<cfif #ftype# is "text">
    <cfset where = "WHERE t.#FindKey.fname# = '#recid#'" />
<cfelse>
    <cfset where = "WHERE t.#FindKey.fname# = #recid#" />
</cfif>

<!--- Query to get details based on results query and where clause --->
<cfinclude template="/include/qry/details_466_4.cfm" />

