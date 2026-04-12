<cfinclude template="/include/perfcount.cfm" />
<cfset auditionSourceService = createObject("component", "services.AuditionSourceService") />
<cfset findsource = auditionSourceService.SELaudsources_24359(audsource=y.audsource) />