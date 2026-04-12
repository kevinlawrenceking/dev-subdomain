<cfinclude template="/include/perfcount.cfm" />
<cfset auditionSubmitSiteUserService = createObject("component", "services.AuditionSubmitSiteUserService")>
<cfset subsites = auditionSubmitSiteUserService.SELaudsubmitsites_user(userid=userid)>