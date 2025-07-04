<cfset genreAuditionService = createObject("component", "services.GenreAuditionService")>
<cfset export_ac = genreAuditionService.SELaudgenres_audition_xref(projectList="#projectlist#")>