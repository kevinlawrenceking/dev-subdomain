<!---
    PURPOSE: Handle Google OAuth callback for calendar integration.
    Exchanges authorization code for access/refresh tokens and stores them.
    SCOPE: calendar.events (minimal permissions)
--->

<cfparam name="URL.code" default="" />
<cfparam name="URL.error" default="" />
<cfparam name="URL.error_description" default="" />
<cfparam name="URL.state" default="" />

<!--- 1) Verify the user has an active session --->
<cfif NOT structKeyExists(session, "userid")>
    <cflog file="tao_google_oauth" type="error"
           text="[callback] No session.userid. SameSite cookie may not have been sent. Redirecting to login." />
    <cflocation url="/loginform.cfm" addtoken="no" />
</cfif>

<!--- 2) Validate the state token (CSRF protection) --->
<cfif NOT structKeyExists(session, "googleOAuthState") OR url.state NEQ session.googleOAuthState>
    <cflog file="tao_google_oauth" type="error"
           text="[callback] State mismatch. Expected=#structKeyExists(session,'googleOAuthState') ? session.googleOAuthState : 'NONE'# Got=#HTMLEditFormat(url.state)# userid=#session.userid#" />
    <!--- Clean up --->
    <cfset structDelete(session, "googleOAuthState") />
    <cflocation url="/app/calendar-appoint/?google_error=state_mismatch" addtoken="no" />
</cfif>
<!--- Single-use: delete state token after validation --->
<cfset structDelete(session, "googleOAuthState") />

<!--- 3) Handle Google-side errors --->
<cfif len(trim(URL.error))>
    <cflog file="tao_google_oauth" type="warning"
           text="[callback] Google returned error=#HTMLEditFormat(url.error)# desc=#HTMLEditFormat(url.error_description)# userid=#session.userid#" />
    <cflocation url="/app/calendar-appoint/?google_error=#URLEncodedFormat(url.error)#" addtoken="no" />
</cfif>

<!--- 4) Validate authorization code present --->
<cfif NOT len(trim(URL.code))>
    <cflog file="tao_google_oauth" type="error"
           text="[callback] No authorization code received. userid=#session.userid#" />
    <cflocation url="/app/calendar-appoint/?google_error=no_code" addtoken="no" />
</cfif>

<!--- 5) Exchange authorization code for tokens --->
<cfset authorizationCode = trim(URL.code) />
<cfset clientId = application.secrets.googleOAuthClientId />
<cfset clientSecret = application.secrets.googleOAuthClientSecret />
<cfset redirectUri = application.secrets.googleOAuthRedirectUri />
<cfset tokenUrl = "https://oauth2.googleapis.com/token" />

<cflog file="tao_google_oauth"
       text="[callback] Exchanging code for tokens. userid=#session.userid# redirectUri=#redirectUri#" />

<cfhttp url="#tokenUrl#" method="post" result="tokenResponse" charset="utf-8" timeout="15">
    <cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded" />
    <cfhttpparam type="formField" name="code" value="#authorizationCode#" />
    <cfhttpparam type="formField" name="client_id" value="#clientId#" />
    <cfhttpparam type="formField" name="client_secret" value="#clientSecret#" />
    <cfhttpparam type="formField" name="redirect_uri" value="#redirectUri#" />
    <cfhttpparam type="formField" name="grant_type" value="authorization_code" />
</cfhttp>

<!--- 6) Process token response --->
<cfif left(tokenResponse.statusCode, 3) NEQ "200" OR NOT structKeyExists(tokenResponse, "FileContent")>
    <cflog file="tao_google_oauth" type="error"
           text="[callback] Token exchange failed. status=#tokenResponse.statusCode# userid=#session.userid#" />
    <cflocation url="/app/calendar-appoint/?google_error=token_exchange_failed" addtoken="no" />
</cfif>

<cftry>
    <cfset tokenData = deserializeJSON(tokenResponse.FileContent) />

    <!--- Extract tokens — refresh_token only present on first authorization --->
    <cfset newAccessToken = tokenData.access_token />
    <cfset newRefreshToken = structKeyExists(tokenData, "refresh_token") ? tokenData.refresh_token : "" />
    <cfset expiresIn = structKeyExists(tokenData, "expires_in") ? tokenData.expires_in : 3600 />

    <!--- 7) Store tokens in the database --->
    <cfif len(newRefreshToken)>
        <!--- First link or re-consent: store both tokens --->
        <cfquery>
            UPDATE taousers
            SET access_token = <cfqueryparam value="#newAccessToken#" cfsqltype="CF_SQL_VARCHAR" />,
                refresh_token = <cfqueryparam value="#newRefreshToken#" cfsqltype="CF_SQL_VARCHAR" />
            WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="CF_SQL_INTEGER" />
        </cfquery>
    <cfelse>
        <!--- Re-auth without new refresh token: keep existing refresh_token --->
        <cfquery>
            UPDATE taousers
            SET access_token = <cfqueryparam value="#newAccessToken#" cfsqltype="CF_SQL_VARCHAR" />
            WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="CF_SQL_INTEGER" />
        </cfquery>
    </cfif>

    <cflog file="tao_google_oauth"
           text="[callback] Tokens stored. userid=#session.userid# hasRefresh=#len(newRefreshToken) GT 0# expiresIn=#expiresIn#s" />

    <!--- 8) Redirect to calendar with success indicator --->
    <cflocation url="/app/calendar-appoint/?google_linked=1" addtoken="no" />

<cfcatch type="any">
    <cflog file="tao_google_oauth" type="error"
           text="[callback] Parse/store error: #cfcatch.message# userid=#session.userid#" />
    <cflocation url="/app/calendar-appoint/?google_error=parse_failed" addtoken="no" />
</cfcatch>
</cftry>
