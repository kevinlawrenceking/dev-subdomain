<cfsilent>
<!---
    Contact Import V2 - Dry Run Endpoint
    POST /ajax/import/dry-run.cfm

    Returns: JSON with preview of what will be imported
    Purpose: Show user a summary before executing the actual import
--->

<cfset response = {
    success: false,
    job_id: 0,
    summary: {
        will_import: 0,
        will_skip: 0,
        will_update: 0,
        problems_remaining: 0,
        dupes_unresolved: 0
    },
    preview: [],
    warnings: [],
    message: ""
}>

<cftry>
    <!--- Validate user session --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid)>
        <cfset response.message = "Authentication required">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    <cfset userid = session.userid>

    <!--- Get job_id from request --->
    <cfset requestData = {}>
    <cfif structKeyExists(form, "job_id")>
        <cfset requestData.job_id = form.job_id>
    <cfelseif getHttpRequestData().method eq "POST" and len(getHttpRequestData().content)>
        <cftry>
            <cfset requestData = deserializeJSON(getHttpRequestData().content)>
            <cfcatch>
                <cfset response.message = "Invalid JSON request body">
                <cfoutput>#serializeJSON(response)#</cfoutput>
                <cfabort>
            </cfcatch>
        </cftry>
    </cfif>

    <cfif not structKeyExists(requestData, "job_id") or not isNumeric(requestData.job_id)>
        <cfset response.message = "job_id is required">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <cfset job_id = val(requestData.job_id)>
    <cfset response.job_id = job_id>

    <!--- Get import service --->
    <cfset importService = new services.ContactImportV2Service()>

    <!--- Verify job exists and belongs to user --->
    <cfset job = importService.getJob(job_id)>

    <cfif not job.found>
        <cfset response.message = "Import job not found">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <cfif job.userid neq userid>
        <cfset response.message = "Access denied">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Check job status --->
    <cfif job.status eq "completed">
        <cfset response.message = "This import has already been completed">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Count rows by status and action --->
    <cfquery name="qCounts">
        SELECT
            status,
            user_action,
            COUNT(*) AS cnt
        FROM import_job_rows
        WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#job_id#">
        GROUP BY status, user_action
    </cfquery>

    <cfset willImport = 0>
    <cfset willSkip = 0>
    <cfset willUpdate = 0>
    <cfset problemsRemaining = 0>
    <cfset dupesUnresolved = 0>

    <cfloop query="qCounts">
        <cfswitch expression="#qCounts.status#">
            <cfcase value="ready">
                <cfset willImport += qCounts.cnt>
            </cfcase>
            <cfcase value="problem">
                <cfset problemsRemaining += qCounts.cnt>
            </cfcase>
            <cfcase value="dupe">
                <cfif qCounts.user_action eq "import_new">
                    <cfset willImport += qCounts.cnt>
                <cfelseif qCounts.user_action eq "update_existing">
                    <cfset willUpdate += qCounts.cnt>
                <cfelseif qCounts.user_action eq "skip">
                    <cfset willSkip += qCounts.cnt>
                <cfelse>
                    <cfset dupesUnresolved += qCounts.cnt>
                </cfif>
            </cfcase>
            <cfcase value="ignored">
                <cfset willSkip += qCounts.cnt>
            </cfcase>
        </cfswitch>
    </cfloop>

    <cfset response.summary.will_import = willImport>
    <cfset response.summary.will_skip = willSkip>
    <cfset response.summary.will_update = willUpdate>
    <cfset response.summary.problems_remaining = problemsRemaining>
    <cfset response.summary.dupes_unresolved = dupesUnresolved>

    <!--- Get preview of contacts to import (first 20) --->
    <cfquery name="qPreview">
        SELECT
            row_id,
            row_num,
            normalized_json,
            status,
            user_action,
            matched_contactid
        FROM import_job_rows
        WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#job_id#">
          AND (
              (status = 'ready')
              OR (status = 'dupe' AND user_action IN ('import_new', 'update_existing'))
          )
        ORDER BY row_num
        LIMIT 20
    </cfquery>

    <cfset preview = []>
    <cfloop query="qPreview">
        <cfset rowData = len(qPreview.normalized_json) ? deserializeJSON(qPreview.normalized_json) : {}>

        <!--- Build display name --->
        <cfset displayName = "">
        <cfif structKeyExists(rowData, "contactFullName") and len(rowData.contactFullName)>
            <cfset displayName = rowData.contactFullName>
        <cfelseif structKeyExists(rowData, "firstName") or structKeyExists(rowData, "lastName")>
            <cfset displayName = trim((structKeyExists(rowData, "firstName") ? rowData.firstName : "") & " " & (structKeyExists(rowData, "lastName") ? rowData.lastName : ""))>
        </cfif>

        <!--- Get email for display --->
        <cfset displayEmail = "">
        <cfif structKeyExists(rowData, "email_business") and len(rowData.email_business)>
            <cfset displayEmail = rowData.email_business>
        <cfelseif structKeyExists(rowData, "email_personal") and len(rowData.email_personal)>
            <cfset displayEmail = rowData.email_personal>
        </cfif>

        <!--- Get company for display --->
        <cfset displayCompany = structKeyExists(rowData, "company") ? rowData.company : "">

        <!--- Determine action label --->
        <cfset actionLabel = "Create new contact">
        <cfif qPreview.user_action eq "update_existing">
            <cfset actionLabel = "Update existing contact">
        </cfif>

        <cfset arrayAppend(preview, {
            row_num: qPreview.row_num,
            name: displayName,
            email: displayEmail,
            company: displayCompany,
            action: actionLabel
        })>
    </cfloop>

    <cfset response.preview = preview>

    <!--- Add warnings --->
    <cfif problemsRemaining gt 0>
        <cfset arrayAppend(response.warnings, problemsRemaining & " row(s) have validation errors and will not be imported")>
    </cfif>
    <cfif dupesUnresolved gt 0>
        <cfset arrayAppend(response.warnings, dupesUnresolved & " duplicate row(s) need action selection before import")>
    </cfif>
    <cfif willImport + willUpdate eq 0>
        <cfset arrayAppend(response.warnings, "No contacts ready to import")>
    </cfif>

    <!--- Check relationship_system field --->
    <cfquery name="qRelSystem">
        SELECT COUNT(*) AS cnt
        FROM import_job_rows r
        WHERE r.job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#job_id#">
          AND r.normalized_json LIKE '%relationship_system%'
          AND r.status IN ('ready', 'dupe')
    </cfquery>
    <cfif qRelSystem.cnt gt 0>
        <cfset arrayAppend(response.warnings, qRelSystem.cnt & " contact(s) have relationship system enrollment specified")>
    </cfif>

    <cfset response.success = true>
    <cfset response.message = "Dry run completed successfully">

    <cfcatch type="any">
        <cfset response.message = "Dry run failed: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
