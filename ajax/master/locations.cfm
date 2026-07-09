<!---
  GET /ajax/master/locations.cfm   (DIR-WO-2 / TAO-MCD-P1)
  Offices for a master company. Read-only. Auth enforced by /ajax/Application.cfc.
  Params (url): coid (int)
  Response JSON: { success, message, data:[{colocid,location,address1,city,state}], _build }
--->
<cfset buildTag = "master-locations-2026-07-09-v1">
<cfcontent type="application/json" reset="true">

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
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
