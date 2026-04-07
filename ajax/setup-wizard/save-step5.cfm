<!---
    P11 Step 5 Save: Relationship Reminders
    Enrolls contacts in Target/Maintenance systems using the canonical
    RelationshipService.startSystemForContact() -- no parallel enrollment path.
    Auth + CSRF handled by ajax/Application.cfc.
--->
<cfset userid = session.userid>

<cfparam name="form.enrollments" default="[]" />
<cfset enrollments = []>
<cftry>
    <cfset enrollments = deserializeJSON(form.enrollments)>
    <cfcatch><cfset enrollments = []></cfcatch>
</cftry>

<cfset contactsEnrolled = 0>
<cfset relService = request.svc("RelationshipService")>

<cftry>

    <!--- Each enrollment is self-transactional (startSystemForContact handles its own cftransaction).
          Do NOT wrap in an outer transaction to avoid nested transaction issues. --->
    <cfloop array="#enrollments#" index="enrollment">
        <cfset contactId = val(enrollment.contactId ?: 0)>
        <cfset systemId = val(enrollment.systemId ?: 0)>
        <cfif contactId EQ 0 OR systemId EQ 0><cfcontinue></cfif>

        <!--- Security: verify contact belongs to this user --->
        <cfquery name="qOwnership" datasource="#application.datasource#" maxrows="1">
            SELECT contactid FROM contactdetails
            WHERE contactid = <cfqueryparam value="#contactId#" cfsqltype="cf_sql_integer" />
              AND userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
        </cfquery>
        <cfif qOwnership.recordCount EQ 0><cfcontinue></cfif>

        <!--- Call canonical enrollment function --->
        <cfset result = relService.startSystemForContact(
            systemid = systemId,
            contactid = contactId,
            userid = userid
        )>

        <cfif result.success>
            <cfset contactsEnrolled++>
        </cfif>
        <!--- Duplicate enrollment returns success=false with message; skip silently --->
    </cfloop>

    <!--- Update wizard progress --->
    <cfquery datasource="#application.datasource#">
        UPDATE taousers_tbl SET setup_step = 5
        WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
    </cfquery>

    <cfset session.setup_step = 5>
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({
        "success": true,
        "message": contactsEnrolled & " contact(s) enrolled in reminders.",
        "data": {"contactsEnrolled": contactsEnrolled}
    })#</cfoutput>

<cfcatch type="any">
    <cflog file="TAO_setup_wizard" type="error"
           text="Step 5 save failed for user #userid#: #cfcatch.message# | #cfcatch.detail#" />
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({"success": false, "message": "Failed to set up reminders."})#</cfoutput>
</cfcatch>
</cftry>
