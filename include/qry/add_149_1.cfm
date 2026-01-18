<cfset linkService = createObject("component", "services.LinkService")>
<cfset linkid =  linkService.INSlinks(
    linkname = linkname,
    linkurl = linkurl,
    noteid = noteid,
    userid = userid
)>