<cfset service = createObject("component", "services.AuditionDialectService")>
<cfset new_auddialectid = service.INSauddialects(
    new_auddialect = new_auddialect,
    new_audCatid = new_audCatid,
    new_isDeleted = new_isDeleted
)>