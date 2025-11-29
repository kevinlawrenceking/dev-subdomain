<!---
    PURPOSE: Handle confirmed import after user previews
    PHASE: 1 - Contact Import Upgrade
    DATE: 2025-11-26
--->

<cfparam name="form.uploadid" default="0">

<!--- Verify we have a pending import in session --->
<cfif NOT structKeyExists(session, "pendingImport") OR form.uploadid NEQ session.pendingImport.uploadid>
    <cfoutput>
        <div class="alert alert-danger">
            <h4>Import Session Expired</h4>
            <p>Your import session has expired or is invalid. Please upload your file again.</p>
            <a href="/app/contacts-import/" class="btn btn-primary">Return to Import</a>
        </div>
    </cfoutput>
    <cfabort>
</cfif>

<!--- User confirmed, proceed with normal import process --->
<!--- Redirect back to the standard processing flow --->
<cfset session.skipPreview = true>
<cflocation url="/app/contacts-import/?uploadid=#form.uploadid#" addtoken="false">
