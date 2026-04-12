<cfinclude template="/include/perfcount.cfm" />
<cfset auditionStepService = createObject("component", "services.AuditionStepService") />
<cfset audsteps_sel = auditionStepService.SELaudsteps_23792(userid=userid) />