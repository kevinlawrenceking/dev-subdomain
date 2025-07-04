<cfset auditionEssenceXRefService = createObject("component", "services.AuditionEssenceXRefService")>
<cfset findg = auditionEssenceXRefService.SELaudessences_audtion_xref(
    essencename = essences.essencename,
    audroleid = audroleid,
    userid = userid
)>