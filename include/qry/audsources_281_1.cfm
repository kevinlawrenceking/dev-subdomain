<cfinclude template="/include/perfcount.cfm" />
<cfset audsourcesService = createObject("component", "services.AuditionSourceService")>
<cfset audsources = audsourcesService.SELaudsources_24222()>