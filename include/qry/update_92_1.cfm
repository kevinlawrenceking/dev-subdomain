<cfset siteLinkUserService = createObject("component", "services.SiteLinkUserService")>
<cfset siteLinkUserService.UPDsitelinks_user(fileName="#fileName#", id="#id#")>