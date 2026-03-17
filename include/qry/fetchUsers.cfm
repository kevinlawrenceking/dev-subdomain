<!---
    fetchUsers.cfm — Populate per-request user variables from session-cached data.

    Performance: caches userData in session scope for up to 5 minutes to avoid
    a 5-table JOIN on every single request. Forces refresh on user switch
    (impersonation) or when request.forceRefreshUserData is set.

    Security: OAuth tokens and billing data are NOT set as bare variables.
    Pages that need them should read session.userData.refresh_token etc. directly.
--->

<!--- Determine if we need a fresh DB query --->
<cfset var needsRefresh = true>
<cfif structKeyExists(session, "userData")
      AND structKeyExists(session, "userDataCachedAt")
      AND structKeyExists(session.userData, "userId")
      AND session.userData.userId EQ userID
      AND NOT (structKeyExists(request, "forceRefreshUserData") AND request.forceRefreshUserData)
      AND dateDiff("n", session.userDataCachedAt, now()) LT 5>
    <cfset needsRefresh = false>
</cfif>

<cfif needsRefresh>
    <!--- Application-scoped service (avoid per-request createObject) --->
    <cfif NOT structKeyExists(application, "userServiceCached")>
        <cfset application.userServiceCached = createObject("component", "services.UserService")>
    </cfif>
    <cfset session.userData = application.userServiceCached.getUserById(userID)>
    <cfset session.userDataCachedAt = now()>
</cfif>

<cfset userData = session.userData>

<!--- Session-specific values --->
<cfset session.dateformatExample = userData.dateformatExample>
<cfset session.dateformatID = userData.dateformatID>
<cfset session.userrole = userData.userRole>

<!--- Core user identity (widely referenced across 54+ templates) --->
<cfset userId           = userData.userId>
<cfset uid              = userData.uuid>
<cfset uuid             = userData.uuid>
<cfset recordName       = userData.recordName>
<cfset userFirstName    = userData.userFirstName>
<cfset userLastName     = userData.userLastName>
<cfset userEmail        = userData.userEmail>
<cfset userRole         = userData.userRole>
<cfset userStatus       = userData.userStatus>
<cfset isDeleted        = userData.isDeleted>
<cfset isSetup          = userData.isSetup>
<cfset isAudition       = userData.isAudition>
<cfset isBetaTester     = userData.isBetaTester>
<cfset isDemo           = userData.isDemo>
<cfset isauditionmodule = userData.isauditionmodule>
<cfset recover          = userData.recover>
<cfset shareid          = userData.shareid>

<!--- Display / Calendar preferences (calendarName used by Application.cfc path setup) --->
<cfset calendarName     = userData.calendarName>
<cfset calSlotDuration  = userData.calSlotDuration>
<cfset calStartTime     = userData.calStarttime>
<cfset calEndTime       = userData.calendtime>
<cfset avatarName       = userData.avatarname>
<cfset defRows          = userData.defRows>
<cfset viewTypeID       = userData.viewtypeid>
<cfset tzId             = userData.tzid>
<cfset tzName           = userData.tzname>
<cfset tzGeneral        = userData.tzgeneral>

<!--- Date format / region --->
<cfset dateFormatID     = userData.dateFormatID>
<cfset datePrefID       = userData.datePrefID>
<cfset defCountryID     = userData.countryId>
<cfset defRegionID      = userData.region_id>
<cfset countryName      = userData.countryName>
<cfset regionName       = userData.regionName>

<!--- Address --->
<cfset add1             = userData.add1>
<cfset add2             = userData.add2>
<cfset city             = userData.city>
<cfset zip              = userData.zip>

<!--- Contact linkage --->
<cfset userContactID    = userData.contactid>

<!--- OAuth tokens: REMOVED from bare variables scope.
      Only 1 file (include/get_google_calendars.cfm) needs these.
      Read via session.userData.refresh_token / session.userData.access_token --->

<!--- Billing data: REMOVED from bare variables scope.
      Only 1 file (app/admin-users/ajax/send-email.cfm) needs these.
      Read via session.userData.customerId etc. --->
