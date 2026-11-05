<!---
  POST /include/delete_audcontact.cfm   (ticket 2751)
  Remove one contact from one audition project. Called by confirmRemove() in include/aud_rel_pane.cfm.
  CSRF is enforced by include/Application.cfc (X-CSRF-Token header). userid comes from the session
  only; ownership of the project is re-asserted inside ContactItemService.deleteAudContact().
  Params (form): contactid (int), audprojectid (int)
  Response JSON: { success, message, data }
--->
<cfcontent type="application/json" reset="true">
<cfset response = { "success": false, "message": "", "data": {} }>

<cfif NOT structKeyExists(session, "userid") OR NOT isValid("integer", session.userid)>
    <cfheader statuscode="401">
    <cfset response.message = "Your session expired. Please reload and sign in again.">
    <cfoutput>#serializeJSON(response)#</cfoutput>
    <cfabort>
</cfif>

<cfparam name="form.contactid" default="">
<cfparam name="form.audprojectid" default="">

<cftry>
    <cfif NOT isValid("integer", form.contactid) OR val(form.contactid) LTE 0
          OR NOT isValid("integer", form.audprojectid) OR val(form.audprojectid) LTE 0>
        <cfset response.message = "Missing or invalid contact or audition.">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <cfset contactItemService = createObject("component", "services.ContactItemService")>
    <cfset rows = contactItemService.deleteAudContact(
        contactid    = int(form.contactid),
        audprojectid = int(form.audprojectid),
        userid       = int(session.userid))>

    <!--- 0 rows = already removed or not this user's audition. Either way the contact is not on
          this audition for this user, so the UI removal is correct and a double-submit is a no-op. --->
    <cfset response.success = true>
    <cfset response.message = "Contact removed from this audition.">
    <cfset response.data = { "contactid": int(form.contactid), "audprojectid": int(form.audprojectid), "rows": rows }>

    <cfcatch type="any">
        <cfset response.success = false>
        <cfset response.message = "Unable to remove this contact. Please try again.">
        <cflog file="tao_audcontact" type="error"
               text="deleteAudContact FAIL userid=#session.userid# contactid=#left(form.contactid,20)# audprojectid=#left(form.audprojectid,20)# err=#cfcatch.message# #cfcatch.detail#">
        <!--- Persist the handled exception as an error_tickets row (cf_context='handled') so it is
              visible without server log access. Never allowed to change this response. --->
        <cftry>
            <cfif structKeyExists(application, "services") AND structKeyExists(application.services, "errorService")>
                <cfset application.services.errorService.captureHandled(cfcatch, "delete-audcontact")>
            </cfif>
            <cfcatch type="any"></cfcatch>
        </cftry>
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
