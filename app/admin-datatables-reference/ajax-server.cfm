<!---
    Sandbox §6 endpoint: server-side processing (DataTables SSP wire format).
    Manual start/length/order/search paging against pgpages_tbl.
    Admin-only via admin-guard.cfm.

    Production gold-standard for SSP: /include/contacts_ss.cfm (user-scoped,
    CSRF-checked, joined-table search). This sandbox is the minimum-viable
    shape - system-scoped, no joined search, single sort column.
--->
<cfset variables.isAjax = true>
<cfinclude template="/app/admin-users/admin-guard.cfm">

<!--- Merge form + url so the endpoint accepts either method --->
<cfset p = duplicate(form)>
<cfset structAppend(p, url, false)>

<!--- DataTables column index -> SQL column name (whitelist; ORDER BY uses interpolation) --->
<cfset orderableColumns = ["pgID", "pgDir", "pgName", "pgTitle", "pgFilename", "compID"]>

<cfset rawDraw    = structKeyExists(p, "draw")             ? p["draw"]             : 1>
<cfset rawStart   = structKeyExists(p, "start")            ? p["start"]            : 0>
<cfset rawLength  = structKeyExists(p, "length")           ? p["length"]           : 25>
<cfset rawOrdCol  = structKeyExists(p, "order[0][column]") ? p["order[0][column]"] : 0>
<cfset rawOrdDir  = structKeyExists(p, "order[0][dir]")    ? p["order[0][dir]"]    : "asc">
<cfset rawSearch  = structKeyExists(p, "search[value]")    ? p["search[value]"]    : "">

<cfset drawN     = isNumeric(rawDraw)   ? val(rawDraw)   : 1>
<cfset startRow  = max(0, isNumeric(rawStart) ? val(rawStart) : 0)>
<cfset pageLen   = isNumeric(rawLength) ? val(rawLength) : 25>
<cfif pageLen LTE 0 OR pageLen GT 500><cfset pageLen = 25></cfif>

<cfset ordIdx = isNumeric(rawOrdCol) ? val(rawOrdCol) : 0>
<cfif ordIdx LT 0 OR ordIdx GTE arrayLen(orderableColumns)><cfset ordIdx = 0></cfif>
<cfset orderCol = orderableColumns[ordIdx + 1]>
<cfset orderDir = (lcase(rawOrdDir) EQ "desc") ? "DESC" : "ASC">

<cfset searchVal = trim(rawSearch)>

<cfquery name="totalQ" datasource="#application.dsn#">
    SELECT COUNT(*) AS n
    FROM pgpages_tbl
    WHERE IsDeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit">
</cfquery>

<cfquery name="filteredQ" datasource="#application.dsn#">
    SELECT COUNT(*) AS n
    FROM pgpages_tbl
    WHERE IsDeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit">
    <cfif len(searchVal)>
        AND (
            pgDir      LIKE <cfqueryparam value="%#searchVal#%" cfsqltype="cf_sql_varchar">
         OR pgName     LIKE <cfqueryparam value="%#searchVal#%" cfsqltype="cf_sql_varchar">
         OR pgTitle    LIKE <cfqueryparam value="%#searchVal#%" cfsqltype="cf_sql_varchar">
         OR pgFilename LIKE <cfqueryparam value="%#searchVal#%" cfsqltype="cf_sql_varchar">
        )
    </cfif>
</cfquery>

<cfquery name="dataQ" datasource="#application.dsn#">
    SELECT pgID, pgDir, pgName, pgTitle, pgFilename, compID
    FROM pgpages_tbl
    WHERE IsDeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit">
    <cfif len(searchVal)>
        AND (
            pgDir      LIKE <cfqueryparam value="%#searchVal#%" cfsqltype="cf_sql_varchar">
         OR pgName     LIKE <cfqueryparam value="%#searchVal#%" cfsqltype="cf_sql_varchar">
         OR pgTitle    LIKE <cfqueryparam value="%#searchVal#%" cfsqltype="cf_sql_varchar">
         OR pgFilename LIKE <cfqueryparam value="%#searchVal#%" cfsqltype="cf_sql_varchar">
        )
    </cfif>
    ORDER BY #orderCol# #orderDir#
    LIMIT <cfqueryparam value="#pageLen#"  cfsqltype="cf_sql_integer">
    OFFSET <cfqueryparam value="#startRow#" cfsqltype="cf_sql_integer">
</cfquery>

<cfset rows = []>
<cfloop query="dataQ">
    <cfset arrayAppend(rows, {
        "pgID"       = dataQ.pgID,
        "pgDir"      = dataQ.pgDir,
        "pgName"     = dataQ.pgName,
        "pgTitle"    = dataQ.pgTitle,
        "pgFilename" = dataQ.pgFilename,
        "compID"     = dataQ.compID
    })>
</cfloop>

<cfset payload = {
    "draw"            = drawN,
    "recordsTotal"    = totalQ.n,
    "recordsFiltered" = filteredQ.n,
    "data"            = rows
}>

<cfcontent type="application/json; charset=utf-8" reset="true">
<cfoutput>#serializeJSON(payload)#</cfoutput>
