<!---<!---

    PURPOSE: Public entry point for shared contact views    PURPOSE: Public entry point for shared contact views

    AUTHOR: GitHub Copilot    AUTHOR: GitHub Copilot

    DATE: 2025-10-19    DATE: 2025-10-19

    NOTES: Simplified to rely on a permanent shareID    NOTES: Simplified to rely on a permanent shareID

--->--->

<cfparam name="url.shareID" default=""><cfset debug = "YES">

<cfparam name="url.debug" default=""><cfparam name="url.shareToken" default="706C2C9EBECE60DA9F779903AC3FFE79">

<cfset variables.debug = (url.debug EQ "YES") ? "YES" : "NO"><cfparam name="url.u" default="">  <!--- Keep legacy parameter for backward compatibility --->

<cfset shareID = trim(url.shareID)><cfparam name="url.uid" default=""> <!--- Original legacy parameter --->

<cfinclude template="remote_load_common.cfm">

<cffunction name="debugDump" returntype="void" output="true">

<cfif NOT len(shareID)>    <cfargument name="label" type="string" required="true">

    <cfinclude template="invalid_token.cfm">    <cfargument name="value" required="true">

    <cfabort>    <cfif variables.debug IS "YES">

</cfif>        <cfdump var="#arguments.value#" label="#arguments.label#">

        <hr>

<cfquery name="qShareUser" datasource="#dsn#" maxrows="1">    </cfif>

    SELECT</cffunction>

        tu.userid,<!--- Ensure application variables are set --->

        tu.shareID,    <cfif variables.debug IS "YES"><cfoutput><p class="alert alert-danger debug-info-sm">Application DSN not found, initializing...</p></cfoutput></cfif>

        tu.userfirstname,    <cfset onApplicationStart()>

        tu.userlastname,</cfif>

        tu.recordname

    FROM taousers tu<!--- Debug URL parameters --->

    WHERE tu.shareID = <cfqueryparam value="#shareID#" cfsqltype="cf_sql_varchar" maxlength="36"><cfif variables.debug IS "YES">

    LIMIT 1    <div class="debug-info info">

</cfquery>        <h3>URL Parameters</h3>

        <cfoutput>

<cfif qShareUser.recordCount EQ 0>            <ul>

    <cfinclude template="invalid_token.cfm">                <li><strong>shareToken:</strong> #structKeyExists(url, "shareToken") ? url.shareToken : "Not provided"#</li>

    <cfabort>                <li><strong>u:</strong> #url.u#</li>

</cfif>                <li><strong>uid:</strong> #url.uid#</li>

            </ul>

<cfset variables.new_userid = qShareUser.userid>        </cfoutput>

<cfset variables.shareID = qShareUser.shareID>        

<cfset variables.userfirstname = qShareUser.userfirstname>        <h3>Application Settings</h3>

<cfset variables.userlastname = qShareUser.userlastname>        <cfdump var="#application#" label="Application Scope" expand="false">

<cfset variables.recordname = qShareUser.recordname>    </div>

<cfset variables.auditions = true></cfif>

<cfset mediaBase = "/media-" & dsn>

<!--- Handle new shareToken system --->

<cfif variables.debug EQ "YES"><cfif structKeyExists(url, "shareToken") AND len(trim(url.shareToken)) GT 0>

    <cfdump var="#qShareUser#" label="Share User" expand="false">    <cfif variables.debug IS "YES">

</cfif>        <div class="debug-info success">

            <h3>Using New Token System</h3>

<!DOCTYPE html>            <p>Token: <cfoutput>#url.shareToken#</cfoutput></p>

<html lang="en">        </div>

