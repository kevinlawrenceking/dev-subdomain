<cfinclude template="/include/perfcount.cfm" />
<cfset auditionRoleService = createObject("component", "services.AuditionRoleService")>
<cfset auditionRoleService.setFirstMeetingDates()>