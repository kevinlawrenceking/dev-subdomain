<cfinclude template="/include/perfcount.cfm" />
<cfset tagsUserService = createObject("component", "services.TagsUserService")>
<cfset casting_types = tagsUserService.SELtags_user(userid=userid)>