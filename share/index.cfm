<!---
    PURPOSE: Public entry point for shared contact views
    AUTHOR: GitHub Copilot
    DATE: 2025-10-19
    NOTES:
        * Relies on permanent shareID instead of legacy tokens
        * Keeps lightweight debug output when url.debug=YES
        * Delegates data rendering to share.cfm
--->

<cfparam name="url.shareID" default="">
<cfparam name="url.debug" default="">

<cfset variables.debug = (url.debug EQ "YES") ? "YES" : "NO">
<cfset shareID = trim(url.shareID)>

<!--- Load common settings (DSN, asset lists, etc.) --->
<cfinclude template="remote_load_common.cfm">

<!--- Validate that a shareID was provided --->
<cfif NOT len(shareID)>
    <cfinclude template="invalid_token.cfm">
    <cfabort>
</cfif>

<!--- Look up the shared user by shareID --->
<cfquery name="qShareUser" datasource="#dsn#" maxrows="1">
    SELECT
        tu.userID,
        tu.shareID,
        tu.userFirstName,
        tu.userLastName,
        tu.recordname
    FROM taousers tu
    WHERE tu.shareID = <cfqueryparam value="#shareID#" cfsqltype="cf_sql_varchar" maxlength="36">
    LIMIT 1
</cfquery>

<!--- Abort with invalid notice if not found --->
<cfif qShareUser.recordCount EQ 0>
    <cfinclude template="invalid_token.cfm">
    <cfabort>
</cfif>

<!--- Expose common variables for downstream templates --->
<cfset variables.new_userid     = qShareUser.userID>
<cfset variables.shareID        = qShareUser.shareID>
<cfset variables.userfirstname  = qShareUser.userFirstName>
<cfset variables.userlastname   = qShareUser.userLastName>
<cfset variables.recordname     = qShareUser.recordname>
<cfset variables.auditions      = true>
<cfset mediaBase                = application.baseMediaUrl>

<!--- Optional debug output --->
<cfif variables.debug EQ "YES">
    <div class="debug-info info" style="background:#eef5ff;padding:1rem;margin:1rem 0;border:1px solid #99bdf2;">
        <h3 style="margin-top:0;">Share Debug</h3>
        <ul style="margin:0;">
            <li><strong>shareID:</strong> <cfoutput>#shareID#</cfoutput></li>
            <li><strong>User ID:</strong> <cfoutput>#variables.new_userid#</cfoutput></li>
            <li><strong>Viewer:</strong> <cfoutput>#variables.userfirstname# #variables.userlastname#</cfoutput></li>
        </ul>
        <cfif isDefined("application")>
            <p style="margin:0.75rem 0 0;">
                <strong>DSN:</strong> <cfoutput>#application.dsn#</cfoutput>
                &middot;
                <strong>Media Base:</strong> <cfoutput>#mediaBase#</cfoutput>
            </p>
        </cfif>
    </div>
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
    <cfoutput>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>#appname# | Shared Contacts</title>
    </cfoutput>

    <link href="./icons.min.css" rel="stylesheet" type="text/css">

    <!--- Top-of-page assets from remote_load_common.cfm --->
    <cfif isDefined("FindLinksT") AND isQuery(FindLinksT)>
        <cfloop query="FindLinksT">
            <cfoutput>
                <cfif FindLinksT.linktype EQ "script">
                    <script src="#FindLinksT.linkurl#?v=#application.rev#"></script>
                <cfelseif FindLinksT.linktype EQ "script_include">
                    <script>
                        <cfinclude template="#FindLinksT.linkurl#?rev=#RandRange(1,1000000)#">
                    </script>
                <cfelseif FindLinksT.linktype EQ "css" OR FindLinksT.linktype EQ "text/css" OR FindLinksT.linktype EQ "ico">
                    <link href="#FindLinksT.linkurl#?v=#application.rev#"
                          type="text/css"
                          <cfif len(trim(FindLinksT.rel))>rel="#FindLinksT.rel#"</cfif>
                          <cfif len(trim(FindLinksT.hrefid))>id="#FindLinksT.hrefid#"</cfif>>
                </cfif>
            </cfoutput>
        </cfloop>
    <cfelse>
        <!--- Fallback essentials if asset query unavailable --->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/js/bootstrap.bundle.min.js"></script>
    </cfif>

    <style>
        body.loading {
            display: flex;
            justify-content: center;
            align-items: center;
            width: 100%;
            height: 100vh;
            position: fixed;
            top: 0;
            left: 0;
            background: rgba(255,255,255,0.85);
            z-index: 9999;
        }

        #share-header {
            background-color: ##406E8E;
            color: #fff;
            padding: 1.5rem 1rem;
            margin-bottom: 1rem;
        }

        #share-header .logo img {
            height: 32px;
            width: auto;
        }

        .badge-primary {
            background-color: ##406E8E !important;
            color: #fff !important;
            border: 1px solid ##406E8E !important;
        }

        .btn-primary,
        .btn-outline-primary:hover {
            background-color: ##406E8E !important;
            border-color: ##406E8E !important;
        }

        .text-primary,
        .btn-outline-primary {
            color: ##406E8E !important;
            border-color: ##406E8E !important;
        }
    </style>
</head>
<body class="loading">
    <div class="container-fluid px-0">
        <header id="share-header">
            <div class="d-flex align-items-center">
                <div class="logo mr-3">
                    <cfoutput>
                        <img src="#mediaBase#/images/logo-light.png" alt="The Actor's Office">
                    </cfoutput>
                </div>
                <div>
                    <h1 class="h4 mb-1">Shared Contacts</h1>
                    <cfoutput>
                        <p class="mb-0">#variables.userfirstname# #variables.userlastname#</p>
                    </cfoutput>
                </div>
            </div>
        </header>

        <main class="container-fluid">
            <cfinclude template="share.cfm">
        </main>
    </div>

    <!--- Footer assets --->
    <cfif isDefined("FindLinksB") AND isQuery(FindLinksB)>
        <cfloop query="FindLinksB">
            <cfoutput>
                <cfif FindLinksB.linktype EQ "script">
                    <script src="#FindLinksB.linkurl#?v=#application.rev#"></script>
                <cfelseif FindLinksB.linktype EQ "script_include">
                    <script>
                        <cfinclude template="#FindLinksB.linkurl#?rev=#RandRange(1,1000000)#">
                    </script>
                <cfelseif FindLinksB.linktype EQ "css" OR FindLinksB.linktype EQ "text/css" OR FindLinksB.linktype EQ "ico">
                    <link href="#FindLinksB.linkurl#?v=#application.rev#"
                          type="text/css"
                          <cfif len(trim(FindLinksB.rel))>rel="#FindLinksB.rel#"</cfif>
                          <cfif len(trim(FindLinksB.hrefid))>id="#FindLinksB.hrefid#"</cfif>>
                </cfif>
            </cfoutput>
        </cfloop>
    </cfif>
</body>
</html>