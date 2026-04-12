<cfinclude template="/include/perfcount.cfm" />
<cfset tagsUserService = createObject("component", "services.TagsUserService")>
<cfset find = tagsUserService.SELtags_user_24324(new_valuetext=new_valuetext, userid=userid)>