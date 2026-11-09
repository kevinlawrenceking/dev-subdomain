<!---
  GET /ajax/master/locations.cfm   (DIR-WO-2 / TAO-MCD-P1)
  Offices for a master company. Read-only. Auth enforced by /ajax/Application.cfc.
  Params (url): coid (int)
  Response JSON: { success, message, data:[{colocid,location,address1,city,state}], _build }
--->
<cfset buildTag = "master-locations-2026-07-09-v1">
<cfcontent type="application/json" reset="true">
<cfinclude template="../../include/book_feature_guard.cfm"><!--- Book switch: FEATURE_DISABLED when off --->

<cfparam name="url.coid" default="">

<cfif structKeyExists(url, "recordname")><cfset structDelete(url, "recordname")></cfif>

<cfset response = { "success": true, "message": "", "data": [], "_build": buildTag }>

<cftry>
    <cfif NOT len(trim(url.coid)) OR NOT isValid("integer", url.coid)>
        <cfset response.data = []>
    <cfelse>
        <cfset svc = request.svc("MasterDirectoryService")>
        <cfset response.data = svc.getLocations(coid = int(url.coid))>
    </cfif>

    <cfcatch type="any">
        <cfset response.success = false>
        <cfset response.message = "Location lookup failed.">
        <cfset response.data = []>
        <cflog file="master_link" type="error"
               text="locations FAIL userid=#(structKeyExists(session,'userid') ? session.userid : 'na')# coid=#left(url.coid,20)# err=#cfcatch.message#">
        <!--- Persist the handled exception as an error_tickets row (cf_context='handled') so it is
              visible without server log access. Never allowed to change this response. --->
        <cftry>
            <cfif structKeyExists(application, "services") AND structKeyExists(application.services, "errorService")>
                <cfset application.services.errorService.captureHandled(cfcatch, "master-locations")>
            </cfif>
            <cfcatch type="any"></cfcatch>
        </cftry>
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
