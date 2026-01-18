<cfset tagsUserService = createObject("component", "services.TagsUserService")>
<cfset find = tagsUserService.SELtags_user_24457(
    tagname = x.tagname,
    userid = users.userid
)>