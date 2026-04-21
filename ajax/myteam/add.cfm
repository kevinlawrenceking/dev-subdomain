<!---
  POST /ajax/myteam/add.cfm
  Adds a contact to the current user's "My Team" tag.
  Auth + CSRF are enforced by /ajax/Application.cfc (X-CSRF-Token header).
  Request body (application/x-www-form-urlencoded):
    contactid = numeric
  Response: JSON { success, message, contactid, added, _build }
--->
<cfset buildTag = "myteam-add-2026-04-21-v1">

<cfif cgi.REQUEST_METHOD EQ "GET">
    <!--- GET probe for deploy verification; does not write anything. --->
    <cfcontent type="application/json" reset="true">
    <cfoutput>#serializeJSON({"success":true,"probe":true,"_build":buildTag})#</cfoutput>
    <cfabort>
</cfif>

<cfcontent type="application/json" reset="true">
<cfparam name="form.contactid" type="integer">

<cfquery name="qOwn">
    SELECT contactid
    FROM contactdetails
    WHERE contactid = <cfqueryparam value="#form.contactid#" cfsqltype="CF_SQL_INTEGER">
      AND userid    = <cfqueryparam value="#session.userid#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfif qOwn.recordcount EQ 0>
    <cfheader statuscode="404">
    <cfoutput>#serializeJSON({"success":false,"message":"Contact not found.","_build":buildTag})#</cfoutput>
    <cfabort>
</cfif>

<cfset contactService = request.svc("ContactService")>
<cfset added = contactService.addMemberById(userid=session.userid, contactid=form.contactid)>

<cfoutput>#serializeJSON({
    "success": true,
    "contactid": form.contactid,
    "added": added,
    "message": added ? "Team member added." : "Contact is already on your team.",
    "_build": buildTag
})#</cfoutput>
