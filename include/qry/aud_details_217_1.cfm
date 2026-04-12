<cfinclude template="/include/perfcount.cfm" />
<cfset auditionRoleService = createObject("component", "services.AuditionRoleService")>
<cfset aud_details = auditionRoleService.DETaudroles(audroleid=audroleid)>