<cfset AuditionDialectsUserService = createObject("component", "services.AuditionDialectsUserService")>
<cfset new_audDialectID = AuditionDialectsUserService.INSauddialects_user(
    CustomDialect = CustomDialect,
    new_catid = new_catid,
    userid = userid
)>