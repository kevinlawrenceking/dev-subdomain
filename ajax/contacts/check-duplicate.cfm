<!---
  POST /ajax/contacts/check-duplicate.cfm
  Pre-submit duplicate check for the "add a contact" flows. Read-only: looks up
  the current user's existing contacts that match the name/email/phone being
  entered, so the UI can warn before a duplicate is created.

  Reuses services/DuplicateMatcherService (the same scored matcher the V3 importer
  uses). Fail-open by design: any error returns hasDuplicate=false so adding a
  contact is never blocked by this check.

  Auth + CSRF are enforced by /ajax/Application.cfc (X-CSRF-Token header, which
  core.cfm auto-injects on jQuery non-GET requests).

  Request body (application/x-www-form-urlencoded):
    contactFullName = string (required)
    email           = string (optional)
    phone           = string (optional)
  Response JSON: { success, hasDuplicate, candidates:[{contactid,name,recordname,score,reasons}] }
--->
<cfset buildTag = "contact-dupecheck-2026-06-25-v1">

<cfcontent type="application/json" reset="true">

<cfif cgi.REQUEST_METHOD EQ "GET">
    <cfoutput>#serializeJSON({ "success": true, "probe": true, "_build": buildTag })#</cfoutput>
    <cfabort>
</cfif>

<cfparam name="form.contactFullName" default="" />
<cfparam name="form.email"           default="" />
<cfparam name="form.phone"           default="" />

<cfset response = { "success": true, "hasDuplicate": false, "candidates": [], "_build": buildTag } />

<cftry>
    <cfif len(trim(form.contactFullName)) OR len(trim(form.email)) OR len(trim(form.phone))>
        <cfset rowData = {
            "contactFullName": trim(form.contactFullName),
            "email_business":  trim(form.email),
            "phone_work":      trim(form.phone)
        } />

        <cfset matcher = request.svc("DuplicateMatcherService") />
        <cfset dupe = matcher.findDuplicatesSafe(userid = session.userid, rowData = rowData) />

        <cfset response.hasDuplicate = dupe.hasDuplicate />
        <cfif structKeyExists(dupe, "candidates")>
            <cfloop array="#dupe.candidates#" index="cand">
                <cfset arrayAppend(response.candidates, {
                    "contactid":  cand.contactid,
                    "name":       cand.contactFullName,
                    "recordname": structKeyExists(cand, "recordname") ? cand.recordname : "",
                    "score":      cand.score,
                    "reasons":    structKeyExists(cand, "reasons") ? cand.reasons : []
                }) />
            </cfloop>
        </cfif>
    </cfif>

    <cfcatch type="any">
        <!--- Fail open: never block contact creation on a check error --->
        <cfset response.hasDuplicate = false />
        <cfset response.candidates = [] />
        <cflog file="contact_dupecheck" type="error"
               text="check-duplicate FAIL userid=#(structKeyExists(session,'userid') ? session.userid : 'na')# err=#cfcatch.message#" />
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
