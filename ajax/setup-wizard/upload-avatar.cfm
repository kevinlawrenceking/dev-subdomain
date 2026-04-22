<!---
    P11 Step 1: Avatar Upload
    POST endpoint. Accepts JPEG/PNG, max 5MB.
    Auth + CSRF handled by ajax/Application.cfc.

    TECH-DEBT: Diagnostic fields (uploadedBytes, savedBytes, destFile, errorAt)
    are temporary -- there to surface "success but empty image" in dev. Once the
    root cause is fixed, strip them from the JSON response.
--->
<cfset userid = session.userid>

<cftry>

    <!--- Validate file was uploaded --->
    <cfif NOT structKeyExists(form, "avatar") OR NOT len(form.avatar)>
        <cfcontent type="application/json; charset=utf-8" reset="true">
        <cfoutput>#serializeJSON({"success": false, "message": "No file uploaded."})#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Upload to temp location with type validation --->
    <cffile action="upload"
            fileField="avatar"
            destination="#getTempDirectory()#"
            nameConflict="makeUnique"
            accept="image/jpeg,image/png,image/jpg"
            result="uploadResult" />

    <!--- Guard against 0-byte / truncated uploads. A real JPEG is always
          more than ~100 bytes; anything below that is Croppie returning an
          empty blob or a proxy stripping the body. Fail loudly so the UI
          doesn't show "success" for a broken image. --->
    <cfif uploadResult.fileSize LT 512>
        <cffile action="delete" file="#uploadResult.serverDirectory#/#uploadResult.serverFile#" />
        <cflog file="TAO_setup_wizard" type="error"
               text="Avatar upload too small for user #userid#: received #uploadResult.fileSize# bytes (expected real JPEG/PNG)." />
        <cfcontent type="application/json; charset=utf-8" reset="true">
        <cfoutput>#serializeJSON({
            "success": false,
            "message": "Uploaded image was empty or corrupted. Please try a different photo.",
            "uploadedBytes": uploadResult.fileSize,
            "contentType": uploadResult.contentType ?: ""
        })#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Validate file size (5MB max) --->
    <cfif uploadResult.fileSize GT (5 * 1024 * 1024)>
        <cffile action="delete" file="#uploadResult.serverDirectory#/#uploadResult.serverFile#" />
        <cfcontent type="application/json; charset=utf-8" reset="true">
        <cfoutput>#serializeJSON({"success": false, "message": "Image must be under 5MB."})#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Determine destination path --->
    <cfset userMediaPath = application.baseMediaPath & "\users\" & userid>

    <!--- Ensure directory exists --->
    <cfif NOT directoryExists(userMediaPath)>
        <cfdirectory action="create" directory="#userMediaPath#" />
    </cfif>

    <cfset destFile = userMediaPath & "\avatar.jpg">

    <!--- IMPORTANT: cffile action="move" with overwrite PRESERVES the
          destination's existing NTFS ACL on Windows. If a prior write put
          a restrictive ACL on avatar.jpg, IIS anonymous user gets 401.3
          when the browser later requests the image (upload "succeeds" but
          displays as empty). Deleting first forces the new file to inherit
          fresh ACLs from the parent directory, which is what we want. --->
    <cftry>
        <cfif fileExists(destFile)>
            <cffile action="delete" file="#destFile#" />
        </cfif>
        <cfcatch type="any">
            <cflog file="TAO_setup_wizard" type="warning"
                   text="Could not delete existing avatar for user #userid#: #cfcatch.message# (continuing with move)" />
        </cfcatch>
    </cftry>

    <!--- Move uploaded file to user media directory as avatar.jpg --->
    <cffile action="move"
            source="#uploadResult.serverDirectory#/#uploadResult.serverFile#"
            destination="#destFile#"
            nameConflict="overwrite" />

    <!--- Verify the saved file is real before celebrating. --->
    <cfset savedBytes = fileExists(destFile) ? getFileInfo(destFile).size : 0>
    <cfif savedBytes LT 512>
        <cflog file="TAO_setup_wizard" type="error"
               text="Avatar move left empty file for user #userid#: destFile=#destFile# savedBytes=#savedBytes#" />
        <cfcontent type="application/json; charset=utf-8" reset="true">
        <cfoutput>#serializeJSON({
            "success": false,
            "message": "Upload saved an empty file. Please try again.",
            "uploadedBytes": uploadResult.fileSize,
            "savedBytes": savedBytes,
            "destFile": destFile
        })#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Update avatarname in DB --->
    <cfquery datasource="#application.datasource#">
        UPDATE taousers_tbl
        SET avatarName = <cfqueryparam value="#userid#" cfsqltype="cf_sql_varchar" />
        WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
    </cfquery>

    <cfset session.bustUserCache = true>

    <cfset avatarUrl = application.baseMediaUrl & "/users/" & userid & "/avatar.jpg">

    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({
        "success": true,
        "message": "Avatar uploaded.",
        "avatarUrl": avatarUrl,
        "uploadedBytes": uploadResult.fileSize,
        "savedBytes": savedBytes
    })#</cfoutput>

<cfcatch type="any">
    <cfset ctxFile = "">
    <cfset ctxLine = "">
    <cfif isArray(cfcatch.tagContext) AND arrayLen(cfcatch.tagContext)>
        <cfset ctxFile = cfcatch.tagContext[1].template>
        <cfset ctxLine = cfcatch.tagContext[1].line>
    </cfif>
    <cflog file="TAO_setup_wizard" type="error"
           text="Avatar upload failed for user #userid# type=#cfcatch.type# msg=#cfcatch.message# detail=#cfcatch.detail# at=#ctxFile#:#ctxLine#" />
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({
        "success": false,
        "message": "Upload failed. Please try a different image.",
        "errorType": cfcatch.type,
        "errorMessage": cfcatch.message,
        "errorDetail": cfcatch.detail,
        "errorAt": ctxFile & ":" & ctxLine
    })#</cfoutput>
</cfcatch>
</cftry>
