<cfset auditionStepService = createObject("component", "services.AuditionStepService")>
<cfset new_audstepid = auditionStepService.INSaudsteps(new_audstep=new_audstep, new_isDeleted=new_isDeleted)>