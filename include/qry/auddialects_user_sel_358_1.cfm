
<cfset audDialectsService = createObject("component", "services.AuditionDialectsUserService")>
<cfif isNumeric(projectDetails.audcatid) and val(projectDetails.audcatid) gt 0>
    <cfset auddialects_user_sel = audDialectsService.SELauddialects_user(userid=userid, new_audcatid=projectDetails.audcatid)>
<cfelse>
    <cfset auddialects_user_sel = queryNew("ID,NAME,audcatid,userid", "integer,varchar,integer,integer")>
</cfif>