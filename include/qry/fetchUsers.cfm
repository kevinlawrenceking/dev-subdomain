<cfinclude template="/include/perfcount.cfm" />

<!--- PERF: Session-cache the user data struct. Only hit the DB on first
      request of the session or when a profile update sets the bust flag.
      MIGRATE: In Go, this becomes a JWT claims payload or Redis-cached user struct. --->
<cfif NOT structKeyExists(session, "cachedUserData")
      OR (structKeyExists(session, "bustUserCache") AND session.bustUserCache)>
    <cfset userService = request.svc("UserService")>
    <cfset session.cachedUserData = userService.getUserById(userID)>
    <cfset session.bustUserCache = false>
</cfif>

<cfset userData = session.cachedUserData>

<!--- Session-specific values --->
<cfset session.dateformatExample = userData.dateformatExample>
<cfset session.dateformatID = userData.dateformatID>

<!--- Core user identity --->
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
<cfset isDemo           = structKeyExists(userData, "isDemo") ? userData.isDemo : 0>
<cfset isauditionmodule = userData.isauditionmodule>
<cfset recover          = userData.recover>
<cfset shareid          = userData.shareid>

<!--- Display / Calendar preferences --->
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

<!--- OAuth tokens --->
<cfset refreshToken     = userData.refresh_token>
<cfset accessToken      = userData.access_token>

<!--- P11: Setup wizard session variables
      Note: DB userstatus may have trailing spaces (CHAR-style padding). Trim for clean comparison. --->
<cfset session.userstatus = trim(userData.userStatus)>
<cfset session.setup_step = structKeyExists(userData, "setup_step") ? val(userData.setup_step) : 7>

<!--- ThriveCart / billing --->
<cfset customerId           = userData.customerId>
<cfset customerFirst        = userData.customerFirst>
<cfset customerLast         = userData.customerLast>
<cfset customerFullName     = userData.customerFullName>
<cfset customerEmail        = userData.customerEmail>
<cfset purchaseDate         = userData.purchaseDate>
<cfset purchaseName         = userData.purchaseName>
<cfset baseProductName      = userData.baseProductName>
<cfset baseProductLabel     = userData.baseProductLabel>
<cfset baseProductId        = userData.baseProductId>
<cfset basePaymentPlanId    = userData.basePaymentPlanId>
<cfset orderDate            = userData.orderDate>
<cfset trialDays            = userData.trialDays>
<cfset trialEndDate         = userData.trialEndDate>
<cfset purchaseAmountCents  = userData.purchaseAmountCents>
<cfset invoiceId            = userData.invoiceId>
<cfset billingAddress       = userData.billingAddress>
<cfset billingCity          = userData.billingCity>
<cfset billingZip           = userData.billingZip>
<cfset billingCountry       = userData.billingCountry>
<cfset billingState         = userData.billingState>
<cfset planName             = userData.planName>
<cfset accountStatus        = userData.status>
<cfset cancelDate           = userData.cancelDate>
