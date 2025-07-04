

<cfset audDialectsService = createObject("component", "services.AuditionDialectsUserService")>
<cfset auddialects_user_sel = audDialectsService.SELauddialects_user(userid=userid, new_audcatid=projectDetails.audcatid)>