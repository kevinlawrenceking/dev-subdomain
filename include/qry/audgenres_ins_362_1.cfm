<cfset auditionGenreService = createObject("component", "services.AuditionGenreService")>
<!--- Create new audition genre using the standardized function name --->
<cfset new_audgenreid = auditionGenreService.create(
    audgenre = trim(new_audgenre),
    audCatid = new_audCatid,
    isDeleted = new_isDeleted ?: false
)>