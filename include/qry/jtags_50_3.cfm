<cfinclude template="/include/perfcount.cfm" />
<cfset tagsUserService = createObject("component", "services.TagsUserService")>
<cfset jtags = tagsUserService.SELtags_user_23804(userId=userid)>