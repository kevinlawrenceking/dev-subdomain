<cfinclude template="/include/perfcount.cfm" />
<cfset PageFieldService = createObject("component", "services.PageFieldService")>
<cfset FindKey = PageFieldService.SELpgfields_24115(rpgid=rpgid)>