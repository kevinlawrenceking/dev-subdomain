<!--- This ColdFusion page processes an uploaded image, saves it, and sends diagnostic information via email. --->

<cfset pictureImg = imageReadBase64(form.picturebase)>

<!--- Delete existing file first so the new write inherits fresh ACLs from
      the parent directory. Without this, cfimage overwrite preserves the
      destination's existing NTFS ACL -- if it's restrictive, IIS returns
      401.3 when the browser later tries to display the image (upload
      "succeeds" but displays as empty). --->
<cftry>
    <cfif fileExists(cookie.uploadDir)>
        <cffile action="delete" file="#cookie.uploadDir#" />
    </cfif>
    <cfcatch type="any"></cfcatch>
</cftry>

<!--- Save the image to the specified directory --->
<cfimage
    source="#pictureImg#"
    destination="#cookie.uploadDir#"
    overwrite="true"
    action="write">

<!--- Capture diagnostic information for email --->
<cfoutput>
    <cfsavecontent variable="diagnostics">
        <cfif isdefined('pgid')>
            pgid: #pgid#<br />
        </cfif>
        <cfif isdefined('ref_pgid')>
            ref_pgid: #ref_pgid#<br />
        </cfif>
        <cfif isdefined('userid')>
            userid: #userid#<br />
        </cfif>
        <cfif isdefined('cookie.uploadDir')>
            cookie.uploadDir: #cookie.uploadDir#<br />
        </cfif>
        <cfif isdefined('cookie.return_url')>
            cookie.return_url: #cookie.return_url#<br />
        </cfif>
        <cfif isdefined('browser_contact_avatar_loc')>
            browser_contact_avatar_loc: #browser_contact_avatar_loc#<br />
        </cfif>
        <cfif isdefined('image_url')>
            image_url: #image_url#<br />
        </cfif>
    </cfsavecontent>
</cfoutput>

<!--- Send diagnostic information via email --->
<cfmail from="support@theactorsoffice.com" 
        to="kevinking7135@gmail.com" 
        subject="#cookie.uploaddir#" 
        type="HTML">
    <p>#diagnostics#</p>
</cfmail>
