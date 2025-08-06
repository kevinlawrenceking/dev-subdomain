<cfset auditionRoleService = createObject("component", "services.AuditionRoleService")>
<cfset roleDetails = auditionRoleService.DETaudroles_24544(audroleid=audroleid)>

<cfset current_queryResult = roleDetails />
