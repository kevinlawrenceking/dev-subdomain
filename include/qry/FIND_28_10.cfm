<cfinclude template="/include/perfcount.cfm" />
<cfset auditionPlatformUserService = createObject("component", "services.AuditionPlatformUserService") />
<cfset FIND = auditionPlatformUserService.SELaudPlatforms_user_23778(userid=userid, CustomPlatform=CustomPlatform) />