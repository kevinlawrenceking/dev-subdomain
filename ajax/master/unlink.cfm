<!---
  POST /ajax/master/unlink.cfm   (DIR-WO-2 / TAO-MCD-P1)
  Unlink a TAO contact from its master person (R-1 match-guard). Auth + CSRF
  enforced by /ajax/Application.cfc.
  Params (form): contactid (int)
  Response JSON: { success, message, data, _build }
--->
<cfset buildTag = "master-unlink-2026-07-09-v1">
<cfcontent type="application/json" reset="true">
<cfinclude template="/include/book_feature_guard.cfm"><!--- Book switch: FEATURE_DISABLED when off --->

<cfparam name="form.contactid" default="0">

<cfif structKeyExists(form, "recordname")><cfset structDelete(form, "recordname")></cfif>

<cfset response = { "success": false, "message": "", "data": {}, "_build": buildTag }>

<cftry>
    <cfif NOT isValid("integer", form.contactid) OR val(form.contactid) LTE 0>
        <cfset response.message = "Missing or invalid contactid.">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <cfset svc = request.svc("MasterDirectoryService")>
    <cfset result = svc.unlinkMaster(
        contactid = int(form.contactid),
        userid    = session.userid)>

    <cfset response.success = result.success>
    <cfset response.message = structKeyExists(result, "message") ? result.message : "">
    <cfif structKeyExists(result, "data")><cfset response.data = result.data></cfif>

    <cfcatch type="any">
        <cfset response.success = false>
        <cfset response.message = "Unlink failed.">
        <cflog file="master_link" type="error"
               text="unlink FAIL userid=#(structKeyExists(session,'userid') ? session.userid : 'na')# contactid=#left(form.contactid,20)# err=#cfcatch.message#">
        <!--- Persist the handled exception as an error_tickets row (cf_context='handled') so it is
              visible without server log access. Never allowed to change this response. --->
        <cftry>
            <cfif structKeyExists(application, "services") AND structKeyExists(application.services, "errorService")>
                <cfset application.services.errorService.captureHandled(cfcatch, "master-unlink")>
            </cfif>
            <cfcatch type="any"></cfcatch>
        </cftry>
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
