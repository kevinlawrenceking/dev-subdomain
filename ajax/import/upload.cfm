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
    message: ""
}>

<cftry>
    <!--- Validate user session --->
    <cfif not isDefined("userid") or not isNumeric(userid)>
        <cfset response.message = "Authentication required">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Check if file was uploaded --->
    <cfif not structKeyExists(form, "file") or not len(form.file)>
        <cfset response.message = "No file uploaded">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Set up upload directory --->
    <cfset currentURL = cgi.server_name>
    <cfset host = ListFirst(currentURL, ".")>
    <cfset uploadDir = "C:\home\theactorsoffice.com\wwwroot\" & host & "-subdomain\media-" & host & "\users\" & userid & "\imports">

    <!--- Create directory if needed --->
    <cfif not directoryExists(uploadDir)>
        <cfdirectory directory="#uploadDir#" action="create">
    </cfif>

    <!--- Upload file --->
    <cffile
        action="upload"
        filefield="form.file"
        destination="#uploadDir#\"
        nameconflict="MAKEUNIQUE"
        accept=".csv,.xls,.xlsx,.vcf,text/csv,text/vcard,text/x-vcard,application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">

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

    <!--- Compute file hash for idempotency --->
    <cfset importService = new services.ContactImportV2Service()>
    <cfset fileHash = importService.computeFileHash(uploadedPath)>

    <!--- Create import job --->
    <cfset jobResult = importService.createJob(
        userid = userid,
        filename = cffile.clientfile,
        filetype = fileType,
        filesize = fileSize,
        storedFilePath = uploadedPath,
        fileHash = fileHash,
        options = {}
    )>

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
        <cfset response.message = "Upload failed: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
