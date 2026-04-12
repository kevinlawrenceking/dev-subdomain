<cfinclude template="/include/perfcount.cfm" />
<cfset audPayCycleService = createObject("component", "services.AuditionPayCycleService")>
<cfset audpaycycles_sel = audPayCycleService.SELaudpaycycles()>