<cfset audlinks = "" />

<cfset audlinkService = createObject("component", "services.AuditionLinkService") />
<cfset audlinks = audlinkService.SELaudlinks(audroleid=audroleid) />