<!---
    admin_dashboard.cfm
    Contact Import V3 - Admin Dashboard

    Displays job health, feature flag status, and allowlist management.
    ADMIN ONLY - requires session.userrole = "Admin" or "Administrator"

    Actions:
    - GET (no action): Load dashboard data
    - action=refresh_flags: Force refresh feature flags cache
    - action=toggle_global: Toggle global import_v3_enabled flag
    - action=add_user: Add user to allowlist
    - action=remove_user: Remove user from allowlist
    - action=search_users: Search users for allowlist add
--->
<cfsilent>
    <cfset response = {
        "success": false,
        "message": "",
        "data": {}
    }>

    <!--- Admin check - require Admin or Administrator role --->
    <cfif NOT isDefined("session.userid")>
        <cfset response.success = false>
        <cfset response.message = "Not authenticated.">
        <cfset response.code = "AUTH_REQUIRED">
        <cfcontent type="application/json" reset="true">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Check admin role --->
    <cfset isAdmin = false>
    <cfif isDefined("session.userrole")>
        <cfif session.userrole EQ "Admin" OR session.userrole EQ "Administrator">
            <cfset isAdmin = true>
        </cfif>
    </cfif>

    <cfif NOT isAdmin>
        <cfset response.success = false>
        <cfset response.message = "Admin access required.">
        <cfset response.code = "ACCESS_DENIED">
        <cfcontent type="application/json" reset="true">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- CSRF token management - generate if not exists --->
    <cfif NOT structKeyExists(session, "csrf_token") OR NOT len(session.csrf_token)>
        <cfset session.csrf_token = createUUID()>
    </cfif>

    <!--- CSRF validation for POST state-changing actions --->
    <cfset stateChangingActions = "refresh_flags,toggle_global,add_user,remove_user">
    <cfparam name="form.action" default="">
    <cfif len(form.action) AND listFindNoCase(stateChangingActions, form.action)>
        <cfparam name="form.csrf_token" default="">
        <cfif NOT len(form.csrf_token) OR form.csrf_token NEQ session.csrf_token>
            <cfset response.success = false>
            <cfset response.message = "Invalid or missing CSRF token.">
            <cfset response.code = "CSRF_INVALID">
            <cfcontent type="application/json" reset="true">
            <cfoutput>#serializeJSON(response)#</cfoutput>
            <cfabort>
        </cfif>
    </cfif>

    <!--- Initialize service --->
    <cfset importService = new services.ContactImportV3Service()>

    <!--- Get action parameter --->
    <cfparam name="url.action" default="">
    <cfparam name="form.action" default="">
    <cfset action = len(form.action) ? form.action : url.action>

    <!--- Handle actions --->
    <cfswitch expression="#action#">

        <!--- Force refresh feature flags --->
        <cfcase value="refresh_flags">
            <cftry>
                <cfset forceRefreshFeatureFlags()>
                <cfset response.success = true>
                <cfset response.message = "Feature flags refreshed.">
                <cfset response.data.flagStatus = importService.getFeatureFlagStatus()>
                <cfcatch>
                    <cfset response.success = false>
                    <cfset response.message = "Failed to refresh flags: " & cfcatch.message>
                </cfcatch>
            </cftry>
        </cfcase>

        <!--- Toggle global flag --->
        <cfcase value="toggle_global">
            <cfparam name="form.enabled" default="">
            <cfset newState = (form.enabled EQ "1" OR form.enabled EQ "true")>
            <cfset result = importService.setFeatureFlag("import_v3_enabled", newState)>
            <cfif result.success>
                <!--- Force refresh to apply change immediately --->
                <cfset forceRefreshFeatureFlags()>
                <cfset response.success = true>
                <cfset response.message = "Global flag set to " & (newState ? "ENABLED" : "DISABLED")>
                <cfset response.data.flagStatus = importService.getFeatureFlagStatus()>
            <cfelse>
                <cfset response = result>
            </cfif>
        </cfcase>

        <!--- Add user to allowlist --->
        <cfcase value="add_user">
            <cfparam name="form.userid" default="">
            <cfparam name="form.notes" default="">
            <cfif NOT isNumeric(form.userid) OR form.userid LTE 0>
                <cfset response.success = false>
                <cfset response.message = "Invalid userid.">
            <cfelse>
                <cfset result = importService.addAllowedUser(val(form.userid), form.notes)>
                <cfif result.success>
                    <!--- Force refresh to apply change immediately --->
                    <cfset forceRefreshFeatureFlags()>
                    <cfset response.success = true>
                    <cfset response.message = "User added to allowlist.">
                    <cfset response.data.allowedUsers = importService.getAllowedUsers().data.users>
                <cfelse>
                    <cfset response = result>
                </cfif>
            </cfif>
        </cfcase>

        <!--- Remove user from allowlist --->
        <cfcase value="remove_user">
            <cfparam name="form.userid" default="">
            <cfif NOT isNumeric(form.userid) OR form.userid LTE 0>
                <cfset response.success = false>
                <cfset response.message = "Invalid userid.">
            <cfelse>
                <cfset result = importService.removeAllowedUser(val(form.userid))>
                <cfif result.success>
                    <!--- Force refresh to apply change immediately --->
                    <cfset forceRefreshFeatureFlags()>
                    <cfset response.success = true>
                    <cfset response.message = "User removed from allowlist.">
                    <cfset response.data.allowedUsers = importService.getAllowedUsers().data.users>
                <cfelse>
                    <cfset response = result>
                </cfif>
            </cfif>
        </cfcase>

        <!--- Search users for add dialog --->
        <cfcase value="search_users">
            <cfparam name="url.q" default="">
            <cfparam name="form.q" default="">
            <cfset searchTerm = len(form.q) ? form.q : url.q>
            <cfif len(searchTerm) LT 2>
                <cfset response.success = true>
                <cfset response.data.users = []>
            <cfelse>
                <cftry>
                    <cfquery name="qUsers" datasource="#application.datasource#">
                        SELECT userid, userfirst, userlast, useremail, userRole
                        FROM taousers
                        WHERE isDeleted = 0
                          AND userStatus = 'Active'
                          AND (
                              userfirst LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                              OR userlast LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                              OR useremail LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                              OR CONCAT(userfirst, ' ', userlast) LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
                          )
                        ORDER BY userfirst, userlast
                        LIMIT 20
                    </cfquery>
                    <cfset users = []>
                    <cfloop query="qUsers">
                        <cfset arrayAppend(users, {
                            "userid": qUsers.userid,
                            "user_name": trim(qUsers.userfirst & " " & qUsers.userlast),
                            "user_email": qUsers.useremail,
                            "user_role": qUsers.userRole
                        })>
                    </cfloop>
                    <cfset response.success = true>
                    <cfset response.data.users = users>
                    <cfcatch>
                        <cfset response.success = false>
                        <cfset response.message = "Search failed: " & cfcatch.message>
                    </cfcatch>
                </cftry>
            </cfif>
        </cfcase>

        <!--- Default: Load full dashboard data --->
        <cfdefaultcase>
            <cftry>
                <!--- Feature flag status --->
                <cfset flagStatus = importService.getFeatureFlagStatus()>

                <!--- Dashboard stats --->
                <cfset statsResult = importService.getDashboardStats()>
                <cfset stats = statsResult.success ? statsResult.data : {}>

                <!--- Recent jobs --->
                <cfset jobsResult = importService.getRecentJobs(50)>
                <cfset recentJobs = jobsResult.success ? jobsResult.data.jobs : []>

                <!--- Allowed users --->
                <cfset allowedResult = importService.getAllowedUsers()>
                <cfset allowedUsers = allowedResult.success ? allowedResult.data.users : []>

                <cfset response.success = true>
                <cfset response.data = {
                    "flagStatus": flagStatus,
                    "stats": stats,
                    "recentJobs": recentJobs,
                    "allowedUsers": allowedUsers,
                    "serverTime": now(),
                    "csrf_token": session.csrf_token
                }>
                <cfcatch>
                    <cfset response.success = false>
                    <cfset response.message = "Failed to load dashboard: " & cfcatch.message>
                </cfcatch>
            </cftry>
        </cfdefaultcase>

    </cfswitch>
</cfsilent>
<cfcontent type="application/json" reset="true">
<cfoutput>#serializeJSON(response)#</cfoutput>
