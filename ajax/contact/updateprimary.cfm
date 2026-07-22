<!---
  POST /ajax/contact/updateprimary.cfm   (DIR-LNK-WO-6 / TAO-MCD-P1)
  Edit ONE primary column (phone/email/company) on an UNLINKED contact.
  Auth + CSRF enforced by /ajax/Application.cfc.

  Enforcement lives in ContactService.updatePrimary(): a single conditional UPDATE keyed on
  contactid + userid + master_co_contact_id IS NULL. A linked contact, someone else's contact,
  or an oversized value is rejected server-side with zero writes. userid comes from the session
  ONLY - it is never accepted from the client, and there is no bypass parameter (the master
  path uses ContactService.update(), a separate trusted method).

  Params (form): contactid (int), field (contactPhone|contactEmail|contactCompany), value (string)
  Response JSON: { success, message, data, _build }
--->
<cfset buildTag = "wo6-updateprimary-2026-07-20-v2">
<cfcontent type="application/json" reset="true">

<cfparam name="form.contactid" default="0">
<cfparam name="form.field"     default="">
<cfparam name="form.value"     default="">

<!--- Strip recordname at the endpoint boundary (never let it reach the writer path).
      recordname is a VIRTUAL GENERATED column; writing it is a hard MySQL error. --->
<cfif structKeyExists(form, "recordname")><cfset structDelete(form, "recordname")></cfif>

<cfset response = { "success": false, "message": "", "data": {}, "_build": buildTag }>

<cftry>
    <cfif NOT isValid("integer", form.contactid) OR val(form.contactid) LTE 0>
        <cfset response.message = "Missing or invalid contactid.">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <cfset svc = request.svc("ContactService")>
    <cfset result = svc.updatePrimary(
        contactid = int(form.contactid),
        userid    = session.userid,
        field     = form.field,
        value     = form.value)>

    <cfset response.success = result.success>
    <cfset response.message = structKeyExists(result, "message") ? result.message : "">
    <cfif structKeyExists(result, "data")><cfset response.data = result.data></cfif>

    <cfcatch type="any">
        <cfset response.success = false>
        <cfset response.message = "Save failed.">
        <cflog file="wo6_primary" type="error"
               text="updatePrimary FAIL userid=#(structKeyExists(session,'userid') ? session.userid : 'na')# contactid=#left(form.contactid,20)# field=#left(form.field,30)# err=#cfcatch.message#">
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
