<!---
  POST /ajax/master/link-confirm.cfm   (DIR-LNK-WO-7)
  Confirm a master link/relink from the preview modal. Auth + CSRF enforced by /ajax/Application.cfc.
  The client sends IDS + the photo choice only; the service (confirmLink) re-derives every master
  value from the database. Idempotent.
  Params (form): contactid (int), masterCoContactId (int), colocid (int, optional),
                 photoChoice (user|master, optional -> 'user')
  Response JSON: { success, message, data, _build }
--->
<cfset buildTag = "wo7-link-confirm-2026-07-18-v1">
<cfcontent type="application/json" reset="true">

<cfparam name="form.contactid"         default="0">
<cfparam name="form.masterCoContactId" default="0">
<cfparam name="form.colocid"           default="0">
<cfparam name="form.photoChoice"       default="user">

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

    <!--- Only 'master' opts into the Book photo; anything else is treated as keep-user. --->
    <cfset photoChoice = (lCase(trim(form.photoChoice)) EQ "master") ? "master" : "user">

    <cfset svc = request.svc("MasterDirectoryService")>
    <cfset result = svc.confirmLink(
        contactid         = int(form.contactid),
        masterCoContactId = int(form.masterCoContactId),
        colocid           = val(form.colocid),
        photoChoice       = photoChoice,
        userid            = session.userid)>

    <cfset response.success = result.success>
    <cfset response.message = structKeyExists(result, "message") ? result.message : "">
    <cfif structKeyExists(result, "data")><cfset response.data = result.data></cfif>

    <cfcatch type="any">
        <cfset response.success = false>
        <cfset response.message = "Link failed.">
        <cflog file="master_link" type="error"
               text="link-confirm FAIL userid=#(structKeyExists(session,'userid') ? session.userid : 'na')# contactid=#left(form.contactid,20)# master=#left(form.masterCoContactId,20)# err=#cfcatch.message#">
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
