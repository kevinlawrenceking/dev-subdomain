<cfset genreAuditionService = createObject("component", "services.GenreAuditionService")>
<cfset findge = genreAuditionService.SELaudgenres_audition_xref_24274(
    audgenre=genres.audgenre,
    audroleid=audroleid
)>