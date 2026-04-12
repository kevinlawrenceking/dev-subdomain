<cfinclude template="/include/perfcount.cfm" />
<cfset auditionSubmitSiteUserService = createObject("component", "services.AuditionSubmitSiteUserService")>
<cfset details = auditionSubmitSiteUserService.DETaudsubmitsites_user(submitsiteid=submitsiteid)>