<cfinclude template="/include/perfcount.cfm" />
<cfset auditionGenreUserService = createObject("component", "services.AuditionGenreUserService")>
<cfset findit = auditionGenreUserService.SELaudgenres_user_24272(new_audcatid=new_audcatid, userid=userid)>