<cfinclude template="/include/perfcount.cfm" />
<cfset tagsService = createObject("component", "services.TagsUserService")>
<cfset tags = tagsService.SELtags_user_23844(userid=userid)>