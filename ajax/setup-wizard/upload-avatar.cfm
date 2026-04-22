<!---
    P11 Step 1: Avatar Upload
    POST endpoint. Auth + CSRF handled by ajax/Application.cfc.

    Mirrors /include/image_upload2.cfm: frontend posts a base64 data URL as
    `picturebase`, server decodes via imageReadBase64() and writes via cfimage.
    Delete-before-write forces the new file to inherit fresh NTFS ACLs from
    the parent directory (see project memory: cffile preserves NTFS ACL).
--->
<cfset userid = session.userid>

<cftry>

    <cfif NOT structKeyExists(form, "picturebase") OR NOT len(form.picturebase)>
        <cfcontent type="application/json; charset=utf-8" reset="true">
        <cfoutput>#serializeJSON({"success": false, "message": "No image data received."})#</cfoutput>
        <cfabort>
    </cfif>

    <cfset pictureImg = imageReadBase64(form.picturebase)>

    <cfset userMediaPath = application.baseMediaPath & "\users\" & userid>
    <cfif NOT directoryExists(userMediaPath)>
        <cfdirectory action="create" directory="#userMediaPath#" />
    </cfif>
    <cfset destFile = userMediaPath & "\avatar.jpg">

    <cftry>
        <cfif fileExists(destFile)>
            <cffile action="delete" file="#destFile#" />
        </cfif>
        <cfcatch type="any"></cfcatch>
    </cftry>

    <cfimage source="#pictureImg#"
             destination="#destFile#"
             overwrite="true"
             action="write">

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
