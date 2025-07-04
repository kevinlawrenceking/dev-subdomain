<cfset componentPath = "/services/AuditionGenreService">
<cfset auditionGenreService = createObject("component", componentPath)>
<cfset auditionGenreService.UPDaudgenres(
    new_audgenre = new_audgenre,
    new_audCatid = new_audCatid,
    new_isDeleted = new_isDeleted,
    new_audgenreid = new_audgenreid
)>