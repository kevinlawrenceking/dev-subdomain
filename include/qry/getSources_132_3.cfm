<cfinclude template="/include/perfcount.cfm" />
<cfset auditionSourceService = createObject("component", "services.AuditionSourceService")>
<cfset getSources = auditionSourceService.SELaudsources()>