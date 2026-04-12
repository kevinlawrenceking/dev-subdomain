<cfinclude template="/include/perfcount.cfm" />
<cfset rangesService = createObject("component", "services.AuditionAgeRangeService")>
<cfset ranges = rangesService.SELaudageranges(false)>