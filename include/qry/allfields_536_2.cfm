<cfinclude template="/include/perfcount.cfm" />
<cfset componentService = createObject("component", "services.ComponentService")>
<cfset fields = componentService.getAllFields(comptable=comptable)>