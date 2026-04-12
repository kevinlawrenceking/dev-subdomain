<cfinclude template="/include/perfcount.cfm" />
<cfset tagsUserService = createObject("component", "services.TagsUserService")>
<cfset tags = tagsUserService.SELtags_user_24047(userid=userid, tagtypes=tagtypes)>