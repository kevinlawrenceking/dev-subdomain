<!---
    Sandbox §5 endpoint: client-side AJAX (dataSrc).
    Returns { data: [...] } shaped for the section's columns array.
    Admin-only via admin-guard.cfm (variables.isAjax = true returns JSON 403).
--->
<cfset variables.isAjax = true>
<cfinclude template="/app/admin-users/admin-guard.cfm">

<cfquery name="versions" datasource="#application.dsn#">
    SELECT verid,
           CONCAT(IFNULL(major,0), '.', IFNULL(minor,0), '.', IFNULL(patch,0)) AS vername,
           IFNULL(versiontype, '')   AS versiontype,
           IFNULL(versionstatus, '') AS versionstatus,
           releasedate
    FROM taoversions
    ORDER BY verid DESC
    LIMIT 100
</cfquery>

<cfset payload = { "data" = [] }>
<cfloop query="versions">
    <cfset arrayAppend(payload.data, {
        "verid"         = versions.verid,
        "vername"       = versions.vername,
        "versiontype"   = versions.versiontype,
        "versionstatus" = versions.versionstatus,
        "releasedate"   = isDate(versions.releasedate) ? dateFormat(versions.releasedate, "yyyy-mm-dd") : ""
    })>
</cfloop>

<cfcontent type="application/json; charset=utf-8" reset="true">
<cfoutput>#serializeJSON(payload)#</cfoutput>
