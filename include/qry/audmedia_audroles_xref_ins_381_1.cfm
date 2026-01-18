<cfset componentPath = "/services/AuditionMediaAudRolesXRefService">
<cfset componentInstance = createObject("component", componentPath)>
<cfset new_ = componentInstance.INSaudmedia_audroles_xref(
    new_mediaid = new_mediaid,
    new_audroleid = new_audroleid,
    new_mediaAudroleDescript = new_mediaAudroleDescript,
    new_isDeleted = new_isDeleted
)>