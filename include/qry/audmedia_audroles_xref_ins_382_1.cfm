<cfset service = createObject("component", "services.AuditionMediaAudRolesXRefService")>
<cfset service.UPDaudmedia_audroles_xref(
    new_mediaid = new_mediaid,
    new_audroleid = new_audroleid,
    new_mediaAudroleDescript = new_mediaAudroleDescript,
    new_isDeleted = new_isDeleted,
    conditionColumn = "yourConditionColumn", 
    conditionValue = "yourConditionValue"
)>