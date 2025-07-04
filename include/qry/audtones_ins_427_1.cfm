<cfset auditionTonesService = createObject("component", "services.AuditionTonesService.cfc")>
<cfset auditionTonesService.UPDaudtones(
    new_tone=new_tone,
    new_audCatid=new_audCatid,
    new_isDeleted=new_isDeleted,
    new_toneid=new_toneid
)>
