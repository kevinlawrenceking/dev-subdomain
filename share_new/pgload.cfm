<!--- Default Parameters --->
<cfparam name="u" default="434F6AD485112F73A9" />
<cfparam name="pgaction" default="view" />
<cfparam name="subdomain" default="app" />
<cfparam name="thispage2" default="" />
<cfparam name="rpgid" default="0" />
<cfset currentURL = cgi.server_name />
<cfset host = ListFirst(currentURL, ".") />
<cfaborT> 
<!--- Debugging or Utility Outputs --->
<cfoutput>
    <cfset thisPath = ExpandPath("*.*") />
    <cfset thisDirectory = "#GetDirectoryFromPath(thisPath)#" />
</cfoutput>

<cfparam name="catArea_UCB" default="C" />
<cfparam name="contactid" default="0" />

<!--- Load the UserService --->
<cfset userService = createObject("component", "services.UserService")>
<cfset userData = userService.getUserByHash(uid) />

<!--- Check if user data was found --->
<cfif userData.recordCount EQ 0>
    <cfoutput>Not found!</cfoutput>
    <cfabort>
<cfelse>
    <!--- Map user data to local variables --->
    <cfset userid = userData.userId />
    <cfset userContactid = userData.userContactID />
    <cfset userCalStarttime = userData.calstarttime />
    <cfset userCalendtime = userData.calendtime />
    <cfset avatarname = userData.avatarname />
    <cfset isbetatester = userData.isBetaTester />
    <cfset defrows = userData.defRows + 1 />
    <cfset defcountry = userData.defCountry />
    <cfset defState = userData.defState />
    <cfset tzid = userData.tzid />
    <cfset customerid = userData.customerid />
    <cfset userFirstName = userData.userFirstName />
    <cfset userLastName = userData.userLastName />
    <cfset userEmail = userData.userEmail />
    <cfset userRole = userData.userRole />

    <cfif userContactid EQ contactid>
        <cfset catArea_UCB = "U" />
    </cfif>
</cfif>
<Cfset userAvatarUrl = "/media-" & dsn & "/users/" & userid & "/avatar.jpg" />
<!--- Fetch shares --->
<cfset ShareService = createObject("component", "services.ShareService")>
<cfset shares = ShareService.shares(userid=userid)>

<!--- Fetch page data --->
<cfset PageService = createObject("component", "services.PageService")>
<cfset FindPage = PageService.getPagesByShare() />

<cfif FindPage.RecordCount EQ 1>
    <!--- Fetch related links and components --->
<cfset PageService = createObject("component", "services.PageService")>
<cfset FindLinksT = PageService.getLinksTop(pgid=11)>
 
<cfset PageService = createObject("component", "services.PageService")>
<cfset FindLinksB = PageService.getLinksBottom(pgid=11)>
 
 <cfset PageService = createObject("component", "services.PageService")>
<cfset FindLinksExtra = PageService.getLinksExtra(pgid=11)>

    <!--- Set application variables --->
    <cfset appName = FindPage.appName />
    <cfset appDescription = FindPage.appDescription />
    <cfset appAuthor = FindPage.appAuthor />
    <cfset appLogoName = FindPage.appLogoName />
    <cfset colorTopBar = (host EQ "uat") ? "Purple" : FindPage.colorTopBar />
    <cfset colorLeftSideBar = FindPage.colorLeftSideBar />
    <cfset home = "/app/dashboard" />
    <cfset mocktoday = FindPage.mocktoday />
    <cfset mock_yn = FindPage.mock_yn />

    <!--- Set component variables --->
    <cfset compid = FindPage.compid />
    <cfset compname = FindPage.compname />
    <cfset compDir = FindPage.compDir />
    <cfset compTable = FindPage.compTable />
    <cfset compowner = FindPage.compowner />

    <!--- Set page variables --->
    <cfset pgid = FindPage.pgid />
    <cfset cookie.pgid = FindPage.pgid />
    <cfset pgname = FindPage.pgname />
    <cfset pgDir = FindPage.pgDir />
    <cfset pgTitle = FindPage.pgTitle />
    <cfset pgHeading = FindPage.pgHeading />
    <cfset pgFilename = FindPage.pgFilename />
    <cfset update_type = FindPage.update_type />

    <cfoutput>
        <cfset pageTitle = "#appName# | #pgTitle#" />
    </cfoutput>
<cfelse>
    <cfoutput>No record! #trim(thispage)#</cfoutput>
</cfif>
