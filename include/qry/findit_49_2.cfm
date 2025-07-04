<cfset auditionGenreUserService = createObject("component", "services.AuditionGenreUserService")>
<cfset findit = auditionGenreUserService.SELaudgenres_user(audcatid=audcatid, userid=userid)>