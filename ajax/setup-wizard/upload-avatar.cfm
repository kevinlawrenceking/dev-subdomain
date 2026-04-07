<!---
    P11 Step 1: Avatar Upload
    POST endpoint. Accepts JPEG/PNG, max 5MB.
    Auth + CSRF handled by ajax/Application.cfc.
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

    <!--- Move uploaded file to user media directory as avatar.jpg --->
    <cffile action="move"
            source="#uploadResult.serverDirectory#/#uploadResult.serverFile#"
            destination="#destFile#"
            nameConflict="overwrite" />

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
        "avatarUrl": avatarUrl
    })#</cfoutput>

<cfcatch type="any">
    <cflog file="TAO_setup_wizard" type="error"
           text="Avatar upload failed for user #userid#: #cfcatch.message#" />
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({"success": false, "message": "Upload failed. Please try a different image."})#</cfoutput>
</cfcatch>
</cftry>
