<cfinclude template="/include/perfcount.cfm" />
<cfset objAuditionRoleService = createObject("component", "services.AuditionRoleService")>
<cfset objAuditionRoleService.UPDaudroles(audroleid=#audroleid#)>