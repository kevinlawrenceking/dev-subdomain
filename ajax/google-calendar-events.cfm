<cfsilent>
<!---
    ajax/google-calendar-events.cfm — Fetch Google Calendar events for FullCalendar
    Method: GET
    Params: start (ISO 8601), end (ISO 8601) — sent automatically by FullCalendar
    Returns: JSON array of event objects formatted for FullCalendar v6
    Auth: session.userid enforced by ajax/Application.cfc
--->

<cfset response = [] />

<!--- Get user's Google tokens --->
<cfquery name="userTokens" datasource="#application.datasource#">
    SELECT access_token, refresh_token
    FROM taousers
    WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="CF_SQL_INTEGER" />
</cfquery>

<!--- Exit early if no Google account linked --->
<cfif userTokens.recordCount EQ 0 OR NOT len(trim(userTokens.access_token))>
    <!--- Return empty array silently — user hasn't linked Google --->
</cfif>

<cfif userTokens.recordCount GT 0 AND len(trim(userTokens.access_token))>

    <cfparam name="url.start" default="" />
    <cfparam name="url.end" default="" />

    <!--- Build Google Calendar API URL with time range --->
    <cfset apiUrl = "https://www.googleapis.com/calendar/v3/calendars/primary/events" />
    <cfset apiParams = "singleEvents=true&orderBy=startTime&maxResults=250" />

    <cfif len(url.start) AND isDate(url.start)>
        <cfset apiParams = apiParams & "&timeMin=" & URLEncodedFormat(url.start) />
    </cfif>
    <cfif len(url.end) AND isDate(url.end)>
        <cfset apiParams = apiParams & "&timeMax=" & URLEncodedFormat(url.end) />
    </cfif>

    <cfset fullUrl = apiUrl & "?" & apiParams />
    <cfset currentToken = userTokens.access_token />

    <!--- Attempt API call (with one retry after token refresh) --->
    <cfset maxAttempts = 2 />
    <cfloop from="1" to="#maxAttempts#" index="attempt">

        <cfhttp url="#fullUrl#" method="get" result="apiResponse" charset="utf-8" timeout="10">
            <cfhttpparam type="header" name="Authorization" value="Bearer #currentToken#" />
        </cfhttp>

        <cfif left(apiResponse.statusCode, 3) EQ "200">
            <!--- Success: parse events --->
            <cftry>
                <cfset gcalData = deserializeJSON(apiResponse.FileContent) />
                <cfif structKeyExists(gcalData, "items")>
                    <cfloop array="#gcalData.items#" index="item">
                        <cfset evt = {} />
                        <cfset evt["id"] = "gcal-" & item.id />
                        <cfset evt["title"] = structKeyExists(item, "summary") ? item.summary : "(No title)" />
                        <cfset evt["className"] = "gcal-event" />
                        <cfset evt["backgroundColor"] = "##4285F4" />
                        <cfset evt["borderColor"] = "##3367D6" />
                        <cfset evt["editable"] = false />
                        <cfset evt["extendedProps"] = {
                            "source": "google",
                            "description": structKeyExists(item, "description") ? left(item.description, 200) : "",
                            "eventType": "Google Calendar"
                        } />

                        <!--- Parse start/end (can be date-only or dateTime) --->
                        <cfif structKeyExists(item.start, "dateTime")>
                            <cfset evt["start"] = item.start.dateTime />
                            <cfset evt["allDay"] = false />
                        <cfelseif structKeyExists(item.start, "date")>
                            <cfset evt["start"] = item.start.date />
                            <cfset evt["allDay"] = true />
                        </cfif>

                        <cfif structKeyExists(item, "end")>
                            <cfif structKeyExists(item.end, "dateTime")>
                                <cfset evt["end"] = item.end.dateTime />
                            <cfelseif structKeyExists(item.end, "date")>
                                <cfset evt["end"] = item.end.date />
                            </cfif>
                        </cfif>

                        <cfset arrayAppend(response, evt) />
                    </cfloop>
                </cfif>
            <cfcatch>
                <cflog file="tao_google_oauth" type="error"
                       text="[gcal-events] Parse error: #cfcatch.message# userid=#session.userid#" />
            </cfcatch>
            </cftry>
            <cfbreak />

        <cfelseif left(apiResponse.statusCode, 3) EQ "401" AND attempt EQ 1 AND len(trim(userTokens.refresh_token))>
            <!--- Token expired: attempt refresh --->
            <cflog file="tao_google_oauth"
                   text="[gcal-events] Access token expired, refreshing. userid=#session.userid#" />

            <cfhttp url="https://oauth2.googleapis.com/token" method="post" result="refreshResult" charset="utf-8" timeout="10">
                <cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded" />
                <cfhttpparam type="formField" name="client_id" value="#application.secrets.googleOAuthClientId#" />
                <cfhttpparam type="formField" name="client_secret" value="#application.secrets.googleOAuthClientSecret#" />
                <cfhttpparam type="formField" name="refresh_token" value="#userTokens.refresh_token#" />
                <cfhttpparam type="formField" name="grant_type" value="refresh_token" />
            </cfhttp>

            <cfif left(refreshResult.statusCode, 3) EQ "200">
                <cftry>
                    <cfset refreshData = deserializeJSON(refreshResult.FileContent) />
                    <cfset currentToken = refreshData.access_token />

                    <!--- Store the new access token --->
                    <cfquery datasource="#application.datasource#">
                        UPDATE taousers
                        SET access_token = <cfqueryparam value="#currentToken#" cfsqltype="CF_SQL_VARCHAR" />
                        WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="CF_SQL_INTEGER" />
                    </cfquery>

                    <cflog file="tao_google_oauth"
                           text="[gcal-events] Token refreshed successfully. userid=#session.userid#" />
                <cfcatch>
                    <cflog file="tao_google_oauth" type="error"
                           text="[gcal-events] Refresh parse error: #cfcatch.message# userid=#session.userid#" />
                    <cfbreak />
                </cfcatch>
                </cftry>
            <cfelse>
                <!--- Refresh failed (token revoked or expired) --->
                <cflog file="tao_google_oauth" type="error"
                       text="[gcal-events] Refresh failed. status=#refreshResult.statusCode# userid=#session.userid#. Clearing tokens." />
                <!--- Clear tokens so user sees Link Google button again --->
                <cfquery datasource="#application.datasource#">
                    UPDATE taousers
                    SET access_token = '', refresh_token = ''
                    WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="CF_SQL_INTEGER" />
                </cfquery>
                <cfbreak />
            </cfif>

        <cfelse>
            <!--- Other error --->
            <cflog file="tao_google_oauth" type="error"
                   text="[gcal-events] API error. status=#apiResponse.statusCode# attempt=#attempt# userid=#session.userid#" />
            <cfbreak />
        </cfif>
    </cfloop>
</cfif>

</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true" /><cfoutput>#serializeJSON(response)#</cfoutput>
