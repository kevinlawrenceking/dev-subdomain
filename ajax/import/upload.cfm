<cfsilent>
<!---
    Contact Import V2 - File Upload Endpoint
    POST /ajax/import/upload.cfm

    Accepts: multipart/form-data with 'file' field
    Returns: JSON with job_id or error
--->

<cfset response = {
    success: false,
    job_id: 0,
    filename: "",
    file_type: "",
    file_size: 0,
    file_hash: "",
    is_duplicate_file: false,
    existing_job: {},
    message: "",
    debug_step: "",
    debug_path: ""
}>

<cftry>
    <cfset response.debug_step = "init">
    <!--- Validate user session --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid)>
        <cfset response.message = "Authentication required">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    <cfset userid = session.userid>

    <!--- Check if file was uploaded --->
    <cfif not structKeyExists(form, "file") or not len(form.file)>
        <cfset response.message = "No file uploaded">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <cfset response.debug_step = "setup_dir">
    <!--- Set up upload directory using session path from Application.cfc --->
    <cfif structKeyExists(session, "userImportsPath") and len(session.userImportsPath)>
        <cfset uploadDir = session.userImportsPath>
    <cfelse>
        <!--- Fallback: construct path using application settings --->
        <cfset uploadDir = application.baseMediaPath & "\users\" & userid & "\imports">
    </cfif>

    <cfset response.debug_step = "create_dir">
    <cfset response.debug_path = uploadDir>
    <!--- Create directory if needed --->
    <cfif not directoryExists(uploadDir)>
        <cfdirectory directory="#uploadDir#" action="create">
    </cfif>

    <cfset response.debug_step = "upload_file">
    <!--- Upload file --->
    <cffile
        action="upload"
        filefield="form.file"
        destination="#uploadDir#\"
        nameconflict="MAKEUNIQUE"
        accept=".csv,.xls,.xlsx,.vcf,text/csv,text/plain,text/vcard,text/x-vcard,application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">

    <!--- Get file info --->
    <cfset uploadedFile = cffile.serverfile>
    <cfset uploadedPath = uploadDir & "\" & uploadedFile>
    <cfset fileInfo = getFileInfo(uploadedPath)>
    <cfset fileSize = fileInfo.size>

    <!--- Determine file type --->
    <cfset fileExtension = lcase(listLast(uploadedFile, "."))>
    <cfset fileType = fileExtension>

    <!--- Validate file type --->
    <cfif not listFindNoCase("csv,xls,xlsx,vcf", fileType)>
        <!--- Delete invalid file --->
        <cffile action="delete" file="#uploadedPath#">
        <cfset response.message = "Invalid file type. Please upload CSV, XLS, XLSX, or VCF files.">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Validate file size (max 50MB) --->
    <cfif fileSize gt 52428800>
        <cffile action="delete" file="#uploadedPath#">
        <cfset response.message = "File too large. Maximum size is 50MB.">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <cfset response.debug_step = "init_service">
    <!--- Compute file hash for idempotency --->
    <cfset importService = new services.ContactImportV2Service()>

    <cfset response.debug_step = "compute_hash">
    <cfset fileHash = importService.computeFileHash(uploadedPath)>

    <cfset response.debug_step = "create_job">
    <!--- Create import job --->
    <cftry>
    <cfset jobResult = importService.createJob(
        userid = userid,
        filename = cffile.clientfile,
        filetype = fileType,
        filesize = fileSize,
        storedFilePath = uploadedPath,
        fileHash = fileHash,
        options = {}
    )>
    <cfcatch type="any">
        <cfset response.message = "createJob error: " & cfcatch.message>
        <cfif structKeyExists(cfcatch, "detail") and len(cfcatch.detail)>
            <cfset response.message &= " | " & cfcatch.detail>
        </cfif>
        <cfif structKeyExists(cfcatch, "sql") and len(cfcatch.sql)>
            <cfset response.message &= " | SQL: " & cfcatch.sql>
        </cfif>
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfcatch>
    </cftry>

    <cfif not jobResult.success>
        <cfset response.message = jobResult.message>
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Return success --->
    <cfset response.success = true>
    <cfset response.job_id = jobResult.job_id>
    <cfset response.filename = cffile.clientfile>
    <cfset response.file_type = fileType>
    <cfset response.file_size = fileSize>
    <cfset response.file_hash = fileHash>
    <cfset response.is_duplicate_file = jobResult.isDuplicateFile>
    <cfif jobResult.isDuplicateFile>
        <cfset response.existing_job = jobResult.existingJob>
        <cfset response.message = jobResult.message>
    <cfelse>
        <cfset response.message = "File uploaded successfully">
    </cfif>

    <cfcatch type="any">
        <cfset response.message = "Upload failed at step [" & response.debug_step & "]: " & cfcatch.message>
        <cfif len(cfcatch.detail)>
            <cfset response.message = response.message & " | Detail: " & cfcatch.detail>
        </cfif>
        <cfif structKeyExists(cfcatch, "sql") and len(cfcatch.sql)>
            <cfset response.message = response.message & " | SQL: " & left(cfcatch.sql, 200)>
        </cfif>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
