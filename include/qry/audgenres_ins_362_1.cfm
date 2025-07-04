<cfset auditionGenreService = createObject("component", "services.AuditionGenreService")>
<cfset new_audgenreid = auditionGenreService.INSaudgenres(
    new_audgenre = trim(new_audgenre),
    new_audCatid = new_audCatid,
    new_isDeleted = new_isDeleted
)>