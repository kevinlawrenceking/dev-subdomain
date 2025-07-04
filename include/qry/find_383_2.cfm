<cfset auditionMediaXRefService = createObject("component", "services.AuditionMediaXRefService")>
<cfset find = auditionMediaXRefService.SELaudmedia_auditions_xref(
    new_mediaID = new_mediaID,
    audprojectid = audprojectid
)>