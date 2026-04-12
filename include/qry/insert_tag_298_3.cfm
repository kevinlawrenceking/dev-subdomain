<cfinclude template="/include/perfcount.cfm" />
<cfset tagsUserService = createObject("component", "services.TagsUserService")>
<cfset tagsUserService.INStags_user(userid=userid, new_valuetext=new_valuetext)>