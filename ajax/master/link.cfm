<!---
  POST /ajax/master/link.cfm   (DIR-WO-2 / TAO-MCD-P1)
  Link a TAO contact to a master person. Auth + CSRF enforced by /ajax/Application.cfc.
  Params (form): contactid (int), masterCoContactId (int), coid (int, optional),
                 colocid (int, optional)
  Response JSON: { success, message, data, _build }
--->
<cfset buildTag = "master-link-2026-07-09-v1">
<cfcontent type="application/json" reset="true">

<cfparam name="form.contactid"         default="0">
<cfparam name="form.masterCoContactId" default="0">
<cfparam name="form.coid"              default="0">
<cfparam name="form.colocid"           default="0">

<!--- Strip recordname at the endpoint boundary (never let it reach the writer path) --->
<cfif structKeyExists(form, "recordname")><cfset structDelete(form, "recordname")></cfif>

<cfset response = { "success": false, "message": "", "data": {}, "_build": buildTag }>

<cftry>
    <cfif NOT isValid("integer", form.contactid) OR val(form.contactid) LTE 0
          OR NOT isValid("integer", form.masterCoContactId) OR val(form.masterCoContactId) LTE 0>
        <cfset response.message = "Missing or invalid contactid / masterCoContactId.">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <cfset svc = request.svc("MasterDirectoryService")>
    <cfset result = svc.linkContactToMaster(
        contactid         = int(form.contactid),
        masterCoContactId = int(form.masterCoContactId),
        coid              = val(form.coid),
        colocid           = val(form.colocid),
        userid            = session.userid)>

    <cfset response.success = result.success>
    <cfset response.message = structKeyExists(result, "message") ? result.message : "">
    <cfif structKeyExists(result, "data")><cfset response.data = result.data></cfif>

    <cfcatch type="any">
        <cfset response.success = false>
        <cfset response.message = "Link failed.">
        <cflog file="master_link" type="error"
               text="link FAIL userid=#(structKeyExists(session,'userid') ? session.userid : 'na')# contactid=#left(form.contactid,20)# master=#left(form.masterCoContactId,20)# err=#cfcatch.message#">
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
