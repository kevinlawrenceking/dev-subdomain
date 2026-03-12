<cfsilent>
<!---
    Audition Import - File Upload Endpoint
    POST /ajax/import-auditions/upload.cfm

    Accepts: multipart/form-data with 'file' field
    Returns: JSON envelope with job object or error code

    Response codes:
    - AUTH_REQUIRED: No session userid
    - DUPLICATE_FILE: Same file (by hash) already uploaded by this user
    - UPLOAD_FAILED: File upload or storage failed
    - INVALID_FILE_TYPE: File extension not in whitelist
    - FILE_TOO_LARGE: File exceeds 50MB limit
--->

<cfset variables.response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {}
}>
<cfset variables.startTick = getTickCount()>
<cfset variables.debug = ["start"]>
<cfset variables.userid = 0>
<cflog file="import_auditions" text="[upload] START">
<cftry>
    <!--- A) Auth: Require logged-in session userid --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset variables.response.code = "AUTH_REQUIRED">
        <cfset variables.response.message = "Authentication required">
        <cfset variables.response.data.debug = variables.debug>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset variables.userid = session.userid>
    <cfset arrayAppend(variables.debug, "auth_ok")>

    <!--- Validate file was uploaded --->
    <cfif not structKeyExists(form, "file") or not len(form.file)>
        <cfset variables.response.code = "UPLOAD_FAILED">
        <cfset variables.response.message = "No file uploaded">
        <cfset variables.response.data.debug = variables.debug>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset arrayAppend(variables.debug, "file_validated")>

    <!--- B) Set up upload directory --->
    <cfif structKeyExists(session, "userImportsPath") and len(session.userImportsPath)>
        <cfset variables.uploadDir = session.userImportsPath>
    <cfelse>
        <cfset variables.uploadDir = application.baseMediaPath & "\users\" & variables.userid & "\imports">
    </cfif>

    <!--- Create directory if needed --->
    <cfif not directoryExists(variables.uploadDir)>
        <cfdirectory directory="#variables.uploadDir#" action="create">
    </cfif>

    <!--- Upload file with type validation (CSV, XLS, XLSX only for auditions) --->
    <cftry>
        <cffile
            action="upload"
            filefield="form.file"
            destination="#variables.uploadDir#\"
            nameconflict="MAKEUNIQUE"
            accept=".csv,.xls,.xlsx,text/csv,text/plain,application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/octet-stream">
        <cfcatch type="any">
            <cfset variables.response.code = "UPLOAD_FAILED">
            <cfset variables.response.message = "File upload failed: " & cfcatch.message>
            <cflog file="import_auditions" text="[upload] ERROR upload failed userid=#variables.userid# message=#cfcatch.message#">
            <cfset variables.response.data.debug = variables.debug>
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
        </cfcatch>
    </cftry>
    <cfset arrayAppend(variables.debug, "file_uploaded")>
    <cflog file="import_auditions" text="[upload] FILE_UPLOADED userid=#variables.userid# file=#cffile.clientfile#">

    <!--- Get file info --->
    <cfset variables.uploadedFile = cffile.serverfile>
    <cfset variables.uploadedPath = variables.uploadDir & "\" & variables.uploadedFile>
    <cfset variables.originalFilename = cffile.clientfile>
    <cfset variables.fileInfo = getFileInfo(variables.uploadedPath)>
    <cfset variables.fileSize = variables.fileInfo.size>

    <!--- Validate file type by extension (no VCF for auditions) --->
    <cfset variables.fileExtension = lcase(listLast(variables.uploadedFile, "."))>
    <cfset variables.fileType = variables.fileExtension>

    <cfif not listFindNoCase("csv,xls,xlsx", variables.fileType)>
        <cffile action="delete" file="#variables.uploadedPath#">
        <cfset variables.response.code = "INVALID_FILE_TYPE">
        <cfset variables.response.message = "Invalid file type. Allowed: CSV, XLS, XLSX">
        <cflog file="import_auditions" text="[upload] ERROR invalid file type userid=#variables.userid# type=#variables.fileType#">
        <cfset variables.response.data.debug = variables.debug>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <!--- Validate file size (max 50MB) --->
    <cfif variables.fileSize gt 52428800>
        <cffile action="delete" file="#variables.uploadedPath#">
        <cfset variables.response.code = "FILE_TOO_LARGE">
        <cfset variables.response.message = "File too large. Maximum size is 50MB.">
        <cflog file="import_auditions" text="[upload] ERROR file too large userid=#variables.userid# size=#variables.fileSize#">
        <cfset variables.response.data.debug = variables.debug>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <!--- C) Compute SHA-256 hash --->
    <cfset variables.fileBytes = fileReadBinary(variables.uploadedPath)>
    <cfset variables.messageDigest = createObject("java", "java.security.MessageDigest").getInstance("SHA-256")>
    <cfset variables.hashBytes = variables.messageDigest.digest(variables.fileBytes)>
    <cfset variables.fileHash = "">
    <cfloop from="1" to="#arrayLen(variables.hashBytes)#" index="variables.i">
        <cfset variables.byteVal = variables.hashBytes[variables.i]>
        <cfif variables.byteVal lt 0>
            <cfset variables.byteVal = variables.byteVal + 256>
        </cfif>
        <cfset variables.fileHash = variables.fileHash & right("0" & formatBaseN(variables.byteVal, 16), 2)>
    </cfloop>
    <cfset variables.fileHash = lcase(variables.fileHash)>
    <cfset arrayAppend(variables.debug, "hash_computed")>

    <!--- Initialize service for logging --->
    <cfset variables.importService = new services.AuditionImportService()>

    <!--- Check for duplicate file (same user + same hash) --->
    <cfset variables.qExisting = queryExecute(
        "SELECT job_id, userid, source_filename, file_type, file_size, file_hash,
                stored_file_path, status, created_at, updated_at
         FROM import_auditions_jobs
         WHERE userid = :userid AND file_hash = :file_hash",
        {
            userid: { value: variables.userid, cfsqltype: "cf_sql_integer" },
            file_hash: { value: variables.fileHash, cfsqltype: "cf_sql_varchar", maxlength: 64 }
        },
        { datasource: application.datasource }
    )>
    <cfset arrayAppend(variables.debug, "dupe_checked")>

    <cfif variables.qExisting.recordCount gt 0>
        <!--- Duplicate file - delete newly uploaded file and return existing job --->
        <cffile action="delete" file="#variables.uploadedPath#">

        <cfset variables.importService.logEvent(
            job_id = variables.qExisting.job_id,
            userid = variables.userid,
            event_type = "duplicate_file",
            detail = { attempted_filename: variables.originalFilename }
        )>

        <cflog file="import_auditions" text="[upload] DUPLICATE userid=#variables.userid# existing_job_id=#variables.qExisting.job_id# hash=#variables.fileHash#">

        <cfset variables.response.success = true>
        <cfset variables.response.code = "DUPLICATE_FILE">
        <cfset variables.response.message = "This file has already been uploaded.">
        <cfset variables.response.data = {
            "job": {
                "job_id": variables.qExisting.job_id,
                "status": variables.qExisting.status,
                "file_hash": variables.qExisting.file_hash,
                "source_filename": variables.qExisting.source_filename,
                "file_size": variables.qExisting.file_size
            }
        }>
        <cfset variables.response.data.debug = variables.debug>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <!--- Insert new job with status = "uploaded" --->
    <cfset variables.qResult = {}>
    <cfset queryExecute(
        "INSERT INTO import_auditions_jobs (
            userid, source_filename, file_type, file_size, file_hash,
            stored_file_path, status, created_at, updated_at
        ) VALUES (
            :userid, :source_filename, :file_type, :file_size, :file_hash,
            :stored_file_path, 'uploaded', NOW(), NOW()
        )",
        {
            userid: { value: variables.userid, cfsqltype: "cf_sql_integer" },
            source_filename: { value: variables.originalFilename, cfsqltype: "cf_sql_varchar", maxlength: 255 },
            file_type: { value: variables.fileType, cfsqltype: "cf_sql_varchar", maxlength: 10 },
            file_size: { value: variables.fileSize, cfsqltype: "cf_sql_bigint" },
            file_hash: { value: variables.fileHash, cfsqltype: "cf_sql_varchar", maxlength: 64 },
            stored_file_path: { value: variables.uploadedPath, cfsqltype: "cf_sql_varchar", maxlength: 500 }
        },
        { datasource: application.datasource, result: "variables.qResult" }
    )>

    <cfset variables.newJobId = variables.qResult.generatedKey>
    <cfset arrayAppend(variables.debug, "job_created")>

    <!--- Log upload event --->
    <cfset variables.importService.logEvent(
        job_id = variables.newJobId,
        userid = variables.userid,
        event_type = "upload",
        detail = {
            source_filename: variables.originalFilename,
            file_type: variables.fileType,
            file_size: variables.fileSize,
            file_hash: variables.fileHash
        }
    )>

    <cflog file="import_auditions" text="[upload] SUCCESS userid=#variables.userid# job_id=#variables.newJobId# hash=#variables.fileHash# elapsed_ms=#getTickCount() - variables.startTick#">
    <cfset arrayAppend(variables.debug, "done")>

    <!--- Return success response --->
    <cfset variables.response.success = true>
    <cfset variables.response.code = "">
    <cfset variables.response.message = "File uploaded successfully">
    <cfset variables.response.data = {
        "job": {
            "job_id": variables.newJobId,
            "status": "uploaded",
            "file_hash": variables.fileHash,
            "source_filename": variables.originalFilename,
            "file_size": variables.fileSize
        },
        "elapsed_ms": getTickCount() - variables.startTick
    }>
    <cfset variables.response.data.debug = variables.debug>

    <cfcatch type="any">
        <cflog file="import_auditions" text="[upload] ERROR userid=#variables.userid# message=#cfcatch.message# detail=#cfcatch.detail#">
        <cfset arrayAppend(variables.debug, "exception")>
        <cfset variables.response.code = "UPLOAD_FAILED">
        <cfset variables.response.message = "Upload failed: " & cfcatch.message>
        <cfset variables.response.data.debug = variables.debug>
    </cfcatch>
</cftry>
</cfsilent>
<cfset variables.response.data.debug = variables.debug>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
