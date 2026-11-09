<!---
  POST /ajax/master/resyncall.cfm   (DIR-LNK-WO-8)
  ADMIN-ONLY on-demand master re-sync + first-run backfill. Auth + CSRF are enforced by
  /ajax/Application.cfc (401 without a session, 403 without a valid CSRF token on POST); this
  endpoint adds the admin gate. Sweeps every linked contact and refreshes the three master-managed
  columns where _src='master' (value-comparison, idempotent, no-op where correct - a total no-op
  against a fully-current dataset). Server re-derives every value; NO client input is used.
  Response JSON: { success, message, data:{ scanned, synced, skipped, failed, fieldsWritten, runId }, _build }

  ADMIN GATE (N-3): gated on a DB-backed role check (taousers.userRole IN Admin/Administrator), the
  reliable signal used by app/admin-users/admin-guard.cfm and ajax/importv3/admin_dashboard.cfm - NOT
  session.isAdmin, which has NO set-site anywhere in the codebase and would leave the endpoint
  permanently 403. (Register: the ~7 existing endpoints gating on session.isAdmin share that latent
  defect; out of WO-8 scope.)
--->
<cfset buildTag = "wo8-resyncall-2026-07-28-v1">
<cfcontent type="application/json" reset="true">
<cfinclude template="../../include/book_feature_guard.cfm"><!--- Book switch: FEATURE_DISABLED when off --->

<cfset response = { "success": false, "message": "", "data": {}, "_build": buildTag }>

<cfset isAdminUser = false>
<cfif structKeyExists(session, "userid")>
    <cfquery name="qRole" maxrows="1">
        SELECT userRole
        FROM taousers
        WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer">
    </cfquery>
    <cfif qRole.recordCount AND (qRole.userRole EQ "Admin" OR qRole.userRole EQ "Administrator")>
        <cfset isAdminUser = true>
    </cfif>
</cfif>

<cfif NOT isAdminUser>
    <cfheader statuscode="403">
    <cfset response.message = "Admin access required.">
    <cfoutput>#serializeJSON(response)#</cfoutput>
    <cfabort>
</cfif>

<cftry>
    <cfset svc = request.svc("MasterDirectoryService")>
    <cfset result = svc.resyncAllLinked()>

    <cfset response.success = result.success>
    <cfset response.message = structKeyExists(result, "message") ? result.message : "">
    <cfif structKeyExists(result, "data")><cfset response.data = result.data></cfif>

    <cfcatch type="any">
        <cfset response.success = false>
        <cfset response.message = "Re-sync failed.">
        <cflog file="master_sync" type="error"
               text="resyncall FAIL user=#(structKeyExists(session,'userid') ? session.userid : 'na')# err=#cfcatch.message#">
        <!--- Persist the handled exception as an error_tickets row (cf_context='handled') so it is
              visible without server log access. Never allowed to change this response. --->
        <cftry>
            <cfif structKeyExists(application, "services") AND structKeyExists(application.services, "errorService")>
                <cfset application.services.errorService.captureHandled(cfcatch, "master-resyncall")>
            </cfif>
            <cfcatch type="any"></cfcatch>
        </cftry>
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
