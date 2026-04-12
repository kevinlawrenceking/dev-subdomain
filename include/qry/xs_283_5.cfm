<cfinclude template="/include/perfcount.cfm" />
<cfset fuActionService = createObject("component", "services.FUActionService")>
<cfset xs = fuActionService.SELfuactions(target_id_system=target_id_system)>