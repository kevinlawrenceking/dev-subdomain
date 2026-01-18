<cfset componentPath = "services.AuditionGenreService">
<cfset auditionGenreService = createObject("component", componentPath)>

<!--- Update audition genre using the standardized function name --->
<cfset auditionGenreService.update(
    audgenreid = new_audgenreid,
    audgenre = trim(new_audgenre),
    audCatid = new_audCatid,
    isDeleted = new_isDeleted ?: false
)>