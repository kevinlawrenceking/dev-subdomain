<cfinclude template="/include/perfcount.cfm" />
<cfset objAuditionRoleService = createObject("component", "services.AuditionRoleService")>
<cfset objAuditionRoleService.UPDaudroles_23813(statusField=statusfield, newAudRoleId=new_audroleid)>