<cfinclude template="/include/perfcount.cfm" />
<cfset genreAuditionService = createObject("component", "services.GenreAuditionService")>
<cfset genreAuditionService.DELaudgenres_audition_xref(new_audroleid=new_audroleid)>