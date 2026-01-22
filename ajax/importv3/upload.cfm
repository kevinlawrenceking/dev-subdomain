<cfsilent>
<!---
    Contact Import V3 - File Upload Endpoint
    POST /ajax/importv3/upload.cfm

    Accepts: multipart/form-data with 'file' field
    Returns: JSON envelope with job object or error code

    Response codes:
    - AUTH_REQUIRED: No session userid
    - DUPLICATE_FILE: Same file (by hash) already uploaded by this user
    - UPLOAD_FAILED: File upload or storage failed
    - INVALID_FILE_TYPE: File extension not in whitelist
    - FILE_TOO_LARGE: File exceeds 50MB limit
--->

<cfset response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {}
}>
<cftry>
    <!--- A) Auth: Require logged-in session userid --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset response.code = "AUTH_REQUIRED">
        <cfset response.message = "Authentication required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset userid = session.userid>

    <!--- Validate file was uploaded --->
    <cfif not structKeyExists(form, "file") or not len(form.file)>
        <cfset response.code = "UPLOAD_FAILED">
        <cfset response.message = "No file uploaded">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- B) Set up upload directory using session path from Application.cfc --->
    <cfif structKeyExists(session, "userImportsPath") and len(session.userImportsPath)>
        <cfset uploadDir = session.userImportsPath>
    <cfelse>
        <!--- Fallback: construct path using application settings --->
        <cfset uploadDir = application.baseMediaPath & "\users\" & userid & "\imports">
    </cfif>

    <!--- Create directory if needed --->
    <cfif not directoryExists(uploadDir)>
        <cfdirectory directory="#uploadDir#" action="create">
    </cfif>

    <!--- Upload file with type validation --->
    <cftry>
        <cffile
            action="upload"
            filefield="form.file"
            destination="#uploadDir#\"
            nameconflict="MAKEUNIQUE"
            accept=".csv,.xls,.xlsx,.vcf,text/csv,text/plain,text/vcard,text/x-vcard,application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/octet-stream">
        <cfcatch type="any">
            <cfset response.code = "UPLOAD_FAILED">
            <cfset response.message = "File upload failed: " & cfcatch.message>
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
        </cfcatch>
    </cftry>

    <!--- Get file info --->
    <cfset uploadedFile = cffile.serverfile>
    <cfset uploadedPath = uploadDir & "\" & uploadedFile>
    <cfset originalFilename = cffile.clientfile>
    <cfset fileInfo = getFileInfo(uploadedPath)>
    <cfset fileSize = fileInfo.size>

    <!--- Validate file type by extension --->
    <cfset fileExtension = lcase(listLast(uploadedFile, "."))>
    <cfset fileType = fileExtension>

    <cfif not listFindNoCase("csv,xls,xlsx,vcf", fileType)>
        <!--- Delete invalid file --->
        <cffile action="delete" file="#uploadedPath#">
        <cfset response.code = "INVALID_FILE_TYPE">
        <cfset response.message = "Invalid file type. Allowed: CSV, XLS, XLSX, VCF">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- Validate file size (max 50MB) --->
    <cfif fileSize gt 52428800>
        <cffile action="delete" file="#uploadedPath#">
        <cfset response.code = "FILE_TOO_LARGE">
        <cfset response.message = "File too large. Maximum size is 50MB.">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- C) Compute SHA-256 hash using Java MessageDigest --->
    <cfset fileBytes = fileReadBinary(uploadedPath)>
    <cfset messageDigest = createObject("java", "java.security.MessageDigest").getInstance("SHA-256")>
    <cfset hashBytes = messageDigest.digest(fileBytes)>
    <!--- Convert bytes to hex string --->
    <cfset fileHash = "">
    <cfloop from="1" to="#arrayLen(hashBytes)#" index="i">
        <cfset byteVal = hashBytes[i]>
        <cfif byteVal lt 0>
            <cfset byteVal = byteVal + 256>
        </cfif>
        <cfset fileHash = fileHash & right("0" & formatBaseN(byteVal, 16), 2)>
    </cfloop>
    <cfset fileHash = lcase(fileHash)>

    <!--- Initialize V3 service for logging --->
    <cfset v3Service = new services.ContactImportV3Service()>

    <!--- Check for duplicate file (same user + same hash) --->
    <cfset qExisting = queryExecute(
        "SELECT job_id, userid, source_filename, file_type, file_size, file_hash,
                stored_file_path, status, created_at, updated_at
         FROM import_v3_jobs
         WHERE userid = :userid AND file_hash = :file_hash",
        {
            userid: { value: userid, cfsqltype: "cf_sql_integer" },
            file_hash: { value: fileHash, cfsqltype: "cf_sql_varchar", maxlength: 64 }
        },
        { datasource: application.datasource }
    )>

    <cfif qExisting.recordCount gt 0>
        <!--- Duplicate file - delete newly uploaded file and return existing job --->
        <cffile action="delete" file="#uploadedPath#">

        <!--- Log duplicate event --->
        <cfset v3Service.logEvent(
            job_id = qExisting.job_id,
            userid = userid,
            event_type = "duplicate_file",
            detail = { attempted_filename: originalFilename }
        )>

        <!--- Return success with DUPLICATE_FILE code and existing job --->
        <cfset response.success = true>
        <cfset response.code = "DUPLICATE_FILE">
        <cfset response.message = "This file has already been uploaded.">
        <cfset response.data = {
            "job": {
                "job_id": qExisting.job_id,
                "status": qExisting.status,
                "file_hash": qExisting.file_hash,
                "source_filename": qExisting.source_filename,
                "file_size": qExisting.file_size
            }
        }>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- Insert new job with status = "uploaded" --->
    <cfset qResult = {}>
    <cfset queryExecute(
        "INSERT INTO import_v3_jobs (
            userid, source_filename, file_type, file_size, file_hash,
            stored_file_path, status, created_at, updated_at
        ) VALUES (
            :userid, :source_filename, :file_type, :file_size, :file_hash,
            :stored_file_path, 'uploaded', NOW(), NOW()
        )",
        {
            userid: { value: userid, cfsqltype: "cf_sql_integer" },
            source_filename: { value: originalFilename, cfsqltype: "cf_sql_varchar", maxlength: 255 },
            file_type: { value: fileType, cfsqltype: "cf_sql_varchar", maxlength: 10 },
            file_size: { value: fileSize, cfsqltype: "cf_sql_bigint" },
            file_hash: { value: fileHash, cfsqltype: "cf_sql_varchar", maxlength: 64 },
            stored_file_path: { value: uploadedPath, cfsqltype: "cf_sql_varchar", maxlength: 500 }
        },
        { datasource: application.datasource, result: "qResult" }
    )>

    <cfset newJobId = qResult.generatedKey>

    <!--- E) Log upload event --->
    <cfset v3Service.logEvent(
        job_id = newJobId,
        userid = userid,
        event_type = "upload",
        detail = {
            source_filename: originalFilename,
            file_type: fileType,
            file_size: fileSize,
            file_hash: fileHash
        }
    )>

    <!--- D) Return success response --->
    <cfset response.success = true>
    <cfset response.code = "">
    <cfset response.message = "File uploaded successfully">
    <cfset response.data = {
        "job": {
            "job_id": newJobId,
            "status": "uploaded",
            "file_hash": fileHash,
            "source_filename": originalFilename,
            "file_size": fileSize
        }
    }>

    <cfcatch type="any">
        <cfset response.code = "UPLOAD_FAILED">
        <cfset response.message = "Upload failed: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
