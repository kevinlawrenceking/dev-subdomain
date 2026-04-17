<cfcontent type="application/json" reset="true">

<cfparam name="draw"     default="1" type="integer">
<cfparam name="start"    default="0" type="integer">
<cfparam name="length"   default="10" type="integer">
<cfparam name="uploadid" default="0" type="integer">
<cfparam name="contacts_table" default="" type="string">
<cfparam name="bytag"    default="" type="string">
<cfparam name="byimport" default="" type="string">
<cfparam name="bylike"   default="" type="string">

<!--- userid: session is authoritative; URL form accepted for backward compat --->
<cfif structKeyExists(session, "userid") AND val(session.userid) gt 0>
    <cfset userid = session.userid>
<cfelseif structKeyExists(url, "userid") AND val(url.userid) gt 0>
    <cfset userid = url.userid>
<cfelseif structKeyExists(form, "userid") AND val(form.userid) gt 0>
    <cfset userid = form.userid>
<cfelse>
    {"draw": <cfoutput>#val(draw)#</cfoutput>, "recordsTotal": 0, "recordsFiltered": 0, "data": []}
    <cfabort>
</cfif>

<!--- DataTables search payload --->
<cfset searchValue = "">
<cfif structKeyExists(form, "search[value]") AND len(form["search[value]"]) gt 0>
    <cfset searchValue = form["search[value]"]>
</cfif>

<!--- WO-5B: Validate dynamic table name. On failure return a well-formed empty envelope
      so DataTables does not render "Invalid JSON response". --->
<cfif NOT reFindNoCase("^[a-z_][a-z0-9_]{0,63}$", trim(contacts_table))>
    <cflog file="contacts_ss" text="BLOCKED: invalid table name contacts_table='#htmlEditFormat(contacts_table)#'" />
    {"draw": <cfoutput>#val(draw)#</cfoutput>, "recordsTotal": 0, "recordsFiltered": 0, "data": []}
    <cfabort>
</cfif>

<!--- ORDER BY mapping. DataTables column index -> view field.
      Must match thead + columnDefs in contacts_table.cfm and the data row emit order below:
        0 = checkbox (not sortable)
        1 = Name    -> col1
        2 = Tags    -> col2b
        3 = Company -> col5
        4 = Phone   -> col3
        5 = Email   -> col4
--->
<cfset orderClause = "ORDER BY col1 ASC">
<cfif structKeyExists(form, "order[0][column]")>
    <cfset orderCol = val(form["order[0][column]"])>
    <cfset orderDir = (structKeyExists(form, "order[0][dir]") AND form["order[0][dir]"] IS "desc") ? "DESC" : "ASC">
    <cfswitch expression="#orderCol#">
        <cfcase value="1"><cfset orderClause = "ORDER BY col1 " & orderDir></cfcase>
        <cfcase value="2"><cfset orderClause = "ORDER BY col2b " & orderDir></cfcase>
        <cfcase value="3"><cfset orderClause = "ORDER BY col5 " & orderDir></cfcase>
        <cfcase value="4"><cfset orderClause = "ORDER BY col3 " & orderDir></cfcase>
        <cfcase value="5"><cfset orderClause = "ORDER BY col4 " & orderDir></cfcase>
    </cfswitch>
</cfif>

<!--- Unfiltered total for this user+grid (used for DataTables recordsTotal).
      WHERE is duplicated across the three queries intentionally: parameterized binds
      do not survive cfsavecontent, and triplicating keeps every placeholder bound. --->
<cfquery name="qTotal">
    SELECT COUNT(contactid) AS n
    FROM #contacts_table#
    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="CF_SQL_INTEGER">
    <cfif len(trim(bytag))>
        AND contactid IN (
            SELECT contactid FROM contactitems
            WHERE valuetype = 'tags' AND itemstatus = 'active'
              AND valuetext = <cfqueryparam cfsqltype="cf_sql_varchar" value="#bytag#">
        )
    </cfif>
    <cfif len(trim(byimport))>
        AND contactid IN (
            SELECT contactid FROM contactsimport
                WHERE uploadid = <cfqueryparam value="#byimport#" cfsqltype="CF_SQL_INTEGER">
            UNION
            SELECT created_contactid FROM import_v3_rows
                WHERE job_id = <cfqueryparam value="#byimport#" cfsqltype="CF_SQL_INTEGER">
                  AND created_contactid IS NOT NULL
        )
    </cfif>
    <cfif len(trim(bylike))>
        AND col1 LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#bylike#%">
    </cfif>
    <cfif val(uploadid) gt 0>
        AND contactid IN (
            SELECT contactid FROM contactsimport
            WHERE uploadid = <cfqueryparam value="#uploadid#" cfsqltype="cf_sql_integer">
        )
    </cfif>
</cfquery>

<!--- Filtered count (adds the DataTables search box filter) --->
<cfquery name="qFilteredCount">
    SELECT COUNT(contactid) AS n
    FROM #contacts_table#
    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="CF_SQL_INTEGER">
    <cfif len(trim(bytag))>
        AND contactid IN (
            SELECT contactid FROM contactitems
            WHERE valuetype = 'tags' AND itemstatus = 'active'
              AND valuetext = <cfqueryparam cfsqltype="cf_sql_varchar" value="#bytag#">
        )
    </cfif>
    <cfif len(trim(byimport))>
        AND contactid IN (
            SELECT contactid FROM contactsimport
                WHERE uploadid = <cfqueryparam value="#byimport#" cfsqltype="CF_SQL_INTEGER">
            UNION
            SELECT created_contactid FROM import_v3_rows
                WHERE job_id = <cfqueryparam value="#byimport#" cfsqltype="CF_SQL_INTEGER">
                  AND created_contactid IS NOT NULL
        )
    </cfif>
    <cfif len(trim(bylike))>
        AND col1 LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#bylike#%">
    </cfif>
    <cfif val(uploadid) gt 0>
        AND contactid IN (
            SELECT contactid FROM contactsimport
            WHERE uploadid = <cfqueryparam value="#uploadid#" cfsqltype="cf_sql_integer">
        )
    </cfif>
    <cfif len(trim(searchValue))>
        <cfif trim(searchValue) IS "no system">
            AND contactid NOT IN (SELECT contactid FROM contacts_ss_followup WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">)
            AND contactid NOT IN (SELECT contactid FROM contacts_ss_maint    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">)
            AND contactid NOT IN (SELECT contactid FROM contacts_ss_target   WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">)
        <cfelse>
            AND (
                   contactid LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(searchValue)#%">
                OR col1      LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(searchValue)#%">
                OR col2      LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(searchValue)#%">
                OR col3      LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(searchValue)#%">
                OR col4      LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(searchValue)#%">
                OR col5      LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(searchValue)#%">
            )
        </cfif>
    </cfif>
</cfquery>

<!--- Paged data: SQL LIMIT pushes pagination into the database --->
<cfquery name="qPage">
    SELECT contactid, col2b, col3, col4, col5, hlink
    FROM #contacts_table#
    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="CF_SQL_INTEGER">
    <cfif len(trim(bytag))>
        AND contactid IN (
            SELECT contactid FROM contactitems
            WHERE valuetype = 'tags' AND itemstatus = 'active'
              AND valuetext = <cfqueryparam cfsqltype="cf_sql_varchar" value="#bytag#">
        )
    </cfif>
    <cfif len(trim(byimport))>
        AND contactid IN (
            SELECT contactid FROM contactsimport
                WHERE uploadid = <cfqueryparam value="#byimport#" cfsqltype="CF_SQL_INTEGER">
            UNION
            SELECT created_contactid FROM import_v3_rows
                WHERE job_id = <cfqueryparam value="#byimport#" cfsqltype="CF_SQL_INTEGER">
                  AND created_contactid IS NOT NULL
        )
    </cfif>
    <cfif len(trim(bylike))>
        AND col1 LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#bylike#%">
    </cfif>
    <cfif val(uploadid) gt 0>
        AND contactid IN (
            SELECT contactid FROM contactsimport
            WHERE uploadid = <cfqueryparam value="#uploadid#" cfsqltype="cf_sql_integer">
        )
    </cfif>
    <cfif len(trim(searchValue))>
        <cfif trim(searchValue) IS "no system">
            AND contactid NOT IN (SELECT contactid FROM contacts_ss_followup WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">)
            AND contactid NOT IN (SELECT contactid FROM contacts_ss_maint    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">)
            AND contactid NOT IN (SELECT contactid FROM contacts_ss_target   WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">)
        <cfelse>
            AND (
                   contactid LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(searchValue)#%">
                OR col1      LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(searchValue)#%">
                OR col2      LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(searchValue)#%">
                OR col3      LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(searchValue)#%">
                OR col4      LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(searchValue)#%">
                OR col5      LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(searchValue)#%">
            )
        </cfif>
    </cfif>
    #preserveSingleQuotes(orderClause)#
    LIMIT <cfqueryparam value="#val(start)#"  cfsqltype="cf_sql_integer">,
          <cfqueryparam value="#val(length)#" cfsqltype="cf_sql_integer">
</cfquery>

{"draw": <cfoutput>#val(draw)#</cfoutput>,
"recordsTotal": <cfoutput>#qTotal.n#</cfoutput>,
"recordsFiltered": <cfoutput>#qFilteredCount.n#</cfoutput>,
"data": [<cfoutput query="qPage"><cfif currentRow gt 1>,</cfif>[#SerializeJSON(qPage.contactid)#,#SerializeJSON(qPage.hlink)#,#SerializeJSON(qPage.col2b)#,#SerializeJSON(qPage.col5)#,#SerializeJSON(qPage.col3)#,#SerializeJSON(qPage.col4)#]</cfoutput>]
}
