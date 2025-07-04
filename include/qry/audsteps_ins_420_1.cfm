<cfset auditionStepService = createObject("component", "services.AuditionStepService")>
<cfset auditionStepService.UPDaudsteps(
    new_audstep = new_audstep,
    new_isDeleted = new_isDeleted,
    new_audstepid = new_audstepid
)>