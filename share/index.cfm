<!---
    PURPOSE: Public entry point for shared contact views
    AUTHOR: GitHub Copilot
    DATE: 2025-10-19
    NOTES:
        * Relies on permanent shareID instead of legacy tokens
        * Keeps lightweight debug output when url.debug=YESf
        * Delegates data rendering to share.cfm
--->
<cfset dsn = "abod">
<cfset shareID = trim(url.shareID)>
<cfset baseMediaUrl  = "/media-" & dsn>
<cfset assetBase     = "/share/assets">
<cfset cacheBuster   = RandRange(1, 1000000)>

<!--- Basic guard: require a shareID value --->
<cfif NOT len(shareID)>
    <cfoutput><p>Missing shareID.</p></cfoutput>
    <cfabort>
</cfif>

<!--- Fetch the user tied to this shareID --->
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

<!--- Straightforward handling when no record exists --->
<cfif qShareUser.recordCount EQ 0>
    <cfoutput><p>No shared data found.</p></cfoutput>
    <cfabort>
</cfif>

<!--- Expose common variables for downstream templates --->
<cfset variables.new_userid     = qShareUser.userID>
<cfset variables.shareID        = qShareUser.shareID>
<cfset variables.userfirstname  = qShareUser.userFirstName>
<cfset variables.userlastname   = qShareUser.userLastName>
<cfset variables.recordname     = qShareUser.recordname>
<cfset variables.auditions      = true>
<cfset mediaBase                = baseMediaUrl>

<!DOCTYPE html>
<html lang="en">
<head>
    <cfoutput>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>#variables.recordname# | Shared Contacts</title>
    </cfoutput>

    <cfoutput>
        <link href="#assetBase#/icons.min.css?v=#cacheBuster#" rel="stylesheet" type="text/css">
        <link href="#assetBase#/bootstrap.css?v=#cacheBuster#" rel="stylesheet" type="text/css">
        <link href="#assetBase#/app.min.css?v=#cacheBuster#" rel="stylesheet" type="text/css">
        <link href="#assetBase#/datatables.min.css?v=#cacheBuster#" rel="stylesheet" type="text/css">
        <link href="#assetBase#/dataTables.checkboxes.css?v=#cacheBuster#" rel="stylesheet" type="text/css">
        <link href="#assetBase#/utilityclasses.css?v=#cacheBuster#" rel="stylesheet" type="text/css">
        <script src="#assetBase#/jquery-3.6.0.min.js?v=#cacheBuster#"></script>
        <script src="#assetBase#/bootstrap.bundle.js?v=#cacheBuster#"></script>
        <script src="#assetBase#/datatables.min.js?v=#cacheBuster#"></script>
        <script src="#assetBase#/dataTables.checkboxes.min.js?v=#cacheBuster#"></script>
        <script src="#assetBase#/app.min.js?v=#cacheBuster#"></script>
    </cfoutput>
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
</body>
</html>