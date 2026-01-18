<cfset tagsUserService = createObject("component", "services.TagsUserService")>
<cfset tagsUserService.UPDtags_user(userid=userid, tagname=left(y.tagname, 40))>