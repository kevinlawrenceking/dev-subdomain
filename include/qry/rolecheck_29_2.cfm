<cfinclude template="/include/perfcount.cfm" />
<cfset auditionRoleService = createObject("component", "services.AuditionRoleService")>
<cfset rolecheck = auditionRoleService.SELaudroles(audroleid=audroleid)>