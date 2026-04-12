<cfinclude template="/include/perfcount.cfm" />
<cfset AuditionAgeRangeXRefService = createObject("component", "services.AuditionAgeRangeXRefService")>
<cfset AuditionAgeRangeXRefService.INSaudageranges_audtion_xref(new_rangeid=new_rangeid, new_audroleid=new_audroleid) />