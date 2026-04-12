<cfinclude template="/include/perfcount.cfm" />
<cfset tagsUserService = createObject("component", "services.TagsUserService")>
<cfset y = tagsUserService.SELtags_user_24328(userid=userid)>