<cfsilent>
<!--- Quick diagnostic to test CSV parsing directly --->
<cfset response = {
    "success": false,
    "message": "",
    "data": {}
}>

<cftry>
    <!--- Get job_id from URL --->
    <cfparam name="url.job_id" default="0">
    <cfset jobId = val(url.job_id)>

    <cfif jobId lte 0>
        <cfset response.message = "job_id required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- Get job info --->
    <cfset qJob = queryExecute(
        "SELECT * FROM import_v3_jobs WHERE job_id = :job_id",
        { job_id: { value: jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>

    <cfif qJob.recordCount eq 0>
        <cfset response.message = "Job not found">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <cfset response.data.job = {
        "job_id": qJob.job_id,
        "status": qJob.status,
        "source_filename": qJob.source_filename,
        "file_type": qJob.file_type,
        "stored_file_path": qJob.stored_file_path,
        "total_rows": qJob.total_rows
    }>

    <!--- Check if file exists --->
    <cfset filePath = qJob.stored_file_path>
    <cfset response.data.file_exists = fileExists(filePath)>

    <cfif fileExists(filePath)>
        <!--- Try to read first few lines --->
        <cfset fileContent = fileRead(filePath, "utf-8")>
        <cfset response.data.file_size_bytes = len(fileContent)>

        <!--- Normalize line endings --->
        <cfset fileContent = replace(fileContent, chr(13) & chr(10), chr(10), "all")>
        <cfset fileContent = replace(fileContent, chr(13), chr(10), "all")>

        <!--- Split into lines --->
        <cfset lines = listToArray(fileContent, chr(10))>
        <cfset response.data.line_count = arrayLen(lines)>

        <!--- Show first 3 lines --->
        <cfset preview = []>
        <cfloop from="1" to="#min(3, arrayLen(lines))#" index="i">
            <cfset arrayAppend(preview, lines[i])>
        </cfloop>
        <cfset response.data.preview_lines = preview>

        <!--- Check rows table --->
        <cfset qRows = queryExecute(
            "SELECT COUNT(*) as cnt FROM import_v3_rows WHERE job_id = :job_id",
            { job_id: { value: jobId, cfsqltype: "cf_sql_integer" } },
            { datasource: application.datasource }
        )>
        <cfset response.data.rows_in_db = qRows.cnt>

        <!--- Check columns table --->
        <cfset qCols = queryExecute(
            "SELECT COUNT(*) as cnt FROM import_v3_columns WHERE job_id = :job_id",
            { job_id: { value: jobId, cfsqltype: "cf_sql_integer" } },
            { datasource: application.datasource }
        )>
        <cfset response.data.columns_in_db = qCols.cnt>
    </cfif>

    <cfset response.success = true>
    <cfset response.message = "Diagnostic complete">

    <cfcatch type="any">
        <cfset response.message = "Error: " & cfcatch.message>
        <cfset response.data.error_detail = cfcatch.detail>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
