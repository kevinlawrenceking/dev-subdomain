<!---
  GET /ajax/master/search.cfm   (DIR-WO-2 / TAO-MCD-P1)
  Master-directory people search for the contact link autocomplete.
  Read-only. Auth enforced by /ajax/Application.cfc. No CSRF (GET).
  Params (url): term (string, >=2), limit (int, 1-25, default 10)
  Response JSON: { success, message, data:[{master_co_contact_id,fullname,jobtitle_type,coid,coName}], _build }
--->
<cfset buildTag = "master-search-2026-07-09-v1">
<cfcontent type="application/json" reset="true">
<cfinclude template="/include/book_feature_guard.cfm"><!--- Book switch: FEATURE_DISABLED when off --->

<cfparam name="url.term"  default="">
<cfparam name="url.limit" default="10">

<!--- Strip recordname defensively at the endpoint boundary --->
<cfif structKeyExists(url, "recordname")><cfset structDelete(url, "recordname")></cfif>

<!--- Pure probe when no term supplied --->
<cfif NOT len(trim(url.term))>
    <cfoutput>#serializeJSON({ "success": true, "probe": true, "data": [], "_build": buildTag })#</cfoutput>
    <cfabort>
</cfif>

<cfset response = { "success": true, "message": "", "data": [], "_build": buildTag }>

<cftry>
    <cfset svc = request.svc("MasterDirectoryService")>
    <cfset response.data = svc.searchPeople(term = trim(url.term), limit = url.limit)>

    <cfcatch type="any">
        <cfset response.success = false>
        <cfset response.message = "Search failed.">
        <cfset response.data = []>
        <cflog file="master_link" type="error"
               text="search FAIL userid=#(structKeyExists(session,'userid') ? session.userid : 'na')# term=#left(url.term,40)# err=#cfcatch.message#">
        <!--- Persist the handled exception as an error_tickets row (cf_context='handled') so it is
              visible without server log access. Never allowed to change this response. --->
        <cftry>
            <cfif structKeyExists(application, "services") AND structKeyExists(application.services, "errorService")>
                <cfset application.services.errorService.captureHandled(cfcatch, "master-search")>
            </cfif>
            <cfcatch type="any"></cfcatch>
        </cftry>
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