<head>    </cfif>

    <cfoutput>   

        <meta charset="utf-8">   

        <meta name="viewport" content="width=device-width, initial-scale=1.0"></cfif>

        <meta http-equiv="X-UA-Compatible" content="IE=edge">

        <title>#appname# | Shared Contacts</title><!--- Legacy system handling --->

    </cfoutput><cfif len(trim(url.u)) GT 0 OR len(trim(url.uid)) GT 0>

    <link href="./icons.min.css" rel="stylesheet" type="text/css" />    <cfset session.userid = 0>

    <cfparam name="variables.refresh_yn" default="N">

    <cfif isDefined("FindLinksT") AND isQuery(FindLinksT)>    <cfparam name="variables.NEW_USERID" default="0">

        <cfloop query="FindLinksT">    <cfset variables.legacy_token = len(trim(url.u)) GT 0 ? url.u : url.uid>

            <cfoutput>    

                <cfif FindLinksT.linktype EQ "script">    <cfif variables.debug IS "YES">

                    <script src="#FindLinksT.linkurl#"></script>        <div class="debug-info warning">

                <cfelseif FindLinksT.linktype EQ "script_include">            <h3>Using Legacy Token System</h3>

                    <script>            <p>Legacy token: <cfoutput>#variables.legacy_token#</cfoutput></p>

                        <cfinclude template="#FindLinksT.linkurl#?rev=#RandRange(1,1000000)#">            <p>Token source: <cfoutput>#len(trim(url.u)) GT 0 ? "u parameter" : "uid parameter"#</cfoutput></p>

                    </script>            <p>Token length: <cfoutput>#len(variables.legacy_token)#</cfoutput></p>

                <cfelseif FindLinksT.linktype EQ "css" OR FindLinksT.linktype EQ "text/css" OR FindLinksT.linktype EQ "ico">        </div>

                    <link href="#FindLinksT.linkurl#?rev=#RandRange(1,1000000)#"    </cfif>

                          <cfif len(trim(FindLinksT.rel))>rel="#FindLinksT.rel#"</cfif>    <cfparam name="url.debug" default="">

                          type="text/css"    <cfparam name="url.shareID" default="">

                          <cfif len(trim(FindLinksT.hrefid))>id="#FindLinksT.hrefid#"</cfif>>    <cfset debug = (url.debug EQ "YES") ? "YES" : "NO">

                </cfif>    <cfset shareID = trim(url.shareID)>

            </cfoutput>    <cfset variables.debug = debug>

        </cfloop>

    <cfelse>    <cfinclude template="remote_load_common.cfm">

        <link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css" rel="stylesheet" type="text/css" />

        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>    <cfif NOT len(shareID)>

        <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/js/bootstrap.bundle.min.js"></script>        <cfinclude template="invalid_token.cfm">

    </cfelse>        <cfabort>

    </cfif>

    <style>

        body.loading {    <cfquery name="qShareUser" datasource="#dsn#" maxrows="1">

            display: flex;        SELECT

            justify-content: center;            tu.userid,

            align-items: center;            tu.shareID,

            width: 100%;            tu.userfirstname,

            height: 100vh;            tu.userlastname,

            position: fixed;            tu.recordname

            top: 0;        FROM taousers tu

            left: 0;        WHERE tu.shareID = <cfqueryparam value="#shareID#" cfsqltype="cf_sql_varchar" maxlength="36">

            background: rgba(255,255,255,0.85);    </cfquery>

            z-index: 9999;

        }    <cfif qShareUser.recordCount EQ 0>

        <cfinclude template="invalid_token.cfm">

        #share-header {        <cfabort>

            background-color: #406E8E;    </cfif>

            color: #fff;

            padding: 1.5rem 1rem;    <cfset variables.new_userid = qShareUser.userid>

            margin-bottom: 1rem;    <cfset variables.shareID = qShareUser.shareID>

        }    <cfset variables.userfirstname = qShareUser.userfirstname>

    <cfset variables.userlastname = qShareUser.userlastname>

        #share-header .logo img {    <cfset variables.recordname = qShareUser.recordname>

            height: 32px;    <cfset variables.auditions = true>

            width: auto;

        }    <cfif debug EQ "YES">

        <cfdump var="#qShareUser#" label="Share User" expand="false">

        .badge-primary {    </cfif>

            background-color: #406E8E !important;

            color: #fff !important;    <!DOCTYPE html>

            border: 1px solid #406E8E !important;    <html lang="en">

        }    <head>

        <cfoutput>

        .btn-primary,            <meta charset="utf-8">

        .btn-outline-primary:hover {            <meta name="viewport" content="width=device-width, initial-scale=1.0">

            background-color: #406E8E !important;            <meta http-equiv="X-UA-Compatible" content="IE=edge">

            border-color: #406E8E !important;            <title>#appname# | Shared Contacts</title>

        }        </cfoutput>

        <link href="./icons.min.css" rel="stylesheet" type="text/css" />

        .text-primary,

        .btn-outline-primary {        <cfif isDefined("FindLinksT") AND isQuery(FindLinksT)>

            color: #406E8E !important;            <cfloop query="FindLinksT">

            border-color: #406E8E !important;                <cfoutput>

        }                    <cfif FindLinksT.linktype EQ "script">

    </style>                        <script src="#FindLinksT.linkurl#"></script>

</head>                    <cfelseif FindLinksT.linktype EQ "script_include">

