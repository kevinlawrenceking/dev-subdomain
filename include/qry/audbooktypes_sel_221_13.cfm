<cfinclude template="/include/perfcount.cfm" />
<cfset auditionBookTypeService = createObject("component", "services.AuditionBookTypeService")>
<cfset audbooktypes_sel = auditionBookTypeService.SELaudbooktypes()>