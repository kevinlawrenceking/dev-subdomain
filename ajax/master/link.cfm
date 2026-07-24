<!---
  POST /ajax/master/link.cfm   (DIR-WO-2 / TAO-MCD-P1)  -- RETIRED at DIR-LNK-WO-7 (P6 tidy).
  This legacy endpoint drove MasterDirectoryService.linkContactToMaster, which bypasses the entire
  WO-7 link flow: NO preservation of displaced user values, NO email/phone office snapshot, and NO
  master_audit_tbl rows -- a data-integrity bypass that stayed reachable by a direct POST even after
  the UI stopped calling it (the live link flow is the preview modal -> POST /ajax/master/link-confirm.cfm).
  Neutralized here to a guarded rejection (fix-batch #6): the service is NOT invoked; any hit is a stale
  client or a direct probe and is logged. The method + this file are deleted in WO-11 cleanup.
  Auth + CSRF remain enforced by /ajax/Application.cfc; this template only rejects.
  Response JSON: { success:false, message, data, _build }
--->
<cfset buildTag = "master-link-RETIRED-2026-07-23-v2">
<cfcontent type="application/json" reset="true">

<cfset response = { "success": false, "message": "This action is no longer available.", "data": {}, "_build": buildTag }>

<cflog file="master_link" type="warning"
       text="link.cfm RETIRED endpoint hit userid=#(structKeyExists(session,'userid') ? session.userid : 'na')# contactid=#left((structKeyExists(form,'contactid') ? form.contactid : ''),20)# master=#left((structKeyExists(form,'masterCoContactId') ? form.masterCoContactId : ''),20)#">

<cfoutput>#serializeJSON(response)#</cfoutput>
