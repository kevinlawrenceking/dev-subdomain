<cfinclude template="/include/perfcount.cfm" />
<cfset audPayCycleService = createObject("component", "services.AuditionPayCycleService")>
<cfset audpaycyles_sel = audPayCycleService.SELaudpaycycles_24579()>