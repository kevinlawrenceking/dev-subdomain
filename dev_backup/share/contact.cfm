<!---
    PURPOSE: Individual contact detail page for share portal
    AUTHOR: GitHub Copilot
    DATE: 2025-10-19
    NOTES: Full-page view with header and back button
--->
<cfset dsn = "abod">
<cfset shareID = trim(url.shareID)>
<cfset contactID = val(url.contactID)>
<cfset baseMediaUrl  = "/media-" & dsn>
<cfset assetBase     = "/share/assets">
<cfset cacheBuster   = RandRange(1, 1000000)>

<!--- Basic guard: require shareID and contactID --->
<cfif NOT len(shareID) OR contactID EQ 0>
    <cfoutput><p>Invalid request.</p></cfoutput>
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

<cfif qShareUser.recordCount EQ 0>
    <cfoutput><p>No shared data found.</p></cfoutput>
    <cfabort>
</cfif>

<!--- Expose common variables --->
<cfset variables.new_userid     = qShareUser.userID>
<cfset variables.shareID        = qShareUser.shareID>
<cfset variables.userfirstname  = qShareUser.userFirstName>
<cfset variables.userlastname   = qShareUser.userLastName>
<cfset variables.recordname     = qShareUser.recordname>
<cfset mediaBase                = baseMediaUrl>

<!DOCTYPE html>
<html lang="en">
<head>
    <cfoutput>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>Contact Details | #variables.recordname#</title>
    </cfoutput>

    <cfoutput>
        <link href="#assetBase#/icons.min.css?v=#cacheBuster#" rel="stylesheet" type="text/css">
        <link href="#assetBase#/bootstrap.css?v=#cacheBuster#" rel="stylesheet" type="text/css">
        <link href="#assetBase#/app.min.css?v=#cacheBuster#" rel="stylesheet" type="text/css">
        <link href="#assetBase#/utilityclasses.css?v=#cacheBuster#" rel="stylesheet" type="text/css">
        <script src="#assetBase#/jquery-3.6.0.min.js?v=#cacheBuster#"></script>
        <script src="#assetBase#/bootstrap.bundle.js?v=#cacheBuster#"></script>
        <script src="#assetBase#/app.min.js?v=#cacheBuster#"></script>
    </cfoutput>
    <style>
        body {
            font-family: 'Inter', 'Segoe UI', sans-serif;
            background-color: #f4f7fb;
            color: #24313f;
            min-height: 100vh;
        }

        #share-header {
            background: linear-gradient(135deg, #355a75 0%, #406E8E 60%, #4a87af 100%);
            color: #fff;
            padding: 1.75rem 1.5rem;
            margin-bottom: 1rem;
            box-shadow: 0 12px 30px rgba(26, 52, 71, 0.28);
            border-bottom-left-radius: 18px;
            border-bottom-right-radius: 18px;
        }

        #share-header .logo img {
            height: 24px;
            width: auto;
        }

        #share-header .header-inner {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 1.75rem;
            flex-wrap: wrap;
        }

        #share-header .header-title {
            font-size: 2.25rem;
            letter-spacing: 0.02em;
            margin-bottom: 0.2rem;
            color: rgba(255, 255, 255, 0.94);
        }

        #share-header .header-meta {
            opacity: 0.9;
            font-size: 1rem;
        }

        #share-header .header-text {
            margin-left: 0.75rem;
        }

        #share-header .header-actions {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        #share-header .back-btn {
            background: rgba(255,255,255,0.18);
            color: #fff;
            border: 1px solid rgba(255,255,255,0.35);
            padding: 0.55rem 1.1rem;
            border-radius: 999px;
            font-weight: 600;
            text-decoration: none;
        }

        #share-header .back-btn:hover {
            background: rgba(255,255,255,0.28);
            color: #fff;
            text-decoration: none;
        }

        #share-header .header-avatar img {
            width: 72px;
            height: 72px;
            border-radius: 50%;
            border: 3px solid rgba(255,255,255,0.4);
            object-fit: cover;
            box-shadow: 0 10px 25px rgba(13, 35, 52, 0.45);
        }

        main.container-fluid {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 1.5rem 3rem;
        }

        .content-card {
            background: #fff;
            border-radius: 18px;
            box-shadow: 0 22px 48px rgba(39, 70, 98, 0.16);
            padding: 2.5rem 2.75rem 2rem;
        }

        .badge-primary {
            background-color: #406E8E !important;
            color: #fff !important;
            border: 1px solid #406E8E !important;
        }

        .btn-primary,
        .btn-outline-primary:hover {
            background-color: #406E8E !important;
            border-color: #406E8E !important;
        }

        .text-primary,
        .btn-outline-primary {
            color: #406E8E !important;
            border-color: #406E8E !important;
        }

        .btn-outline-primary {
            color: #406E8E !important;
        }
    </style>
</head>
<body>
    <div class="container-fluid px-0">
        <header id="share-header">
            <div class="header-inner">
                <div class="d-flex align-items-center">
                    <div class="logo mr-4">
                        <cfoutput>
                            <img src="#mediaBase#/images/logo-light.png" alt="The Actor's Office">
                        </cfoutput>
                    </div>
                    <div class="header-text">
                        <cfoutput>
                            <h1 class="header-title mb-0">#variables.recordname#</h1>
                            <p class="header-meta mb-0">
                                Contact Details
                            </p>
                        </cfoutput>
                    </div>
                </div>
                <div class="header-actions">
                    <cfoutput>
                        <a href="index.cfm?shareID=#URLEncodedFormat(variables.shareID)#" class="back-btn">
                            <i class="fe-arrow-left mr-2"></i>Back to List
                        </a>
                        <div class="header-avatar">
                            <img src="#mediaBase#/users/#variables.new_userid#/avatar.jpg?ver=#RandRange(1, 1000000)#" alt="#HTMLEditFormat(variables.recordname)#" onerror="this.src='#mediaBase#/images/default-avatar.png';">
                        </div>
                    </cfoutput>
                </div>
            </div>
        </header>

        <main class="container-fluid">
            <div class="content-card">
                <cfinclude template="share_contact_details.cfm">
            </div>
        </main>
    </div>
</body>
</html>
