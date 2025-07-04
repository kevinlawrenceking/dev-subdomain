<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>
<cfset results = auditionProjectService.getAuditions(
    userid = userid,
    byimport = byimport,
    sel_contactid = sel_contactid,
    colist = colist,
    sel_audcatid = sel_audcatid,
    sel_audstepid = sel_audstepid,
    sel_audtype = sel_audtype,
    auddate = auddate,
    cur_date = cur_date,
    materials = materials,
    audsearch = audsearch
)>