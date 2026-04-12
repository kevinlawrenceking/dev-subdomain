<cfinclude template="/include/perfcount.cfm" />
<cfset pageFieldService = createObject("component", "services.PageFieldService")>
<cfset FindKey = pageFieldService.SELpgfields(rpgid=rpgid)>