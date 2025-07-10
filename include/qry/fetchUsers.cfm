<cfset userService = createObject("component", "services.UserService")>
<cfset userData = userService.getUserById(userID)>

<!-- Session-specific values -->
<cfset session.dateformatExample = userData.dateformatExample>
<cfset session.dateformatID = userData.dateformatID>

<!-- Core user identity -->
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

<!-- Display / Calendar preferences -->
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

<!-- Date format / region -->
<cfset dateFormatID     = userData.dateFormatID>
<cfset datePrefID       = userData.datePrefID>
<cfset defCountryID     = userData.countryId>
<cfset defRegionID      = userData.region_id>
<cfset countryName      = userData.countryName>
<cfset regionName       = userData.regionName>

<!-- Address -->
<cfset add1             = userData.add1>
<cfset add2             = userData.add2>
<cfset city             = userData.city>
<cfset zip              = userData.zip>

<!-- Contact linkage -->
<cfset userContactID    = userData.contactid>

<!-- OAuth tokens -->
<cfset refreshToken     = userData.refresh_token>
<cfset accessToken      = userData.access_token>

<!-- ThriveCart / billing -->
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
<cfset accountStatus        = userData.status> <!-- renamed to avoid `status` clobber -->
<cfset cancelDate           = userData.cancelDate>
