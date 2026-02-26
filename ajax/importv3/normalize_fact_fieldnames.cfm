<cfsilent>
<!---
    Contact Import V3 - Normalize Fact Field Names (Admin Only)
    POST /ajax/importv3/normalize_fact_fieldnames.cfm?job_id=...

    Remediates legacy snake_case field_name values in import_v3_facts
    to the canonical camelCase convention for a single job.

    Mapping:
        first_name   -> firstName
        last_name    -> lastName
        full_name    -> contactFullName
        contact_type -> contactType

    Idempotent: re-running on an already-normalized job returns updated_count=0.
    Admin-only: requires session.isAdmin = true.
--->

<cfset variables.response = {
    "ok": false,
    "job_id": 0,
    "updated_count": 0,
    "message": ""
}>

<cftry>
    <!--- A) Auth: Require logged-in session --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset variables.response.message = "Authentication required">
        <cfheader statuscode="401">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <!--- B) Admin guard: Require session.isAdmin --->
    <cfif not isDefined("session.isAdmin") or session.isAdmin neq true>
        <cfset variables.response.message = "Administrator access required">
        <cfheader statuscode="403">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <!--- C) Read job_id --->
    <cfparam name="url.job_id" default="">
    <cfparam name="form.job_id" default="">

    <cfset variables.jobId = 0>
    <cfif isNumeric(url.job_id) and val(url.job_id) gt 0>
        <cfset variables.jobId = val(url.job_id)>
    <cfelseif isNumeric(form.job_id) and val(form.job_id) gt 0>
        <cfset variables.jobId = val(form.job_id)>
    </cfif>

    <cfif variables.jobId lte 0>
        <cfset variables.response.message = "job_id is required">
        <cfheader statuscode="400">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset variables.response.job_id = variables.jobId>

    <!--- D) Verify job exists --->
    <cfset variables.qJobCheck = queryExecute(
        "SELECT job_id FROM import_v3_jobs WHERE job_id = :job_id",
        { job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>
    <cfif variables.qJobCheck.recordCount eq 0>
        <cfset variables.response.message = "Job not found">
        <cfheader statuscode="404">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <!--- E) Normalize snake_case field_names to camelCase --->
    <cfset variables.mappings = [
        { "old": "first_name",   "new": "firstName" },
        { "old": "last_name",    "new": "lastName" },
        { "old": "full_name",    "new": "contactFullName" },
        { "old": "contact_type", "new": "contactType" }
    ]>

    <cfset variables.totalUpdated = 0>

    <cfloop array="#variables.mappings#" index="variables.m">
        <cfset variables.qUpdate = {}>
        <cfset queryExecute(
            "UPDATE import_v3_facts f
             INNER JOIN import_v3_rows r ON f.row_id = r.row_id
             SET f.field_name = :new_name, f.updated_at = NOW()
             WHERE r.job_id = :job_id
               AND f.field_name = :old_name",
            {
                job_id:   { value: variables.jobId,  cfsqltype: "cf_sql_integer" },
                old_name: { value: variables.m.old,  cfsqltype: "cf_sql_varchar" },
                new_name: { value: variables.m.new,  cfsqltype: "cf_sql_varchar" }
            },
            { datasource: application.datasource, result: "variables.qUpdate" }
        )>
        <cfset variables.totalUpdated += val(variables.qUpdate.recordCount)>
    </cfloop>

    <cflog file="importv3" text="[normalize_fact_fieldnames] admin=#session.userid# job_id=#variables.jobId# updated_count=#variables.totalUpdated#">

    <cfset variables.response.ok = true>
    <cfset variables.response.updated_count = variables.totalUpdated>
    <cfset variables.response.message = "Normalized #variables.totalUpdated# fact field names to camelCase">

    <cfcatch type="any">
        <cflog file="importv3" text="[normalize_fact_fieldnames] ERROR admin=#session.userid# job_id=#variables.jobId# err=#cfcatch.message#">
        <cfset variables.response.message = "Error: " & cfcatch.message>
        <cfheader statuscode="500">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