<body class="loading">                        <script>

    <div class="container-fluid px-0">                            <cfinclude template="#FindLinksT.linkurl#?rev=#RandRange(1,1000000)#">

        <header id="share-header">                        </script>

            <div class="d-flex align-items-center">                    <cfelseif FindLinksT.linktype EQ "css" OR FindLinksT.linktype EQ "text/css" OR FindLinksT.linktype EQ "ico">

                <div class="logo mr-3">                        <link href="#FindLinksT.linkurl#?rev=#RandRange(1,1000000)#"

                    <cfoutput>                              <cfif len(trim(FindLinksT.rel))>rel="#FindLinksT.rel#"</cfif>

                        <img src="#mediaBase#/images/logo-light.png" alt="The Actor's Office">                              type="text/css"

                    </cfoutput>                              <cfif len(trim(FindLinksT.hrefid))>id="#FindLinksT.hrefid#"</cfif>>

                </div>                    </cfif>

                <div>                </cfoutput>

                    <h1 class="h4 mb-1">Shared Contacts</h1>            </cfloop>

                    <cfoutput>        <cfelse>

                        <p class="mb-0">#userfirstname# #userlastname#</p>            <link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css" rel="stylesheet" type="text/css" />

                    </cfoutput>            <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>

                </div>            <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/js/bootstrap.bundle.min.js"></script>

            </div>        </cfelse>

        </header>

        <style>

        <main class="container-fluid">            body.loading {

            <cfinclude template="share.cfm">                display: flex;

        </main>                justify-content: center;

    </div>                align-items: center;

                width: 100%;

    <cfif isDefined("FindLinksB") AND isQuery(FindLinksB)>                height: 100vh;

        <cfloop query="FindLinksB">                position: fixed;

            <cfoutput>                top: 0;

                <cfif FindLinksB.linktype EQ "script">                left: 0;

                    <script src="#FindLinksB.linkurl#?ver=#RandRange(1,1000000)#"></script>                background: rgba(255,255,255,0.85);

                <cfelseif FindLinksB.linktype EQ "script_include">                z-index: 9999;

                    <script>            }

                        <cfinclude template="#FindLinksB.linkurl#?rev=#RandRange(1,1000000)#">

                    </script>            #share-header {

                <cfelseif FindLinksB.linktype EQ "css" OR FindLinksB.linktype EQ "text/css" OR FindLinksB.linktype EQ "ico">                background-color: #406E8E;

                    <link href="#FindLinksB.linkurl#?ver=#RandRange(1,1000000)#"                color: #fff;

                          <cfif len(trim(FindLinksB.rel))>rel="#FindLinksB.rel#"</cfif>                padding: 1.5rem 1rem;

                          type="text/css"                margin-bottom: 1rem;

                          <cfif len(trim(FindLinksB.hrefid))>id="#FindLinksB.hrefid#"</cfif>>            }

                </cfif>

            </cfoutput>            #share-header .logo img {

        </cfloop>                height: 32px;

    </cfif>                width: auto;

</body>            }

</html>

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
        </style>
    </head>
    <body class="loading">
        <div class="container-fluid px-0">
            <header id="share-header">
                <div class="d-flex align-items-center">
                    <div class="logo mr-3">
                        <cfoutput>
                            <img src="/media-#application.dsn#/images/logo-light.png" alt="The Actor's Office">
                        </cfoutput>
                    </div>
                    <div>
                        <h1 class="h4 mb-1">Shared Contacts</h1>
                        <cfoutput>
                            <p class="mb-0">#userfirstname# #userlastname#</p>
                        </cfoutput>
                    </div>
                </div>
            </header>

            <main class="container-fluid">
                <cfinclude template="share.cfm">
            </main>
        </div>

        <cfif isDefined("FindLinksB") AND isQuery(FindLinksB)>
            <cfloop query="FindLinksB">
                <cfoutput>
                    <cfif FindLinksB.linktype EQ "script">
                        <script src="#FindLinksB.linkurl#?ver=#RandRange(1,1000000)#"></script>
                    <cfelseif FindLinksB.linktype EQ "script_include">
                        <script>
                            <cfinclude template="#FindLinksB.linkurl#?rev=#RandRange(1,1000000)#">
                        </script>
                    <cfelseif FindLinksB.linktype EQ "css" OR FindLinksB.linktype EQ "text/css" OR FindLinksB.linktype EQ "ico">
                        <link href="#FindLinksB.linkurl#?ver=#RandRange(1,1000000)#"
                              <cfif len(trim(FindLinksB.rel))>rel="#FindLinksB.rel#"</cfif>
                              type="text/css"
                              <cfif len(trim(FindLinksB.hrefid))>id="#FindLinksB.hrefid#"</cfif>>
                    </cfif>
                </cfoutput>
            </cfloop>
        </cfif>
    </body>
    </html>