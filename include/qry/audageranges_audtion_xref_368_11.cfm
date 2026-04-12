<cfinclude template="/include/perfcount.cfm" />
<cfset auditionAgeRangeService = createObject("component", "services.AuditionAgeRangeService")>
<cfset audageranges_audtion_xref = auditionAgeRangeService.SELaudageranges_24552(audroleid=audroleid)>