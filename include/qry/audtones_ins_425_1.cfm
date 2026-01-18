<cfset auditionTonesService = createObject("component", "services.AuditionTonesService")>
<cfset new_toneid = auditionTonesService.INSaudtones(
    new_tone = new_tone,
    new_audCatid = new_audCatid,
    new_isDeleted = new_isDeleted
)>