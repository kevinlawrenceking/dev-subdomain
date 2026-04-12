<cfinclude template="/include/perfcount.cfm" />
<cfset tagsUserService = createObject("component", "services.TagsUserService")>
<cfset tags = tagsUserService.SELtags_user_24063(userid=userid)>