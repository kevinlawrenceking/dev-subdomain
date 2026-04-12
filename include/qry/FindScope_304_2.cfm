<cfinclude template="/include/perfcount.cfm" />
<cfset tagsUserService = createObject("component", "services.TagsUserService")>
<cfset FindScope = tagsUserService.SELtags_user_24341(new_contactid=new_contactid)>