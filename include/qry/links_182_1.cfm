<cfset auditionLinkService = createObject("component", "services.AuditionLinkService")>
<cfset auditionLinkService.INSaudlinks(
    linkname = linkname,
    linkurl = linkurl,
    audroleid = audroleid
)>