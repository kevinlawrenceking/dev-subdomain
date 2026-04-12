<cfinclude template="/include/perfcount.cfm" />
<cfset auditionStepService = createObject("component", "services.AuditionStepService")>
<cfset audsteps_sel = auditionStepService.SELaudsteps_24083(isDeleted=false)>