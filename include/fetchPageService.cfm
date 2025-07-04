<!--- This ColdFusion page retrieves and processes page details based on the provided RPG ID or page directory. --->
<cfset pageService = createObject("component", "services.PageService")>

<!--- Check if RPG ID is greater than 0 to fetch page details accordingly --->
<cfif rpgid GT 0>
    <cfset FindPage = pageService.getPageDetails(pgid=rpgid)>
<cfelse>
    <cfset FindPage = pageService.getPageDetails(pgDir=thispage)>
</cfif>

<!--- Check if the retrieved page details are empty --->
<cfif StructIsEmpty(FindPage)>
    <cfoutput>No record found for the page: #thispage#</cfoutput>
    <cfabort>
</cfif>

<!--- Set application and page variables from the retrieved page details --->
<cfset appName = FindPage.appname />
<cfset appDescription = FindPage.appDescription />
<cfset appAuthor = FindPage.appAuthor />
<cfset appLogoName = FindPage.appLogoName />
<cfset colorTopBar = (host EQ "uat") ? "Purple" : FindPage.colorTopBar />
<cfset colorLeftSideBar = FindPage.colorLeftSideBar />
<cfset home = "/app/dashboard" />
<cfset mocktoday = FindPage.mocktoday />
<cfset mock_yn = FindPage.mock_yn />
<cfset compid = FindPage.compid />
<cfset compname = FindPage.compname />
<cfset compDir = FindPage.compDir />
<cfset compTable = FindPage.compTable />
<cfset compowner = FindPage.compowner />
<cfset pgid = FindPage.pgid />
<cfset cookie.pgid = FindPage.pgid />
<cfset pgname = FindPage.pgname />
<cfset pgDir = FindPage.pgDir />
<cfset pgTitle = FindPage.pgTitle />
<cfset pgHeading = FindPage.pgHeading />
<cfset pgFilename = FindPage.pgFilename />
<cfset update_type = FindPage.update_type />
<cfset pageTitle = appName & " | " & pgTitle />
<cfset currentURL = cgi.server_name />
<cfset host = ListFirst(currentURL, ".") />

<!--- Determine host color based on the host name --->
<cfset hostcolor = (host EQ "app") ? "##406E8E" :
                  (host EQ "dev") ? "##8b0000" :
                  (host EQ "uat") ? "purple" :
                  (host EQ "chris") ? "green" :
                  (host EQ "new") ? "##284559" :
                  (host EQ "kevin") ? "violet" : "" />

<!--- Fetch the page links based on the page ID and version --->
<cfset pageLinks = pageService.getPageLinksByLocation(pgid=FindPage.pgid, version="1.1")>

<!--- Fetch the include links for the page --->
<cfset includeLinksArray = pageService.getIncludeLinks(pgid=FindPage.pgid)>
