<cfinclude template="/include/perfcount.cfm" />
<cfset auditionSourceService = createObject("component", "services.AuditionSourceService")>
<cfset audsources_sel = auditionSourceService.SELaudsources_24684()>